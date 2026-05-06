import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/appointment_card_widget.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/custom_nav_bar.dart';
import 'package:smartclinic/core/widgets/doctor_card_widget.dart';
import 'package:smartclinic/core/widgets/home_header.dart';
import 'package:smartclinic/core/widgets/search_engine.dart';
import 'package:smartclinic/core/widgets/specialization_widget.dart';
import 'package:smartclinic/features/chat/presentation/screens/chat.dart';
import 'package:smartclinic/features/notification/domain/repo/notifications_repo.dart';
import 'package:smartclinic/injection_dependency.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _unreadNotificationsCount = 0;
  late final PageController _appointmentsController;
  Timer? _autoSwipeTimer;

  @override
  void initState() {
    super.initState();
    _refreshUnreadNotificationsCount();
    _appointmentsController = PageController(viewportFraction: 0.96);
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
  }

  @override
  void dispose() {
    _autoSwipeTimer?.cancel();
    _appointmentsController.dispose();
    super.dispose();
  }

  Future<void> _refreshUnreadNotificationsCount() async {
    final result = await getIt<NotificationsRepo>().getUnreadCount();
    if (!mounted) {
      return;
    }

    result.when(
      success: (data) {
        setState(() {
          _unreadNotificationsCount = data.count;
        });
      },
      failure: (_) {
        setState(() {
          _unreadNotificationsCount = 0;
        });
      },
    );
  }

  Future<void> _openNotifications() async {
    await Navigator.pushNamed(context, AppRoutes.notifications);
    if (!mounted) {
      return;
    }
    await _refreshUnreadNotificationsCount();
  }

  Future<void> _openChatbot() async {
    await Navigator.pushNamed(context, AppRoutes.nouga);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      extendBody: true,
      appBar: _currentIndex == 1
          ? CustomAppBar(
              title: 'Inbox',
              showBackButton: false,
              onNotificationTap: _openNotifications,
            )
          : null,
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) => setState(() => _currentIndex = index),
        onChatbotPressed: _openChatbot,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CustomNavBar.buildChatbotButton(
        onPressed: _openChatbot,
      ),
      body: _currentIndex == 1
          ? const InboxChatRoomsScreen()
          : _buildHomeBody(),
    );
  }

  Widget _buildHomeBody() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              HomeHeader(
                avatarAssetPath: AppImages.imagesIconsPatient,
                title: 'Hi, Khatab !',
                subtitle: 'How do you feel today?',
                showNotificationDot: _unreadNotificationsCount > 0,
                onNotificationTap: _openNotifications,
              ),
              SizedBox(height: 16),
              const SearchEngineBar(),
              SizedBox(height: 16),
              _buildSectionTitle('My Appointments'),
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
                        onTap: () {},
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              _buildSectionTitle('Doctor Specialty'),
              SizedBox(height: 12),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _specialties.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = _specialties[index];
                    return SpecializationWidget(
                      specializationName: item.title,
                      iconPath: item.iconPath,
                      iconData: item.iconData,
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              _buildSectionTitle('Popular Doctors'),
              SizedBox(height: 12),
              SizedBox(
                height: 290,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: _doctors.length,
                  separatorBuilder: (_, __) => SizedBox(width: 18),
                  itemBuilder: (context, index) {
                    final item = _doctors[index];
                    return DoctorCardWidget(
                      doctorName: item.name,
                      specialization: item.specialization,
                      rating: item.rating,
                      imagePath: item.imagePath,
                      onTap: () {},
                      onFavoriteChanged: (value) {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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
        TextButton(
          onPressed: () {},
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
}

class _SpecialtyItem {
  const _SpecialtyItem({required this.title, this.iconPath, this.iconData});

  final String title;
  final String? iconPath;
  final IconData? iconData;
}

class _DoctorItem {
  const _DoctorItem({
    required this.name,
    required this.specialization,
    required this.rating,
    required this.imagePath,
  });

  final String name;
  final String specialization;
  final double rating;
  final String imagePath;
}

const List<_SpecialtyItem> _specialties = <_SpecialtyItem>[
  _SpecialtyItem(
    title: 'Neurologist',
    iconPath: AppImages.imagesSpecialityNeurologist,
  ),
  _SpecialtyItem(title: 'Dentistry', iconPath: AppImages.imagesSpecialityTooth),
  _SpecialtyItem(
    title: 'Cardiology',
    iconPath: AppImages.imagesSpecialityPhysician,
  ),
];

const List<_DoctorItem> _doctors = <_DoctorItem>[
  _DoctorItem(
    name: 'Dr. Mai El Kady',
    specialization: 'Dentist',
    rating: 3.8,
    imagePath: AppImages.imagesDoctorDRMaiElKady,
  ),
  _DoctorItem(
    name: 'Dr. Ahmed Alaa',
    specialization: 'Cardiologist',
    rating: 4.0,
    imagePath: AppImages.imagesDoctorDRAhmedAlaa,
  ),
  _DoctorItem(
    name: 'Dr. Khoulod Ashraf',
    specialization: 'Neurologist',
    rating: 4.2,
    imagePath: AppImages.imagesDoctorDRKhoulodAshraf,
  ),
];
