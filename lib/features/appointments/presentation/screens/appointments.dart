import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/appointment_card_widget.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/custom_nav_bar.dart';
import 'package:smartclinic/features/appointments/data/model/appointment_response_model.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_cubit.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_state.dart';
import 'package:smartclinic/injection_dependency.dart';

class AppointmentsScreen extends StatefulWidget {
  final int initialIndex;

  const AppointmentsScreen({super.key, this.initialIndex = 0});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late final UserSession _userSession;
  late final PageController _upcomingController;

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
    _upcomingController = PageController(viewportFraction: 0.95);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<AppointmentsCubit>().getMyAppointments();
    });
  }

  @override
  void dispose() {
    _upcomingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentsCubit, AppointmentsState>(
      listener: (context, state) {
        if (state is GetMyAppointmentsFailure) {
          CherryToast.error(
            title: const Text('Error'),
            description: Text(state.errorMessage),
          ).show(context);
        }
      },
      builder: (context, state) {
        final upcomingAppointments = _resolveUpcomingAppointments(state);
        final isLoading = state is GetMyAppointmentsLoading;

        return DefaultTabController(
          initialIndex: widget.initialIndex,
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            appBar: CustomAppBar(
              title: 'My Appointments',
              onNotificationTap: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
            ),
            bottomNavigationBar: CustomNavBar(
              selectedIndex: 2,
              userRole: _userSession.userRole,
              onChatbotPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.nouga),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: TabBar(
                    indicatorColor: AppColors.blueAction,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.blueAction,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Cancelled'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: [
                      isLoading && upcomingAppointments.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : upcomingAppointments.isEmpty
                          ? _EmptyAppointmentsView(
                              onBookNow: () => Navigator.pushNamed(
                                context,
                                AppRoutes.search,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                              child: ListView.separated(
                                padding: EdgeInsets.only(
                                  top: 8,
                                  bottom:
                                      MediaQuery.of(context).padding.bottom +
                                      88, // ensure last item isn't hidden by nav bar
                                ),
                                physics: const BouncingScrollPhysics(),
                                itemCount: upcomingAppointments.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = upcomingAppointments[index];
                                  return AppointmentCardWidget(
                                    doctorName: item.doctorName,
                                    specialization: item.specialization,
                                    appointmentDate: item.appointmentDate,
                                    appointmentTime: item.appointmentTime,
                                    imagePath: item.imagePath,
                                    showArrow: false,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.bookingSummary,
                                        arguments: {
                                          'doctorName': item.doctorName,
                                          'specialization': item.specialization,
                                          'clinicName': item.clinicName,
                                          'doctorImage': item.imagePath,
                                          'consultationType':
                                              item.consultationType,
                                          'selectedDate': item.appointmentDate,
                                          'selectedTime': item.appointmentTime,
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                      // Cancelled tab
                      Builder(
                        builder: (context) {
                          final cancelledAppointments =
                              _resolveCancelledAppointments(state);
                          return isLoading && cancelledAppointments.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : cancelledAppointments.isEmpty
                              ? _EmptyAppointmentsView(
                                  onBookNow: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.search,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    8,
                                    0,
                                    0,
                                  ),
                                  child: ListView.separated(
                                    padding: EdgeInsets.only(
                                      top: 8,
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).padding.bottom +
                                          88,
                                    ),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: cancelledAppointments.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = cancelledAppointments[index];
                                      return AppointmentCardWidget(
                                        doctorName: item.doctorName,
                                        specialization: item.specialization,
                                        appointmentDate: item.appointmentDate,
                                        appointmentTime: item.appointmentTime,
                                        imagePath: item.imagePath,
                                        showArrow: false,
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.bookingSummary,
                                            arguments: {
                                              'doctorName': item.doctorName,
                                              'specialization':
                                                  item.specialization,
                                              'clinicName': item.clinicName,
                                              'doctorImage': item.imagePath,
                                              'consultationType':
                                                  item.consultationType,
                                              'selectedDate':
                                                  item.appointmentDate,
                                              'selectedTime':
                                                  item.appointmentTime,
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                        },
                      ),

                      // Completed tab
                      Builder(
                        builder: (context) {
                          final completedAppointments =
                              _resolveCompletedAppointments(state);
                          return isLoading && completedAppointments.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : completedAppointments.isEmpty
                              ? _EmptyAppointmentsView(
                                  onBookNow: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.search,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    8,
                                    0,
                                    0,
                                  ),
                                  child: ListView.separated(
                                    padding: EdgeInsets.only(
                                      top: 8,
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).padding.bottom +
                                          88,
                                    ),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: completedAppointments.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = completedAppointments[index];
                                      return AppointmentCardWidget(
                                        doctorName: item.doctorName,
                                        specialization: item.specialization,
                                        appointmentDate: item.appointmentDate,
                                        appointmentTime: item.appointmentTime,
                                        imagePath: item.imagePath,
                                        showArrow: false,
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.bookingSummary,
                                            arguments: {
                                              'doctorName': item.doctorName,
                                              'specialization':
                                                  item.specialization,
                                              'clinicName': item.clinicName,
                                              'doctorImage': item.imagePath,
                                              'consultationType':
                                                  item.consultationType,
                                              'selectedDate':
                                                  item.appointmentDate,
                                              'selectedTime':
                                                  item.appointmentTime,
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_AppointmentCardData> _resolveUpcomingAppointments(
    AppointmentsState state,
  ) {
    if (state is! GetMyAppointmentsSuccess) {
      return _demoAppointments;
    }

    final filtered = state.response.appointments
        .where(_isUpcomingAppointment)
        .toList();

    if (filtered.isEmpty) {
      return _demoAppointments;
    }

    return filtered
        .asMap()
        .entries
        .map(
          (entry) => _AppointmentCardData.fromModel(
            entry.value,
            fallbackIndex: entry.key,
          ),
        )
        .toList();
  }

  bool _isUpcomingAppointment(AppointmentModel appointment) {
    final status = (appointment.status ?? '').trim().toLowerCase();
    if (status.isEmpty) {
      return true;
    }

    return status.contains('upcoming') ||
        status.contains('scheduled') ||
        status.contains('pending') ||
        status.contains('confirmed') ||
        status.contains('booked') ||
        status.contains('accepted');
  }

  List<_AppointmentCardData> _resolveCancelledAppointments(
    AppointmentsState state,
  ) {
    if (state is! GetMyAppointmentsSuccess) {
      return const [];
    }

    final filtered = state.response.appointments
        .where(_isCancelledAppointment)
        .toList();

    if (filtered.isEmpty) {
      return const [];
    }

    return filtered
        .asMap()
        .entries
        .map(
          (entry) => _AppointmentCardData.fromModel(
            entry.value,
            fallbackIndex: entry.key,
          ),
        )
        .toList();
  }

  bool _isCancelledAppointment(AppointmentModel appointment) {
    final status = (appointment.status ?? '').trim().toLowerCase();
    if (status.isEmpty) return false;
    return status.contains('cancel') || status.contains('canceled');
  }

  List<_AppointmentCardData> _resolveCompletedAppointments(
    AppointmentsState state,
  ) {
    if (state is! GetMyAppointmentsSuccess) {
      return const [];
    }

    final filtered = state.response.appointments
        .where(_isCompletedAppointment)
        .toList();

    if (filtered.isEmpty) {
      return const [];
    }

    return filtered
        .asMap()
        .entries
        .map(
          (entry) => _AppointmentCardData.fromModel(
            entry.value,
            fallbackIndex: entry.key,
          ),
        )
        .toList();
  }

  bool _isCompletedAppointment(AppointmentModel appointment) {
    final status = (appointment.status ?? '').trim().toLowerCase();
    if (status.isEmpty) return false;
    return status.contains('completed') ||
        status.contains('done') ||
        status.contains('attended');
  }

  static const List<_AppointmentCardData> _demoAppointments = [
    _AppointmentCardData(
      doctorName: 'Dr. Mahmoud Abo Leila',
      specialization: 'Dentist',
      clinicName: 'Dar El-Hekma Clinic',
      appointmentDate: 'June 13 2056',
      appointmentTime: '3:30 PM',
      imagePath: AppImages.imagesDoctorDRMahmoudAboLeila,
      consultationType: 'clinic',
    ),
    _AppointmentCardData(
      doctorName: 'Dr. Sara Hassan',
      specialization: 'Cardiologist',
      clinicName: 'Dar El-Hekma Clinic',
      appointmentDate: 'June 14 2056',
      appointmentTime: '5:00 PM',
      imagePath: AppImages.imagesDoctorDRSaraHassan,
      consultationType: 'online',
    ),
  ];
}

class _EmptyAppointmentsView extends StatelessWidget {
  final VoidCallback onBookNow;

  const _EmptyAppointmentsView({required this.onBookNow});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.emptyAppointments,
              width: MediaQuery.of(context).size.width * 0.42,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 28),
            const Text(
              "You don't have an appointment",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "You don't have an appointment scheduled at the moment.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: onBookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCardData {
  final String doctorName;
  final String specialization;
  final String clinicName;
  final String appointmentDate;
  final String appointmentTime;
  final String imagePath;
  final String consultationType;

  const _AppointmentCardData({
    required this.doctorName,
    required this.specialization,
    required this.clinicName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.imagePath,
    required this.consultationType,
  });

  factory _AppointmentCardData.fromModel(
    AppointmentModel model, {
    required int fallbackIndex,
  }) {
    return _AppointmentCardData(
      doctorName: _resolveText(model.doctorName, 'Upcoming appointment'),
      specialization: _resolveText(
        model.type ?? model.clinicName,
        'General appointment',
      ),
      clinicName: _resolveText(model.clinicName, 'Dar El-Hekma Clinic'),
      appointmentDate: _resolveText(model.date, 'Date pending'),
      appointmentTime: _resolveText(model.time, 'Time pending'),
      imagePath: _resolveImagePath(model.doctorName, fallbackIndex),
      consultationType: _resolveText(model.type, 'clinic'),
    );
  }

  static String _resolveText(String? value, String fallback) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String _resolveImagePath(String? doctorName, int fallbackIndex) {
    final normalized = (doctorName ?? '').toLowerCase();
    if (normalized.contains('sara')) {
      return AppImages.imagesDoctorDRSaraHassan;
    }

    if (normalized.contains('mahmoud')) {
      return AppImages.imagesDoctorDRMahmoudAboLeila;
    }

    return fallbackIndex.isEven
        ? AppImages.imagesDoctorDRMahmoudAboLeila
        : AppImages.imagesDoctorDRSaraHassan;
  }
}
