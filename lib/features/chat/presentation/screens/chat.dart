import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/services/bg_remover_service.dart';
import 'package:smartclinic/core/widgets/custom_nav_bar.dart';
import 'package:smartclinic/core/widgets/smart_clinic_loader.dart';
import 'package:smartclinic/features/appointments/data/model/appointment_response_model.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_cubit.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_state.dart';
import 'package:smartclinic/injection_dependency.dart';

// ─────────────────────────────────────────────────────────────────────────────
// InboxChatRoomsScreen
// Self-contained — loads appointments via AppointmentsCubit.
// Can also be pre-seeded with an appointments list (for direct nav).
// ─────────────────────────────────────────────────────────────────────────────
class InboxChatRoomsScreen extends StatefulWidget {
  const InboxChatRoomsScreen({
    super.key,
    this.appointments = const [],
  });

  /// Optional pre-loaded appointments. If empty, the screen fetches its own.
  final List<AppointmentModel> appointments;

  @override
  State<InboxChatRoomsScreen> createState() => _InboxChatRoomsScreenState();
}

class _InboxChatRoomsScreenState extends State<InboxChatRoomsScreen> {
  late final AppointmentsCubit _cubit;
  late final UserSession _userSession;
  List<AppointmentModel> _appointments = [];

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
    _cubit = getIt<AppointmentsCubit>();

    if (widget.appointments.isNotEmpty) {
      _appointments = widget.appointments;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cubit.getMyAppointments();
      });
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<AppointmentsCubit, AppointmentsState>(
        bloc: _cubit,
        listener: (context, state) {
          if (state is GetMyAppointmentsSuccess) {
            setState(() => _appointments = state.response.appointments);
          }
        },
        builder: (context, state) {
          final isLoading = state is GetMyAppointmentsLoading;

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
                child: isLoading && _appointments.isEmpty
                    ? const Center(child: SmartClinicLoader(size: 120))
                    : _appointments.isEmpty
                        ? const _InboxEmptyState()
                        : Column(
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
                              Text(
                                'Chat is open from your appointment day for 7 days.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: _appointments.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (context, index) {
                                    final appt = _appointments[index];
                                    return _AppointmentChatTile(
                                      appointment: appt,
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.doctorChatRoom,
                                        arguments: {
                                          'doctorName': appt.doctorName,
                                          'specialization': null,
                                          'clinicName': appt.clinicName,
                                          'doctorImage': appt.doctorImage,
                                          'consultationType': appt.type,
                                          'selectedDate': appt.displayDate,
                                          'selectedTime': appt.displayTime,
                                          'doctorId': appt.doctorId,
                                          'patientId': appt.patientId,
                                          'appointmentDate': appt.date ??
                                              appt.displayDate,
                                          'patientImageUrl':
                                              _userSession.profileImage,
                                        },
                                      ),
                                    );
                                  },
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Single chat room tile
// ─────────────────────────────────────────────────────────────────────────────
class _AppointmentChatTile extends StatefulWidget {
  const _AppointmentChatTile({
    required this.appointment,
    required this.onTap,
  });

  final AppointmentModel appointment;
  final VoidCallback onTap;

  @override
  State<_AppointmentChatTile> createState() => _AppointmentChatTileState();
}

class _AppointmentChatTileState extends State<_AppointmentChatTile> {
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _prepareAvatar();
  }

  Future<void> _prepareAvatar() async {
    final img = widget.appointment.doctorImage;
    if (img == null || img.isEmpty) return;
    final bytes = await BgRemoverService.instance.processImage(img);
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final appt = widget.appointment;
    final active = _chatActive;

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
                  backgroundImage: _avatarBytes != null
                      ? MemoryImage(_avatarBytes!) as ImageProvider
                      : (appt.doctorImage?.startsWith('http') == true)
                          ? NetworkImage(appt.doctorImage!)
                          : AssetImage(AppImages.imagesDoctorDRMaiElKady),
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
                    appt.doctorName ?? 'Doctor',
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
                    appt.clinicName ??
                        (appt.type ?? 'Appointment'),
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
            color: isActive
                ? const Color(0xFF1ABC9C)
                : AppColors.textSecondary,
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

// ─────────────────────────────────────────────────────────────────────────────
// Legacy ChatRoomItem kept for backward compatibility
// ─────────────────────────────────────────────────────────────────────────────
class ChatRoomItem {
  const ChatRoomItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarPath,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  final String name;
  final String lastMessage;
  final String time;
  final String avatarPath;
  final int unreadCount;
  final bool isOnline;
}
