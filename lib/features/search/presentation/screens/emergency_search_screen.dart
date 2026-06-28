import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/doctor_card_widget.dart';
import 'package:smartclinic/features/health_issues/data/models/health_issues_model.dart';
import 'package:smartclinic/features/search/data/model/search_doctors_response_model.dart';
import 'package:smartclinic/features/search/presentation/manager/search_doctors_cubit.dart';
import 'package:smartclinic/features/search/presentation/manager/search_doctors_state.dart';
import 'package:smartclinic/injection_dependency.dart';

class EmergencySearchScreen extends StatefulWidget {
  const EmergencySearchScreen({super.key});

  @override
  State<EmergencySearchScreen> createState() => _EmergencySearchScreenState();
}

class _EmergencySearchScreenState extends State<EmergencySearchScreen> {
  late final UserSession _userSession;
  String _selectedCity = 'All';
  String _selectedArea = 'All';
  String? _selectedSpecialization; // null = all specializations

  // Active health issues passed from home screen (for "Matches Your History" badge)
  List<HealthIssueModel> _activeIssues = [];
  // Specializations derived from active issues
  Set<String> _patientSpecializations = {};

  // Emergency consultation type value for the search API
  static const int _emergencyType = 3;

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
    _initLocationFromProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Read active issues passed as route arguments from home screen
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['activeIssues'] is List<HealthIssueModel>) {
        _activeIssues = args['activeIssues'] as List<HealthIssueModel>;
        _patientSpecializations = _buildPatientSpecializations(_activeIssues);
      }
      _searchDoctors();
    });
  }

  void _initLocationFromProfile() {
    final raw = (_userSession.address ?? '').toLowerCase().trim();
    if (raw.isEmpty) return;

    for (final city in _cityOptions.skip(1)) {
      if (raw.contains(city.toLowerCase())) {
        _selectedCity = city;
        break;
      }
    }
    for (final area in _areaOptions.skip(1)) {
      if (raw.contains(area.toLowerCase())) {
        _selectedArea = area;
        break;
      }
    }
  }

  /// Builds the set of specializations that match the patient's active issues.
  Set<String> _buildPatientSpecializations(List<HealthIssueModel> issues) {
    final specs = <String>{};
    for (final issue in issues) {
      final cured = issue.curedDate;
      final status = issue.status.toLowerCase().trim();
      final isActive = status == 'active' ||
          status == 'ongoing' ||
          status == 'chronic' ||
          status == 'current' ||
          (cured == null || cured.isEmpty);
      if (!isActive) continue;
      final spec = _diseaseToSpecialization(issue.name);
      if (spec != null) specs.add(spec.toLowerCase());
    }
    return specs;
  }

  static String? _diseaseToSpecialization(String diseaseName) {
    final name = diseaseName.toLowerCase();
    if (name.contains('diabet') || name.contains('endocrin') || name.contains('thyroid') || name.contains('insulin')) return 'Endocrinology';
    if (name.contains('heart') || name.contains('cardio') || name.contains('cardiac') || name.contains('hypertens') || name.contains('blood pressure') || name.contains('coronary')) return 'Cardiology';
    if (name.contains('neuro') || name.contains('brain') || name.contains('epilepsy') || name.contains('stroke') || name.contains('migraine') || name.contains('parkinson') || name.contains('alzheimer')) return 'Neurology';
    if (name.contains('lung') || name.contains('asthma') || name.contains('pulmo') || name.contains('respiratory') || name.contains('bronch') || name.contains('copd')) return 'Pulmonology';
    if (name.contains('kidney') || name.contains('renal') || name.contains('nephro')) return 'Nephrology';
    if (name.contains('joint') || name.contains('arthr') || name.contains('bone') || name.contains('ortho') || name.contains('spine') || name.contains('fracture')) return 'Orthopedics';
    if (name.contains('skin') || name.contains('dermat') || name.contains('acne') || name.contains('eczema')) return 'Dermatology';
    if (name.contains('mental') || name.contains('depress') || name.contains('anxiety') || name.contains('psych') || name.contains('bipolar')) return 'Psychiatry';
    if (name.contains('stomach') || name.contains('gastro') || name.contains('intestin') || name.contains('colon') || name.contains('liver') || name.contains('hepat') || name.contains('ibs')) return 'Gastroenterology';
    if (name.contains('eye') || name.contains('ophthalm') || name.contains('vision') || name.contains('glaucom') || name.contains('cataract')) return 'Ophthalmology';
    if (name.contains('ear') || name.contains('ent') || name.contains('throat') || name.contains('nose') || name.contains('sinus') || name.contains('tonsil')) return 'ENT';
    if (name.contains('urology') || name.contains('bladder') || name.contains('prostate') || name.contains('kidney stone')) return 'Urology';
    return null;
  }

  void _searchDoctors() {
    if (!mounted) return;
    // Pass city only — area sorting is handled client-side so we get all
    // doctors in the city and split them by area proximity.
    context.read<DoctorsCubit>().searchDoctors(
      city: _selectedCity == 'All' ? null : _selectedCity,
      consultationType: _emergencyType,
      specialization: _selectedSpecialization,
      pageNumber: 1,
      pageSize: 50,
    );
  }

  /// Returns true if this doctor's specialization matches the patient's history.
  bool _matchesPatientHistory(DoctorModel doctor) {
    if (_patientSpecializations.isEmpty) return false;
    final spec = (doctor.specialization ?? '').toLowerCase();
    return _patientSpecializations.any(
      (ps) => spec.contains(ps) || ps.contains(spec),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CustomAppBar(
        title: 'Emergency Doctors',
        showBackButton: true,
        onBackTap: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: BlocBuilder<DoctorsCubit, DoctorsState>(
          builder: (context, state) {
            final allDoctors = _resolveDoctors(state);
            final isLoading =
                state is SearchDoctorsLoading && allDoctors.isEmpty;

            // Client-side specialization filter
            final filteredDoctors = _selectedSpecialization == null
                ? allDoctors
                : allDoctors
                      .where(
                        (d) =>
                            (d.specialization ?? '').toLowerCase().contains(
                              _selectedSpecialization!.toLowerCase(),
                            ),
                      )
                      .toList();

            // Split into area-matching and rest, both sorted by rating desc
            final areaDoctors = <DoctorModel>[];
            final cityDoctors = <DoctorModel>[];

            if (_selectedArea != 'All') {
              for (final doc in filteredDoctors) {
                if (doc.area == _selectedArea) {
                  areaDoctors.add(doc);
                } else {
                  cityDoctors.add(doc);
                }
              }
            } else {
              cityDoctors.addAll(filteredDoctors);
            }

            areaDoctors.sort(
              (a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0),
            );
            cityDoctors.sort(
              (a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0),
            );

            final totalVisible = areaDoctors.length + cityDoctors.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmergencyBanner(totalVisible),
                  const SizedBox(height: 18),
                  _buildLocationSection(),
                  const SizedBox(height: 12),
                  _buildSpecializationChips(),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (areaDoctors.isEmpty && cityDoctors.isEmpty)
                    _buildEmptyState()
                  else
                    _buildDoctorSections(areaDoctors, cityDoctors),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmergencyBanner(int doctorCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emergency_rounded,
              color: AppColors.error,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Immediate Care',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Doctors sorted by closest area then highest rating',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (doctorCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$doctorCount\navailable',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Location',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FilterDropdown(
                label: 'City',
                value: _selectedCity,
                items: _cityOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value!;
                    _selectedArea = 'All';
                  });
                  _searchDoctors();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterDropdown(
                label: 'Area',
                value: _selectedArea,
                items: _areaOptions,
                onChanged: (value) => setState(() => _selectedArea = value!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Quick-filter chips for emergency specialization
  Widget _buildSpecializationChips() {
    final chips = [
      (null, 'All'),
      ('General', 'General'),
      ('Cardiology', 'Cardio'),
      ('Neurology', 'Neuro'),
      ('Orthopedics', 'Ortho'),
      ('Pulmonology', 'Pulmo'),
      ('Gastroenterology', 'Gastro'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specialization',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chips.map((chip) {
              final isSelected = _selectedSpecialization == chip.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedSpecialization = chip.$1);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.error
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.error
                            : AppColors.deepNavy.withValues(alpha: 0.15),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.error.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      chip.$2,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorSections(
    List<DoctorModel> areaDoctors,
    List<DoctorModel> cityDoctors,
  ) {
    final cityLabel = _selectedCity == 'All' ? 'Your City' : _selectedCity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (areaDoctors.isNotEmpty) ...[
          _buildSectionHeader(
            icon: Icons.location_on_rounded,
            title: 'Doctors in $_selectedArea',
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          _buildDoctorsGrid(areaDoctors),
          const SizedBox(height: 24),
        ],
        if (cityDoctors.isNotEmpty) ...[
          _buildSectionHeader(
            icon: Icons.location_city_rounded,
            title: areaDoctors.isNotEmpty
                ? 'Other Doctors in $cityLabel'
                : _selectedCity != 'All'
                    ? 'Doctors in $cityLabel'
                    : 'Available Emergency Doctors',
            color: AppColors.deepNavy,
          ),
          const SizedBox(height: 12),
          _buildDoctorsGrid(cityDoctors),
        ],
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorsGrid(List<DoctorModel> doctors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: doctors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        final matchesHistory = _matchesPatientHistory(doctor);
        return Stack(
          children: [
            DoctorCardWidget(
              doctorName: doctor.name ?? 'Doctor',
              specialization: doctor.specialization ?? 'Doctor',
              rating: doctor.rating ?? 0,
              reviewsCount: doctor.reviewsCount,
              imagePath: doctor.resolvedImageUrl ?? _fallbackImage(doctor),
              imageUrl: doctor.resolvedImageUrl,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.doctorProfileView,
                arguments: {
                  'name': doctor.name,
                  'doctorId': doctor.id,
                  'clinicId': doctor.clinicId,
                  'doctorImage': doctor.resolvedImageUrl,
                  'specialization': doctor.specialization,
                  'rating': doctor.rating ?? 0.0,
                  'reviewsCount': doctor.reviewsCount,
                  'emergencyFee': doctor.consultationPrice,
                  'clinicName': doctor.clinicName,
                  'clinicAddress': doctor.clinicAddress,
                  'clinicPhone': doctor.clinicPhone,
                  'clinicWorkingHours': doctor.clinicWorkingHours,
                  'enabledConsultationTypes': ['Emergency'],
                },
              ),
              onFavoriteChanged: (_) {},
            ),
            // "Matches Your History" badge
            if (matchesHistory)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.favorite_rounded,
                        size: 9,
                        color: Colors.white,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Matches You',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No emergency doctors found\nin this area.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try selecting a different city or area.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DoctorModel> _resolveDoctors(DoctorsState state) {
    if (state is SearchDoctorsSuccess && state.response.doctors.isNotEmpty) {
      return state.response.doctors;
    }
    return _emergencyFallbackDoctors;
  }

  String _fallbackImage(DoctorModel doctor) {
    final spec = (doctor.specialization ?? '').toLowerCase();
    final name = (doctor.name ?? '').toLowerCase();
    if (name.contains('razan')) return AppImages.imagesDoctorDRRazanHany;
    if (spec.contains('neuro')) return AppImages.imagesDoctorDRKhoulodAshraf;
    if (spec.contains('cardio')) return AppImages.imagesDoctorDRAhmedAlaa;
    if (spec.contains('dent')) return AppImages.imagesDoctorDRMaiElKady;
    return AppImages.imagesDoctorDRHussienShokry;
  }
}

// ── Filter Dropdown ───────────────────────────────────────────────────────────

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.deepNavy.withValues(alpha: 0.12),
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items
                .map(
                  (item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)),
                )
                .toList(),
            onChanged: onChanged,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Options ───────────────────────────────────────────────────────────────────

const List<String> _cityOptions = <String>[
  'All',
  'Cairo',
  'Giza',
  'Alexandria',
];

const List<String> _areaOptions = <String>[
  'All',
  'Nasr City',
  'Maadi',
  'Heliopolis',
  'Zamalek',
  'Dokki',
  'Mohandessin',
  'New Cairo',
  'Haram',
  'Agouza',
];

// ── Emergency Fallback Doctors (shown when API returns empty) ─────────────────

const List<DoctorModel> _emergencyFallbackDoctors = <DoctorModel>[
  DoctorModel(
    id: '1',
    name: 'Dr. Mai El Kady',
    specialization: 'General Practitioner',
    city: 'Cairo',
    area: 'Nasr City',
    consultationType: 3,
    consultationPrice: 350,
    rating: 4.5,
    reviewsCount: 520,
    imageUrl: AppImages.imagesDoctorDRMaiElKady,
  ),
  DoctorModel(
    id: '2',
    name: 'Dr. Hussien Shokry',
    specialization: 'Emergency Medicine',
    city: 'Cairo',
    area: 'Nasr City',
    consultationType: 3,
    consultationPrice: 400,
    rating: 4.2,
    reviewsCount: 410,
    imageUrl: AppImages.imagesDoctorDRHussienShokry,
  ),
  DoctorModel(
    id: '3',
    name: 'Dr. Khoulod Ashraf',
    specialization: 'Neurologist',
    city: 'Cairo',
    area: 'Maadi',
    consultationType: 3,
    consultationPrice: 380,
    rating: 4.8,
    reviewsCount: 680,
    imageUrl: AppImages.imagesDoctorDRKhoulodAshraf,
  ),
  DoctorModel(
    id: '4',
    name: 'Dr. Ahmed Alaa',
    specialization: 'Cardiologist',
    city: 'Cairo',
    area: 'Heliopolis',
    consultationType: 3,
    consultationPrice: 450,
    rating: 4.0,
    reviewsCount: 380,
    imageUrl: AppImages.imagesDoctorDRAhmedAlaa,
  ),
];
