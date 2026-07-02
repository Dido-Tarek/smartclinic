import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/utils/doctor_image_resolver.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/services/bg_remover_service.dart';
import 'package:smartclinic/core/widgets/custom_nav_bar.dart';
import 'package:smartclinic/core/widgets/smart_clinic_loader.dart';
import 'package:smartclinic/features/appointments/data/model/appointment_response_model.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_cubit.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_state.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_response_model.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_cubit.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_state.dart';
import 'package:smartclinic/features/user_management/data/repo/user_management_repo.dart';
import 'package:smartclinic/injection_dependency.dart';

// ─────────────────────────────────────────────────────────────────────────────
// InboxChatRoomsScreen
// ─────────────────────────────────────────────────────────────────────────────
class InboxChatRoomsScreen extends StatefulWidget {
  const InboxChatRoomsScreen({super.key, this.appointments = const []});

  /// Optional pre-loaded appointments. If empty, the screen fetches its own.
  final List<AppointmentModel> appointments;

  @override
  State<InboxChatRoomsScreen> createState() => _InboxChatRoomsScreenState();
}

class _InboxChatRoomsScreenState extends State<InboxChatRoomsScreen> {
  late final AppointmentsCubit _myAppointmentsCubit;
  AppointmentsCubit? _doctorAppointmentsCubit;
  ClinicManagementCubit? _clinicManagementCubit;
  late final UserSession _userSession;

  final List<ClinicModel> _doctorClinics = <ClinicModel>[];
  ClinicModel? _selectedDoctorClinic;
  List<AppointmentModel> _preSeededAppointments = [];

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
    _myAppointmentsCubit = getIt<AppointmentsCubit>();

    if (_userSession.userRole.isDoctor) {
      _doctorAppointmentsCubit = getIt<AppointmentsCubit>();
      _clinicManagementCubit = getIt<ClinicManagementCubit>();
    }

    if (widget.appointments.isNotEmpty) {
      // Filter out cancelled ones even from pre-seeded lists
      _preSeededAppointments = widget.appointments
          .where((a) => !_isCancelled(a.status))
          .toList();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _myAppointmentsCubit.getMyAppointments();
          if (_userSession.userRole.isDoctor) {
            _clinicManagementCubit!.getMyClinics();
          }
        }
      });
    }
  }

  /// Returns true if the appointment's status is any cancellation variant.
  static bool _isCancelled(String? status) {
    final s = (status ?? '').trim().toLowerCase();
    return s.contains('cancel') ||
        s.contains('canceled') ||
        s.contains('cancelled');
  }

  @override
  void dispose() {
    _myAppointmentsCubit.close();
    _doctorAppointmentsCubit?.close();
    _clinicManagementCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userSession.userRole.isDoctor) {
      return _buildDoctorView(context);
    }
    return _buildPatientView(context);
  }

  Widget _buildPatientView(BuildContext context) {
    return BlocProvider.value(
      value: _myAppointmentsCubit,
      child: BlocBuilder<AppointmentsCubit, AppointmentsState>(
        bloc: _myAppointmentsCubit,
        builder: (context, state) {
          final isLoading = state is GetMyAppointmentsLoading;
          final appointments = state is GetMyAppointmentsSuccess
              ? state.response.appointments
                    .where((a) => !_isCancelled(a.status))
                    .toList()
              : _preSeededAppointments;

          return Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            extendBody: true,
            bottomNavigationBar: CustomNavBar(
              selectedIndex: 1,
              userRole: _userSession.userRole,
              onChatbotPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.nouga),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Messages',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Chat is open from your appointment day for 7 days.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: _buildList(
                        appointments,
                        isLoading,
                        isDoctor: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorView(BuildContext context) {
    final clinicCubit = _clinicManagementCubit;
    final doctorCubit = _doctorAppointmentsCubit;

    if (clinicCubit == null || doctorCubit == null) {
      return const Scaffold(body: Center(child: SmartClinicLoader(size: 120)));
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: clinicCubit),
        BlocProvider.value(value: _myAppointmentsCubit),
        BlocProvider.value(value: doctorCubit),
      ],
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
            final selectedId = _selectedDoctorClinic?.id;
            if (selectedId != null) {
              doctorCubit.getDoctorRequests(selectedId);
            }
          }
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            extendBody: true,
            bottomNavigationBar: CustomNavBar(
              selectedIndex: 1,
              userRole: _userSession.userRole,
              onChatbotPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.nouga),
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Text(
                      'Messages',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text(
                      'Chat is open from your appointment day for 7 days.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                        Tab(text: 'My Patients'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Patient tab
                        BlocBuilder<AppointmentsCubit, AppointmentsState>(
                          bloc: _myAppointmentsCubit,
                          builder: (context, state) {
                            final isLoading = state is GetMyAppointmentsLoading;
                            final appointments =
                                state is GetMyAppointmentsSuccess
                                ? state.response.appointments
                                      .where((a) => !_isCancelled(a.status))
                                      .toList()
                                : _preSeededAppointments;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: _buildList(
                                appointments,
                                isLoading,
                                isDoctor: false,
                              ),
                            );
                          },
                        ),
                        // Doctor tab
                        BlocBuilder<AppointmentsCubit, AppointmentsState>(
                          bloc: doctorCubit,
                          builder: (context, state) {
                            final isLoading = state is GetDoctorRequestsLoading;
                            final appointments =
                                state is GetDoctorRequestsSuccess
                                ? state.response.appointments
                                      .where((a) => !_isCancelled(a.status))
                                      .toList()
                                : <AppointmentModel>[];

                            return Column(
                              children: [
                                if (_doctorClinics.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: DropdownButtonFormField<int>(
                                      initialValue: _selectedDoctorClinic?.id,
                                      decoration: InputDecoration(
                                        labelText: 'Clinic schedule',
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.textSecondary
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                      ),
                                      items: _doctorClinics
                                          .where((clinic) => clinic.id != null)
                                          .map(
                                            (clinic) => DropdownMenuItem<int>(
                                              value: clinic.id,
                                              child: Text(
                                                clinic.name ?? 'Clinic',
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (clinicId) {
                                        if (clinicId == null) return;
                                        final selectedClinic = _doctorClinics
                                            .firstWhere(
                                              (clinic) => clinic.id == clinicId,
                                              orElse: () =>
                                                  _selectedDoctorClinic!,
                                            );
                                        setState(() {
                                          _selectedDoctorClinic =
                                              selectedClinic;
                                        });
                                        doctorCubit.getDoctorRequests(clinicId);
                                      },
                                    ),
                                  ),
                                if (_doctorClinics.isEmpty && !isLoading)
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Text(
                                        'No clinic schedule yet',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: _buildList(
                                      appointments,
                                      isLoading,
                                      isDoctor: true,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    List<AppointmentModel> appointments,
    bool isLoading, {
    required bool isDoctor,
  }) {
    if (isLoading && appointments.isEmpty) {
      return const Center(child: SmartClinicLoader(size: 120));
    }
    if (appointments.isEmpty) {
      return const _InboxEmptyState();
    }
    return ListView.separated(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 88,
      ),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return _AppointmentChatTile(
          appointment: appt,
          isDoctor: isDoctor,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.doctorChatRoom,
            arguments: {
              'doctorName': isDoctor ? appt.patientName : appt.doctorName,
              'specialization': null,
              'clinicName': appt.clinicName,
              'doctorImage': appt.doctorImage,
              'consultationType': appt.type,
              'selectedDate': appt.displayDate,
              'selectedTime': appt.displayTime,
              'doctorId': appt.doctorId,
              'patientId': appt.patientId,
              'appointmentDate': appt.date ?? appt.displayDate,
              'patientImageUrl': _userSession.profileImage,
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single chat room tile
// ─────────────────────────────────────────────────────────────────────────────
class _AppointmentChatTile extends StatefulWidget {
  const _AppointmentChatTile({
    required this.appointment,
    required this.onTap,
    this.isDoctor = false,
  });

  final AppointmentModel appointment;
  final VoidCallback onTap;
  final bool isDoctor;

  @override
  State<_AppointmentChatTile> createState() => _AppointmentChatTileState();
}

class _AppointmentChatTileState extends State<_AppointmentChatTile> {
  late final UserSession _userSession;
  Uint8List? _avatarBytes;
  String? _resolvedImageUrl;

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
    _resolvedImageUrl = widget.appointment.doctorImage;
    _prepareAvatar();
  }

  Future<void> _prepareAvatar() async {
    if (widget.isDoctor) {
      final resolved = resolveDoctorImageSource(
        appointmentImage: widget.appointment.doctorImage,
        profileImage: _userSession.profileImage,
      );
      if (resolved != null && resolved.isNotEmpty) {
        _resolvedImageUrl = resolved;
        if (mounted) setState(() {});
        final bytes = await BgRemoverService.instance.processImage(resolved);
        if (mounted) setState(() => _avatarBytes = bytes);
      }
      return;
    }

    final resolved = resolveDoctorImageSource(
      appointmentImage: widget.appointment.doctorImage,
      profileImage: null,
    );

    if (resolved == null || resolved.isEmpty) {
      final doctorId = widget.appointment.doctorId;
      if (doctorId != null && doctorId.isNotEmpty) {
        final result = await getIt<UserManagementRepo>().getProfile(doctorId);
        result.whenOrNull(
          success: (profile) async {
            final profileImg = profile.profileImage;
            if (profileImg != null && profileImg.isNotEmpty) {
              if (mounted) {
                setState(() => _resolvedImageUrl = profileImg);
              }
              final bytes = await BgRemoverService.instance.processImage(
                profileImg,
              );
              if (mounted) setState(() => _avatarBytes = bytes);
            }
          },
        );
      }
      return;
    }

    _resolvedImageUrl = resolved;
    if (mounted) setState(() {});
    final bytes = await BgRemoverService.instance.processImage(resolved);
    if (mounted) setState(() => _avatarBytes = bytes);
  }

  bool get _chatActive {
    final raw = (widget.appointment.date ?? widget.appointment.displayDate)
        .split('T')
        .first
        .trim();
    final apptDate = DateTime.tryParse(raw);
    if (apptDate == null) return false;
    final now = DateTime.now();
    return !now.isBefore(apptDate) &&
        now.isBefore(apptDate.add(const Duration(days: 7)));
  }

  String get _displayDate {
    final raw = widget.appointment.displayDate;
    // Format: 2026-06-30 → "Jun 30, 2026"
    final dt = DateTime.tryParse(raw.split('T').first);
    if (dt == null) return raw;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final appt = widget.appointment;
    final active = _chatActive;
    final imageUrl = resolveDoctorImageSource(
      appointmentImage: _resolvedImageUrl ?? appt.doctorImage,
      profileImage: widget.isDoctor ? _userSession.profileImage : null,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: active
              ? Border.all(
                  color: const Color(0xFF1ABC9C).withValues(alpha: 0.35),
                  width: 1.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.accentBlue,
                  backgroundImage: widget.isDoctor
                      ? const AssetImage(AppImages.imagesIconsDoctor)
                            as ImageProvider
                      : (_avatarBytes != null
                            ? MemoryImage(_avatarBytes!) as ImageProvider
                            : (imageUrl?.startsWith('http') == true)
                            ? NetworkImage(imageUrl!)
                            : const AssetImage(
                                AppImages.imagesDoctorDRMaiElKady,
                              )),
                ),
                if (active)
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isDoctor
                        ? (appt.patientName ?? 'Patient')
                        : (appt.doctorName ?? 'Doctor'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appt.clinicName ?? (appt.type ?? 'Appointment'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Right side — date + badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _displayDate,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 7),
                _ChatStatusBadge(isActive: active),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge
// ─────────────────────────────────────────────────────────────────────────────
class _ChatStatusBadge extends StatelessWidget {
  const _ChatStatusBadge({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF1ABC9C).withValues(alpha: 0.12)
            : AppColors.textSecondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.chat_bubble_rounded : Icons.lock_rounded,
            size: 10,
            color: isActive ? const Color(0xFF1ABC9C) : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Open' : 'Locked',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isActive
                  ? const Color(0xFF1ABC9C)
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _InboxEmptyState extends StatelessWidget {
  const _InboxEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppImages.emptyInbox,
              width: MediaQuery.of(context).size.width * 0.58,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 18),
            const Text(
              'No messages yet\nBook an appointment to chat with your doctor',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
