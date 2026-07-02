import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/utils/doctor_image_resolver.dart';
import 'package:smartclinic/core/widgets/appointment_card_widget.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/custom_nav_bar.dart';
import 'package:smartclinic/features/appointments/data/model/appointment_response_model.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_cubit.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_state.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_response_model.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_cubit.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_state.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/user_management/data/repo/user_management_repo.dart';
import 'package:smartclinic/injection_dependency.dart';

class AppointmentsScreen extends StatefulWidget {
  final int initialIndex;

  const AppointmentsScreen({super.key, this.initialIndex = 0});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late final UserSession _userSession;
  late final AppointmentsCubit _myAppointmentsCubit;
  AppointmentsCubit? _doctorAppointmentsCubit;
  ClinicManagementCubit? _clinicManagementCubit;
  final List<ClinicModel> _doctorClinics = <ClinicModel>[];
  ClinicModel? _selectedDoctorClinic;
  final Map<String, String?> _doctorPhotoCache = {};

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
    _myAppointmentsCubit = context.read<AppointmentsCubit>();
    if (_userSession.userRole.isDoctor) {
      _doctorAppointmentsCubit = getIt<AppointmentsCubit>();
      _clinicManagementCubit = getIt<ClinicManagementCubit>();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _myAppointmentsCubit.getMyAppointments();
      if (_userSession.userRole.isDoctor) {
        _clinicManagementCubit!.getMyClinics();
      }
    });
  }

  @override
  void dispose() {
    _doctorAppointmentsCubit?.close();
    _clinicManagementCubit?.close();
    super.dispose();
  }

  Future<void> _fetchDoctorPhoto(String doctorId) async {
    if (_doctorPhotoCache.containsKey(doctorId)) return;
    _doctorPhotoCache[doctorId] = null; // mark in-flight
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

  @override
  Widget build(BuildContext context) {
    if (_userSession.userRole.isDoctor) {
      return _buildDoctorView(context);
    }

    return BlocConsumer<AppointmentsCubit, AppointmentsState>(
      listener: (context, state) {
        if (state is GetMyAppointmentsSuccess) {
          _prefetchDoctorPhotos(state.response.appointments);
        }
        if (state is GetMyAppointmentsFailure) {
          CherryToast.error(
            title: const Text('Error'),
            description: Text(state.errorMessage),
          ).show(context);
        }
        if (state is CancelAppointmentSuccess) {
          CherryToast.success(
            title: const Text('Appointment cancelled'),
            description: Text(
              state.response.message ?? 'Your appointment has been cancelled.',
            ),
          ).show(context);
          _myAppointmentsCubit.getMyAppointments();
        }
        if (state is CancelAppointmentFailure) {
          CherryToast.error(
            title: const Text('Cancellation failed'),
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
                                  final resolvedPhoto =
                                      resolveDoctorImageSource(
                                        appointmentImage:
                                            _doctorPhotoCache[item.doctorId] ??
                                            item.imageUrl,
                                        profileImage: null,
                                      );
                                  return AppointmentCardWidget(
                                    doctorName: item.doctorName,
                                    specialization: item.specialization,
                                    appointmentDate: item.appointmentDate,
                                    appointmentTime: item.appointmentTime,
                                    imagePath: item.imagePath,
                                    imageUrl: resolvedPhoto,
                                    showArrow: false,
                                    onCancel: () => _showCancelDialog(
                                      context,
                                      item.appointmentId,
                                    ),
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.bookingConfirmation,
                                      arguments: _buildConfirmationArgs(
                                        item,
                                        resolvedPhoto: resolvedPhoto,
                                      ),
                                    ),
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
                                      final resolvedPhoto =
                                          resolveDoctorImageSource(
                                            appointmentImage:
                                                _doctorPhotoCache[item
                                                    .doctorId] ??
                                                item.imageUrl,
                                            profileImage: null,
                                          );
                                      return AppointmentCardWidget(
                                        doctorName: item.doctorName,
                                        specialization: item.specialization,
                                        appointmentDate: item.appointmentDate,
                                        appointmentTime: item.appointmentTime,
                                        imagePath: item.imagePath,
                                        imageUrl: resolvedPhoto,
                                        showArrow: false,
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          AppRoutes.bookingConfirmation,
                                          arguments: _buildConfirmationArgs(
                                            item,
                                            resolvedPhoto: resolvedPhoto,
                                          ),
                                        ),
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
                                      final resolvedPhoto =
                                          resolveDoctorImageSource(
                                            appointmentImage:
                                                _doctorPhotoCache[item
                                                    .doctorId] ??
                                                item.imageUrl,
                                            profileImage: null,
                                          );
                                      return AppointmentCardWidget(
                                        doctorName: item.doctorName,
                                        specialization: item.specialization,
                                        appointmentDate: item.appointmentDate,
                                        appointmentTime: item.appointmentTime,
                                        imagePath: item.imagePath,
                                        imageUrl: resolvedPhoto,
                                        showArrow: false,
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          AppRoutes.bookingConfirmation,
                                          arguments: _buildConfirmationArgs(
                                            item,
                                            resolvedPhoto: resolvedPhoto,
                                          ),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDoctorView(BuildContext context) {
    final clinicCubit = _clinicManagementCubit;
    final doctorCubit = _doctorAppointmentsCubit;

    if (clinicCubit == null || doctorCubit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: clinicCubit,
      child: BlocListener<ClinicManagementCubit, ClinicManagementState>(
        listener: (context, state) {
          if (state is GetMyClinicsSuccess) {
            setState(() {
              _doctorClinics
                ..clear()
                ..addAll(state.response.clinics);
              _selectedDoctorClinic ??= _doctorClinics.isNotEmpty
                  ? _doctorClinics.first
                  : null;
            });

            final selectedClinic = _selectedDoctorClinic;
            final selectedId = selectedClinic?.id;
            if (selectedId != null) {
              doctorCubit.getDoctorRequests(selectedId);
            }
          } else if (state is GetMyClinicsFailure) {
            CherryToast.error(
              title: const Text('Error'),
              description: Text(state.errorMessage),
            ).show(context);
          }
        },
        child: BlocConsumer<AppointmentsCubit, AppointmentsState>(
          bloc: _myAppointmentsCubit,
          listener: (context, state) {
            if (state is GetMyAppointmentsFailure) {
              CherryToast.error(
                title: const Text('Error'),
                description: Text(state.errorMessage),
              ).show(context);
            }
          },
          builder: (context, patientState) {
            return DefaultTabController(
              initialIndex: widget.initialIndex,
              length: 2,
              child: Scaffold(
                backgroundColor: AppColors.scaffoldBg,
                appBar: CustomAppBar(
                  title: 'Appointments',
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
                          Tab(text: 'My Consultations'),
                          Tab(text: 'My Clinic Schedule'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildAppointmentsSourceBody(
                            context,
                            patientState,
                            onEmptyAction: () =>
                                Navigator.pushNamed(context, AppRoutes.search),
                          ),
                          BlocConsumer<AppointmentsCubit, AppointmentsState>(
                            bloc: doctorCubit,
                            listener: (context, state) {
                              if (state is GetDoctorRequestsFailure) {
                                CherryToast.error(
                                  title: const Text('Error'),
                                  description: Text(state.errorMessage),
                                ).show(context);
                              }
                            },
                            builder: (context, doctorState) {
                              return _buildDoctorScheduleTab(
                                context,
                                doctorState,
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
        ),
      ),
    );
  }

  Widget _buildAppointmentsSourceBody(
    BuildContext context,
    AppointmentsState state, {
    required VoidCallback onEmptyAction,
  }) {
    final upcomingAppointments = _resolveUpcomingAppointments(state);
    final isLoading =
        state is GetMyAppointmentsLoading || state is GetDoctorRequestsLoading;

    // Proactively prefetch photos for any appointments whose doctorId we have
    // but whose image hasn't been resolved yet.
    _prefetchDoctorPhotos(
      state is GetMyAppointmentsSuccess
          ? state.response.appointments
          : state is GetDoctorRequestsSuccess
          ? state.response.appointments
          : const [],
    );

    return DefaultTabController(
      length: 3,
      child: Column(
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
                    ? _EmptyAppointmentsView(onBookNow: onEmptyAction)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: ListView.separated(
                          padding: EdgeInsets.only(
                            top: 8,
                            bottom: MediaQuery.of(context).padding.bottom + 88,
                          ),
                          physics: const BouncingScrollPhysics(),
                          itemCount: upcomingAppointments.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = upcomingAppointments[index];
                            final resolvedPhoto = resolveDoctorImageSource(
                              appointmentImage:
                                  _doctorPhotoCache[item.doctorId] ??
                                  item.imageUrl,
                              profileImage: null,
                            );
                            return AppointmentCardWidget(
                              doctorName: item.doctorName,
                              specialization: item.specialization,
                              appointmentDate: item.appointmentDate,
                              appointmentTime: item.appointmentTime,
                              imagePath: item.imagePath,
                              imageUrl: resolvedPhoto,
                              showArrow: false,
                              rawAppointmentDate: item.rawDate,
                              onCancel: () => _showCancelDialog(
                                context,
                                item.appointmentId,
                              ),
                              onChat: () => Navigator.pushNamed(
                                context,
                                AppRoutes.doctorChatRoom,
                                arguments: _buildChatArgs(
                                  item,
                                  resolvedPhoto: resolvedPhoto,
                                ),
                              ),
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.bookingConfirmation,
                                arguments: _buildConfirmationArgs(
                                  item,
                                  resolvedPhoto: resolvedPhoto,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                Builder(
                  builder: (context) {
                    final cancelledAppointments = _resolveCancelledAppointments(
                      state,
                    );
                    return isLoading && cancelledAppointments.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : cancelledAppointments.isEmpty
                        ? _EmptyAppointmentsView(onBookNow: onEmptyAction)
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: ListView.separated(
                              padding: EdgeInsets.only(
                                top: 8,
                                bottom:
                                    MediaQuery.of(context).padding.bottom + 88,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: cancelledAppointments.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = cancelledAppointments[index];
                                final resolvedPhoto = resolveDoctorImageSource(
                                  appointmentImage:
                                      _doctorPhotoCache[item.doctorId] ??
                                      item.imageUrl,
                                  profileImage: null,
                                );
                                return AppointmentCardWidget(
                                  doctorName: item.doctorName,
                                  specialization: item.specialization,
                                  appointmentDate: item.appointmentDate,
                                  appointmentTime: item.appointmentTime,
                                  imagePath: item.imagePath,
                                  imageUrl: resolvedPhoto,
                                  showArrow: false,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.bookingConfirmation,
                                    arguments: _buildConfirmationArgs(
                                      item,
                                      resolvedPhoto: resolvedPhoto,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                  },
                ),
                Builder(
                  builder: (context) {
                    final completedAppointments = _resolveCompletedAppointments(
                      state,
                    );
                    return isLoading && completedAppointments.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : completedAppointments.isEmpty
                        ? _EmptyAppointmentsView(onBookNow: onEmptyAction)
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: ListView.separated(
                              padding: EdgeInsets.only(
                                top: 8,
                                bottom:
                                    MediaQuery.of(context).padding.bottom + 88,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: completedAppointments.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = completedAppointments[index];
                                final resolvedPhoto = resolveDoctorImageSource(
                                  appointmentImage:
                                      _doctorPhotoCache[item.doctorId] ??
                                      item.imageUrl,
                                  profileImage: null,
                                );
                                return AppointmentCardWidget(
                                  doctorName: item.doctorName,
                                  specialization: item.specialization,
                                  appointmentDate: item.appointmentDate,
                                  appointmentTime: item.appointmentTime,
                                  imagePath: item.imagePath,
                                  imageUrl: resolvedPhoto,
                                  showArrow: false,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.bookingConfirmation,
                                    arguments: _buildConfirmationArgs(
                                      item,
                                      resolvedPhoto: resolvedPhoto,
                                    ),
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
        ],
      ),
    );
  }

  Widget _buildDoctorScheduleTab(
    BuildContext context,
    AppointmentsState state,
  ) {
    if (_doctorClinics.isEmpty) {
      return _EmptyAppointmentsView(
        title: 'No clinic schedule yet',
        subtitle: 'Select or create a clinic to start managing appointments.',
        showActionButton: false,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedDoctorClinic?.id,
            decoration: InputDecoration(
              labelText: 'Clinic schedule',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.textSecondary.withValues(alpha: 0.2),
                ),
              ),
            ),
            items: _doctorClinics
                .where((clinic) => clinic.id != null)
                .map(
                  (clinic) => DropdownMenuItem<int>(
                    value: clinic.id,
                    child: Text(clinic.name ?? 'Clinic'),
                  ),
                )
                .toList(),
            onChanged: (clinicId) {
              if (clinicId == null) {
                return;
              }
              final selectedClinic = _doctorClinics.firstWhere(
                (clinic) => clinic.id == clinicId,
                orElse: () => _selectedDoctorClinic!,
              );
              setState(() {
                _selectedDoctorClinic = selectedClinic;
              });
              _doctorAppointmentsCubit?.getDoctorRequests(clinicId);
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _buildAppointmentsSourceBody(
            context,
            state,
            onEmptyAction: () =>
                Navigator.pushNamed(context, AppRoutes.clinicManagement),
          ),
        ),
      ],
    );
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    int? appointmentId,
  ) async {
    if (appointmentId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Appointment',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Keep it',
              style: TextStyle(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancel Appointment',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _myAppointmentsCubit.cancelMyAppointment(appointmentId);
    }
  }

  List<_AppointmentCardData> _resolveUpcomingAppointments(
    AppointmentsState state,
  ) {
    final List<AppointmentModel> appointments;
    if (state is GetMyAppointmentsSuccess) {
      appointments = state.response.appointments;
    } else if (state is GetDoctorRequestsSuccess) {
      appointments = state.response.appointments;
    } else {
      return const [];
    }

    return appointments
        .where(_isUpcomingAppointment)
        .toList()
        .asMap()
        .entries
        .map(
          (e) => _AppointmentCardData.fromModel(e.value, fallbackIndex: e.key),
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
    final List<AppointmentModel> appointments;
    if (state is GetMyAppointmentsSuccess) {
      appointments = state.response.appointments;
    } else if (state is GetDoctorRequestsSuccess) {
      appointments = state.response.appointments;
    } else {
      return const [];
    }

    final filtered = appointments.where(_isCancelledAppointment).toList();
    if (filtered.isEmpty) return const [];

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
    final List<AppointmentModel> appointments;
    if (state is GetMyAppointmentsSuccess) {
      appointments = state.response.appointments;
    } else if (state is GetDoctorRequestsSuccess) {
      appointments = state.response.appointments;
    } else {
      return const [];
    }

    final filtered = appointments.where(_isCompletedAppointment).toList();
    if (filtered.isEmpty) return const [];

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

  Map<String, dynamic> _buildConfirmationArgs(
    _AppointmentCardData item, {
    String? resolvedPhoto,
  }) {
    final patientName = item.patientName?.trim().isNotEmpty == true
        ? item.patientName
        : _userSession.fullName;
    return {
      if (item.appointmentId != null) 'appointmentId': item.appointmentId,
      'doctorName': item.doctorName,
      'specialization': item.specialization,
      'clinicName': item.clinicName,
      'doctorImage': resolvedPhoto ?? item.imageUrl ?? item.imagePath,
      'consultationType': item.consultationType,
      'selectedDate': item.appointmentDate,
      'selectedTime': item.appointmentTime,
      if (patientName != null) 'patientName': patientName,
      if (item.paymentMethod != null) 'paymentMethod': item.paymentMethod,
      if (item.consultationFee != null) 'consultationFee': item.consultationFee,
      if (item.meetingLink != null) 'meetingLink': item.meetingLink,
    };
  }

  Map<String, dynamic> _buildChatArgs(
    _AppointmentCardData item, {
    String? resolvedPhoto,
  }) {
    return {
      'doctorName': item.doctorName,
      'specialization': item.specialization,
      'clinicName': item.clinicName,
      'doctorImage': resolvedPhoto ?? item.imageUrl ?? item.imagePath,
      'consultationType': item.consultationType,
      'selectedDate': item.appointmentDate,
      'selectedTime': item.appointmentTime,
      'doctorId': item.doctorId,
      'patientId': _userSession.patientId,
      'appointmentDate': item.rawDate ?? item.appointmentDate,
      'patientImageUrl': _userSession.profileImage,
    };
  }
}

class _EmptyAppointmentsView extends StatelessWidget {
  final VoidCallback onBookNow;
  final String title;
  final String subtitle;
  final bool showActionButton;

  const _EmptyAppointmentsView({
    this.onBookNow = _noop,
    this.title = "You don't have an appointment",
    this.subtitle = "You don't have an appointment scheduled at the moment.",
    this.showActionButton = true,
  });

  static void _noop() {}

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
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showActionButton) ...[
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
          ],
        ),
      ),
    );
  }
}

class _AppointmentCardData {
  final int? appointmentId;
  final String? doctorId;
  final String doctorName;
  final String specialization;
  final String clinicName;
  final String appointmentDate;
  final String appointmentTime;
  final String imagePath;
  final String? imageUrl;
  final String consultationType;
  final String? patientName;
  final String? paymentMethod;
  final String? meetingLink;
  final double? consultationFee;
  final String? rawDate; // raw ISO date from API (for chat window calc)

  const _AppointmentCardData({
    this.appointmentId,
    this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.clinicName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.imagePath,
    this.imageUrl,
    required this.consultationType,
    this.patientName,
    this.paymentMethod,
    this.meetingLink,
    this.consultationFee,
    this.rawDate,
  });

  factory _AppointmentCardData.fromModel(
    AppointmentModel model, {
    required int fallbackIndex,
  }) {
    // For doctor-schedule appointments the API returns patientName but no
    // doctorName, so fall back to patientName as the card's primary label.
    final cardName = _resolveText(
      model.doctorName?.isNotEmpty == true
          ? model.doctorName
          : model.patientName,
      'Appointment',
    );
    return _AppointmentCardData(
      appointmentId: model.id,
      doctorId: model.doctorId,
      doctorName: cardName,
      specialization: _resolveText(
        model.type ?? model.clinicName,
        'General appointment',
      ),
      clinicName: _resolveText(model.clinicName, 'Dar El-Hekma Clinic'),
      appointmentDate: model.displayDate,
      appointmentTime: model.displayTime,
      imagePath: _resolveFallbackImage(fallbackIndex),
      imageUrl: model.doctorImage,
      consultationType: _resolveText(model.type, 'InClinic'),
      patientName: model.patientName,
      paymentMethod: model.payFromWallet == true ? 'wallet' : 'cash',
      meetingLink: model.meetingLink,
      consultationFee: model.consultationFee,
      rawDate: model.date,
    );
  }

  static String _resolveText(String? value, String fallback) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String _resolveFallbackImage(int fallbackIndex) {
    return AppImages.imagesIconsDoctor;
  }
}
