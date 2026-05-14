import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/doctor_card_widget.dart';
import 'package:smartclinic/core/widgets/search_engine.dart';
import 'package:smartclinic/features/search/data/model/search_doctors_response_model.dart';
import 'package:smartclinic/features/search/presentation/manager/search_doctors_cubit.dart';
import 'package:smartclinic/features/search/presentation/manager/search_doctors_state.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final TextEditingController _queryController = TextEditingController();
  Timer? _debounce;

  String _selectedSpecialization = 'All';
  String _selectedCity = 'All';
  String _selectedArea = 'All';
  String _selectedConsultationType = 'All';
  RangeValues _priceRange = const RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchDoctors());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _scheduleSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _searchDoctors);
  }

  void _searchDoctors() {
    if (!mounted) {
      return;
    }

    context.read<DoctorsCubit>().searchDoctors(
      query: _queryController.text.trim().isEmpty
          ? null
          : _queryController.text.trim(),
      specialization: _selectedSpecialization == 'All'
          ? null
          : _selectedSpecialization,
      city: _selectedCity == 'All' ? null : _selectedCity,
      area: _selectedArea == 'All' ? null : _selectedArea,
      consultationType: _consultationTypeToValue(_selectedConsultationType),
      maxPrice: _priceRange.end.round(),
      pageNumber: 1,
      pageSize: 20,
    );
  }

  int? _consultationTypeToValue(String value) {
    switch (value) {
      case 'Clinic':
        return 0;
      case 'Online':
        return 1;
      case 'Home Visit':
        return 2;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CustomAppBar(
        title: 'Find Doctors',
        onNotificationTap: () =>
            Navigator.pushNamed(context, AppRoutes.notifications),
      ),
      body: SafeArea(
        child: BlocBuilder<DoctorsCubit, DoctorsState>(
          builder: (context, state) {
            final baseDoctors = _resolveDoctors(state);
            final visibleDoctors = baseDoctors.where(_matchesFilters).toList();
            final isLoading = state is SearchDoctorsLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchEngineBar(
                    readOnly: false,
                    controller: _queryController,
                    onChanged: (_) => _scheduleSearch(),
                    onTap: _searchDoctors,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Filters',
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
                          label: 'Specialization',
                          value: _selectedSpecialization,
                          items: _specializationOptions,
                          onChanged: (value) {
                            setState(() => _selectedSpecialization = value!);
                            _scheduleSearch();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterDropdown(
                          label: 'City',
                          value: _selectedCity,
                          items: _cityOptions,
                          onChanged: (value) {
                            setState(() => _selectedCity = value!);
                            _scheduleSearch();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterDropdown(
                          label: 'Area',
                          value: _selectedArea,
                          items: _areaOptions,
                          onChanged: (value) {
                            setState(() => _selectedArea = value!);
                            _scheduleSearch();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterDropdown(
                          label: 'Consultation Type',
                          value: _selectedConsultationType,
                          items: _consultationTypeOptions,
                          onChanged: (value) {
                            setState(() => _selectedConsultationType = value!);
                            _scheduleSearch();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Price Range: ${_priceRange.start.round()} - ${_priceRange.end.round()} EGP',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: AppColors.deepNavy,
                      inactiveTrackColor: AppColors.deepNavy.withValues(
                        alpha: 0.18,
                      ),
                      thumbColor: Colors.white,
                      overlayColor: AppColors.skyBlue.withValues(alpha: 0.14),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 11,
                        elevation: 2,
                      ),
                      valueIndicatorTextStyle: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    child: RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 1000,
                      divisions: 20,
                      labels: RangeLabels(
                        _priceRange.start.round().toString(),
                        _priceRange.end.round().toString(),
                      ),
                      onChanged: (value) {
                        setState(() => _priceRange = value);
                        _scheduleSearch();
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (visibleDoctors.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 36),
                      child: Center(
                        child: Text(
                          'No doctors match the selected filters.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visibleDoctors.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.63,
                          ),
                      itemBuilder: (context, index) {
                        final doctor = visibleDoctors[index];
                        return DoctorCardWidget(
                          doctorName: doctor.name ?? 'Doctor',
                          specialization: doctor.specialization ?? 'Doctor',
                          rating: doctor.rating ?? 0,
                          imagePath: _resolveDoctorImage(doctor),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.doctorProfileView,
                            arguments: {'name': doctor.name},
                          ),
                          onFavoriteChanged: (_) {},
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<DoctorModel> _resolveDoctors(DoctorsState state) {
    if (state is SearchDoctorsSuccess && state.response.doctors.isNotEmpty) {
      return state.response.doctors;
    }

    return _fallbackDoctors;
  }

  bool _matchesFilters(DoctorModel doctor) {
    final query = _queryController.text.trim().toLowerCase();
    final doctorText = '${doctor.name ?? ''} ${doctor.specialization ?? ''}'
        .toLowerCase();

    if (query.isNotEmpty && !doctorText.contains(query)) {
      return false;
    }

    if (_selectedSpecialization != 'All' &&
        doctor.specialization != _selectedSpecialization) {
      return false;
    }

    if (_selectedCity != 'All' && doctor.city != _selectedCity) {
      return false;
    }

    if (_selectedArea != 'All' && doctor.area != _selectedArea) {
      return false;
    }

    final consultationType = _consultationTypeToValue(
      _selectedConsultationType,
    );
    if (consultationType != null &&
        doctor.consultationType != consultationType) {
      return false;
    }

    final price = doctor.consultationPrice;
    if (price != null &&
        (price < _priceRange.start || price > _priceRange.end)) {
      return false;
    }

    return true;
  }

  String _resolveDoctorImage(DoctorModel doctor) {
    final specialization = (doctor.specialization ?? '').toLowerCase();
    final name = (doctor.name ?? '').toLowerCase();

    if (name.contains('razan')) {
      return AppImages.imagesDoctorDRRazanHany;
    }

    if (specialization.contains('neuro')) {
      return AppImages.imagesDoctorDRKhoulodAshraf;
    }

    if (specialization.contains('cardio')) {
      return AppImages.imagesDoctorDRAhmedAlaa;
    }

    if (specialization.contains('dent')) {
      return AppImages.imagesDoctorDRMaiElKady;
    }

    return AppImages.imagesDoctorDRHussienShokry;
  }
}

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

const List<String> _specializationOptions = <String>[
  'All',
  'Dentist',
  'Cardiologist',
  'Neurologist',
];

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
];

const List<String> _consultationTypeOptions = <String>[
  'All',
  'Clinic',
  'Online',
  'Home Visit',
];

const List<DoctorModel> _fallbackDoctors = <DoctorModel>[
  DoctorModel(
    id: '1',
    name: 'Dr. Mai El Kady',
    specialization: 'Dentist',
    city: 'Cairo',
    area: 'Nasr City',
    consultationType: 0,
    consultationPrice: 250,
    rating: 3.8,
  ),
  DoctorModel(
    id: '2',
    name: 'Dr. Razan Hany',
    specialization: 'Dentist',
    city: 'Giza',
    area: 'Maadi',
    consultationType: 1,
    consultationPrice: 300,
    rating: 4.0,
  ),
  DoctorModel(
    id: '3',
    name: 'Dr. Khoulod Ashraf',
    specialization: 'Neurologist',
    city: 'Alexandria',
    area: 'Heliopolis',
    consultationType: 0,
    consultationPrice: 420,
    rating: 4.2,
  ),
  DoctorModel(
    id: '4',
    name: 'Dr. Hussien Shokry',
    specialization: 'Dentist',
    city: 'Cairo',
    area: 'Nasr City',
    consultationType: 2,
    consultationPrice: 280,
    rating: 4.0,
  ),
];
