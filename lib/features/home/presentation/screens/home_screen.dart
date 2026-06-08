import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/appointment_card_widget.dart';
import 'package:smartclinic/core/widgets/custom_nav_bar.dart';
import 'package:smartclinic/core/widgets/doctor_card_widget.dart';
import 'package:smartclinic/core/widgets/home_header.dart';
import 'package:smartclinic/core/widgets/search_engine.dart';
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

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
    _appointmentsController = PageController(viewportFraction: 0.96);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<DoctorsCubit>().searchDoctors(pageSize: 12, pageNumber: 1);
    });
    _autoSwipeTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      final currentPage = _appointmentsController.hasClients
          ? (_appointmentsController.page ??
                    _appointmentsController.initialPage)
                .round()
          : _appointmentsController.initialPage;
      final nextPage = (currentPage + 1) % 2;
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
              const SearchEngineBar(),
              SizedBox(height: 16),
              _buildSectionTitle(
                'My Appointments',
                onSeeAllTap: () =>
                    Navigator.pushNamed(context, AppRoutes.appointments),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 130,
                child: PageView.builder(
                  controller: _appointmentsController,
                  itemCount: 2,
                  padEnds: true,
                  itemBuilder: (context, index) {
                    final data = index == 0
                        ? {
                            'doctorName': 'Dr. Mahmoud Abo Leila',
                            'specialization': 'Dentist',
                            'appointmentDate': 'June 13 2056',
                            'appointmentTime': '3:30 PM',
                            'imagePath':
                                AppImages.imagesDoctorDRMahmoudAboLeila,
                          }
                        : {
                            'doctorName': 'Dr. Sara Hassan',
                            'specialization': 'Cardiologist',
                            'appointmentDate': 'June 14 2056',
                            'appointmentTime': '5:00 PM',
                            'imagePath': AppImages.imagesDoctorDRSaraHassan,
                          };

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: AppointmentCardWidget(
                        doctorName: data['doctorName']!,
                        specialization: data['specialization']!,
                        appointmentDate: data['appointmentDate']!,
                        appointmentTime: data['appointmentTime']!,
                        imagePath: data['imagePath']!,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.doctorProfileView,
                            arguments: {'name': data['doctorName']},
                          );
                        },
                      ),
                    );
                  },
                ),
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
                              onPressed: () {},
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
              _buildSectionTitle(
                'Popular Doctors',
                onSeeAllTap: () =>
                    Navigator.pushNamed(context, AppRoutes.search),
              ),
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
                                'doctorImage': doctor.resolvedImageUrl,
                                'specialization': doctor.specialization,
                                'rating': rating,
                                'reviewsCount': doctor.reviewsCount,
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
      return state.response.doctors;
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
