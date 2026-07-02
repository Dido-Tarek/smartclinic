import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/appointment_card_widget.dart';
import 'package:smartclinic/core/widgets/custom_nav_bar.dart';
import 'package:smartclinic/core/widgets/doctor_card_widget.dart';
import 'package:smartclinic/core/widgets/home_header.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/appointments/data/model/appointment_response_model.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_cubit.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_state.dart';
import 'package:smartclinic/features/health_issues/data/models/health_issues_model.dart';
import 'package:smartclinic/features/health_issues/presentation/manager/health_issues_cubit.dart';
import 'package:smartclinic/features/health_issues/presentation/manager/health_issues_state.dart';
import 'package:smartclinic/features/user_management/data/repo/user_management_repo.dart';
import 'package:smartclinic/injection_dependency.dart';
import 'package:smartclinic/features/search/data/model/search_doctors_response_model.dart';
import 'package:smartclinic/features/search/presentation/manager/search_doctors_cubit.dart';
import 'package:smartclinic/features/search/presentation/manager/search_doctors_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final int _currentIndex = 0;
  late final UserSession _userSession;
  late final PageController _appointmentsController;
  Timer? _autoSwipeTimer;
  late final AnimationController _shineController;
  late final Animation<double> _shadowAnim;
  int _appointmentPageCount = 1;
  final Map<String, String?> _doctorPhotoCache = {};

  // ── Medical history personalisation ─────────────────────────────────────────
  List<HealthIssueModel> _activeIssues = [];
  String? _recommendedSpecialization;
  bool _isPersonalised = false;

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
    _appointmentsController = PageController(viewportFraction: 0.96);
    _fetchCurrentUserPhoto();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppointmentsCubit>().getMyAppointments();
      // For patients: fetch history first → personalise popular doctors.
      // For doctors: just load generic popular doctors directly.
      if (!_userSession.userRole.isDoctor) {
        context.read<HealthIssuesCubit>().emitGetPatientHistory();
      } else {
        context.read<DoctorsCubit>().searchDoctors(pageSize: 5, pageNumber: 1);
      }
    });
    _autoSwipeTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      final currentPage = _appointmentsController.hasClients
          ? (_appointmentsController.page ??
                    _appointmentsController.initialPage)
                .round()
          : _appointmentsController.initialPage;
      final nextPage = (currentPage + 1) % _appointmentPageCount;
      _appointmentsController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _shadowAnim = Tween<double>(begin: 4.0, end: 14.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _autoSwipeTimer?.cancel();
    _appointmentsController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  // ── Disease → Specialization mapping ──────────────────────────────────────

  /// Picks the most relevant specialization from the patient's active issues.
  String? _resolveSpecializationFromHistory(List<HealthIssueModel> issues) {
    final activeIssues = issues.where((issue) {
      final status = (issue.status).toLowerCase().trim();
      final cured = issue.curedDate;
      return status == 'active' ||
          status == 'ongoing' ||
          status == 'chronic' ||
          status == 'current' ||
          (cured == null || cured.isEmpty);
    }).toList();

    if (activeIssues.isEmpty) return null;

    final Map<String, int> specScores = {};
    for (final issue in activeIssues) {
      final spec = _diseaseToSpecialization(issue.name);
      if (spec != null) {
        specScores[spec] = (specScores[spec] ?? 0) + 1;
      }
    }
    if (specScores.isEmpty) return null;
    return specScores.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
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
    if (name.contains('cancer') || name.contains('tumor') || name.contains('oncol') || name.contains('lymphoma') || name.contains('leukemia')) return 'Oncology';
    if (name.contains('allerg') || name.contains('immuno') || name.contains('autoimmune')) return 'Allergy & Immunology';
    if (name.contains('blood') || name.contains('anemia') || name.contains('hematol') || name.contains('thalassemia')) return 'Hematology';
    return null;
  }

  /// Called from the BlocListener when patient history is loaded.
  void _onHealthHistoryLoaded(List<HealthIssueModel> issues) {
    _activeIssues = issues;
    final spec = _resolveSpecializationFromHistory(issues);
    _recommendedSpecialization = spec;

    if (spec != null) {
      context.read<DoctorsCubit>().searchDoctors(
        specialization: spec,
        pageSize: 5,
        pageNumber: 1,
      );
      setState(() => _isPersonalised = true);
    } else {
      context.read<DoctorsCubit>().searchDoctors(pageSize: 5, pageNumber: 1);
      setState(() => _isPersonalised = false);
    }
  }

  // ── Data fetching ────────────────────────────────────────────────────────────

  Future<void> _fetchCurrentUserPhoto() async {
    final userId = _userSession.userId?.trim();
    if (userId == null || userId.isEmpty) return;

    if (_userSession.userRole.isDoctor) {
      final result = await getIt<UserManagementRepo>().getProfile(userId);
      result.when(
        success: (profile) async {
          final image = profile.profileImage;
          if (image != null && image.isNotEmpty) {
            await _userSession.saveProfileImage(image);
            if (mounted) setState(() {});
          }
        },
        failure: (_) {},
      );
    } else {
      final result = await getIt<UserManagementRepo>().getPatientProfile();
      result.when(
        success: (profile) async {
          final image = profile.profilePicture;
          if (image != null && image.isNotEmpty) {
            await _userSession.saveProfileImage(image);
            if (mounted) setState(() {});
          }
        },
        failure: (_) {},
      );
    }
  }

  Future<void> _fetchDoctorPhoto(String doctorId) async {
    if (_doctorPhotoCache.containsKey(doctorId)) return;
    _doctorPhotoCache[doctorId] = null;
    final result = await getIt<UserManagementRepo>().getProfile(doctorId);
    result.when(
      success: (profile) {
        if (mounted) {
          setState(() => _doctorPhotoCache[doctorId] = profile.profileImage);
        }
      },
      failure: (_) {
        if (mounted) setState(() {});
      },
    );
  }

  void _prefetchDoctorPhotos(List<AppointmentModel> appointments) {
    for (final appt in appointments) {
      final id = appt.doctorId;
      if (id != null && id.isNotEmpty && appt.doctorImage == null) {
        _fetchDoctorPhoto(id);
      }
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.pushNamed(context, AppRoutes.notifications);
  }

  Future<void> _openChatbot() async {
    await Navigator.pushNamed(context, AppRoutes.nouga);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      extendBody: true,
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _currentIndex,
        userRole: _userSession.userRole,
        onChatbotPressed: _openChatbot,
      ),
      body: _buildHomeBody(),
    );
  }

  Widget _buildHomeBody() {
    final fullName = _userSession.fullName?.trim();
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              HomeHeader(
                avatarPath: _userSession.profileImage,
                fallbackAssetPath: AppImages.imagesIconsPatient,
                title: fullName == null || fullName.isEmpty
                    ? 'Hi !'
                    : 'Hi, $fullName !',
                subtitle: 'How do you feel today?',
                onNotificationTap: _openNotifications,
              ),
              SizedBox(height: 16),
              _buildSectionTitle(
                'My Appointments',
                onSeeAllTap: () =>
                    Navigator.pushNamed(context, AppRoutes.appointments),
              ),
              SizedBox(height: 10),
              BlocConsumer<AppointmentsCubit, AppointmentsState>(
                listener: (context, apptState) {
                  if (apptState is GetMyAppointmentsSuccess) {
                    _prefetchDoctorPhotos(apptState.response.appointments);
                  }
                },
                builder: (context, apptState) {
                  final upcoming = _resolveUpcomingAppointments(apptState);
                  final itemCount = upcoming.isEmpty ? 1 : upcoming.length;
                  _appointmentPageCount = itemCount;
                  return SizedBox(
                    height: 130,
                    child: PageView.builder(
                      controller: _appointmentsController,
                      itemCount: itemCount,
                      padEnds: true,
                      itemBuilder: (context, index) {
                        if (upcoming.isEmpty) {
                          return _buildBookingAdCard(context);
                        }
                        final appt = upcoming[index];
                        final resolvedPhoto =
                            _doctorPhotoCache[appt.doctorId] ??
                            appt.doctorImage;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: AppointmentCardWidget(
                            doctorName: appt.doctorName ?? '',
                            specialization: appt.type ?? appt.clinicName ?? '',
                            appointmentDate: appt.displayDate,
                            appointmentTime: appt.displayTime,
                            imagePath: AppImages.imagesIconsDoctor,
                            imageUrl: resolvedPhoto,
                            showArrow: true,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.appointments,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildSectionTitle('Emergency', showSeeAll: false),
              SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Immediate Care Appointment',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Book the next available ER doctor now',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: AnimatedBuilder(
                        animation: _shineController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.error.withValues(
                                    alpha: 0.28,
                                  ),
                                  blurRadius: _shadowAnim.value,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.emergencySearch,
                                arguments: {'activeIssues': _activeIssues},
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'BOOK NOW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Health issues listener – fires personalised doctor search
              BlocListener<HealthIssuesCubit, HealthIssuesState>(
                listener: (context, healthState) {
                  healthState.whenOrNull(
                    success: (data) {
                      if (data is List<HealthIssueModel>) {
                        _onHealthHistoryLoaded(data);
                      }
                    },
                  );
                },
                child: const SizedBox.shrink(),
              ),
              _buildSectionTitle(
                _isPersonalised ? 'Recommended for You' : 'Popular Doctors',
                onSeeAllTap: () =>
                    Navigator.pushNamed(context, AppRoutes.search),
              ),
              if (_isPersonalised && _recommendedSpecialization != null) ...[  
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.favorite_rounded, size: 13, color: AppColors.error),
                    SizedBox(width: 5),
                    Text(
                      'Based on your $_recommendedSpecialization history',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 12),
              BlocBuilder<DoctorsCubit, DoctorsState>(
                builder: (context, state) {
                  final doctors = _resolvePopularDoctors(state);
                  final isLoading =
                      state is SearchDoctorsLoading && doctors.isEmpty;

                  if (isLoading) {
                    return const SizedBox(
                      height: 290,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return SizedBox(
                    height: 290,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: doctors.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 18),
                      itemBuilder: (context, index) {
                        final doctor = doctors[index];
                        final imageSource =
                            doctor.resolvedImageUrl ??
                            _fallbackDoctorImage(doctor);
                        final rating = _resolveDoctorRating(doctor);

                        return SizedBox(
                          width: 180,
                          child: DoctorCardWidget(
                            doctorName: doctor.name ?? 'Doctor',
                            specialization: doctor.specialization ?? 'Doctor',
                            rating: rating,
                            reviewsCount: doctor.reviewsCount,
                            imagePath: imageSource,
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
                                'rating': rating,
                                'reviewsCount': doctor.reviewsCount,
                                'clinicFee': doctor.consultationPrice,
                                'clinicName': doctor.clinicName,
                                'clinicAddress': doctor.clinicAddress,
                                'clinicPhone': doctor.clinicPhone,
                                'clinicWorkingHours': doctor.clinicWorkingHours,
                              },
                            ),
                            onFavoriteChanged: (value) {},
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title, {
    VoidCallback? onSeeAllTap,
    bool showSeeAll = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.deepNavy,
          ),
        ),
        if (showSeeAll)
          TextButton(
            onPressed: onSeeAllTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'see all',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.skyBlue,
              ),
            ),
          ),
      ],
    );
  }

  List<DoctorModel> _resolvePopularDoctors(DoctorsState state) {
    if (state is SearchDoctorsSuccess && state.response.doctors.isNotEmpty) {
      final doctors = state.response.doctors;
      // Always show at most 5
      return doctors.length > 5 ? doctors.sublist(0, 5) : doctors;
    }

    return _fallbackDoctors;
  }

  double _resolveDoctorRating(DoctorModel doctor) {
    final reviewsCount = doctor.reviewsCount;
    if (reviewsCount != null && reviewsCount > 0) {
      return (reviewsCount / 100).clamp(0.0, 5.0).toDouble();
    }

    return doctor.rating ?? 0;
  }

  List<AppointmentModel> _resolveUpcomingAppointments(AppointmentsState state) {
    if (state is! GetMyAppointmentsSuccess) return const [];
    return state.response.appointments.where((a) {
      final s = (a.status ?? '').trim().toLowerCase();
      return s.isEmpty ||
          s.contains('upcoming') ||
          s.contains('scheduled') ||
          s.contains('pending') ||
          s.contains('confirmed') ||
          s.contains('booked') ||
          s.contains('accepted');
    }).toList();
  }

  Widget _buildBookingAdCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.search),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.deepNavy, AppColors.skyBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepNavy.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'No upcoming appointments',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Find & Book\nYour Doctor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Search top-rated specialists near you',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Search',
                    style: TextStyle(
                      color: AppColors.deepNavy,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fallbackDoctorImage(DoctorModel doctor) {
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

const List<DoctorModel> _fallbackDoctors = <DoctorModel>[
  DoctorModel(
    id: '1',
    name: 'Mai El Kady',
    specialization: 'Dentist',
    city: 'Cairo',
    area: 'Nasr City',
    consultationType: 0,
    consultationPrice: 250,
    reviewsCount: 380,
    rating: 3.8,
    imageUrl: AppImages.imagesDoctorDRMaiElKady,
  ),
  DoctorModel(
    id: '2',
    name: 'Ahmed Alaa',
    specialization: 'Cardiologist',
    city: 'Cairo',
    area: 'Maadi',
    consultationType: 1,
    consultationPrice: 300,
    reviewsCount: 400,
    rating: 4.0,
    imageUrl: AppImages.imagesDoctorDRAhmedAlaa,
  ),
  DoctorModel(
    id: '3',
    name: 'Khoulod Ashraf',
    specialization: 'Neurologist',
    city: 'Alexandria',
    area: 'Heliopolis',
    consultationType: 2,
    consultationPrice: 350,
    reviewsCount: 420,
    rating: 4.2,
    imageUrl: AppImages.imagesDoctorDRKhoulodAshraf,
  ),
];
