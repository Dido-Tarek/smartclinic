import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/services/bg_remover_service.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/smart_clinic_loader.dart';
import 'package:smartclinic/features/chat/data/model/chat_model.dart';
import 'package:smartclinic/features/chat/presentation/manager/chat_cubit.dart';
import 'package:smartclinic/features/chat/presentation/manager/chat_state.dart';
import 'package:smartclinic/injection_dependency.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper: is the chat window open?
// Window = from appointmentDate until appointmentDate + 7 days (exclusive)
// ─────────────────────────────────────────────────────────────────────────────
class _ChatWindow {
  const _ChatWindow._();

  static bool isActive(String? appointmentDateStr) {
    if (appointmentDateStr == null || appointmentDateStr.isEmpty) return false;
    // accept both "2026-06-30" and "2026-06-30T10:00:00"
    final raw = appointmentDateStr.split('T').first.trim();
    final apptDate = DateTime.tryParse(raw);
    if (apptDate == null) return false;
    final now = DateTime.now();
    final windowEnd = apptDate.add(const Duration(days: 7));
    return !now.isBefore(apptDate) && now.isBefore(windowEnd);
  }

  static bool isExpired(String? appointmentDateStr) {
    if (appointmentDateStr == null || appointmentDateStr.isEmpty) return false;
    final raw = appointmentDateStr.split('T').first.trim();
    final apptDate = DateTime.tryParse(raw);
    if (apptDate == null) return false;
    return DateTime.now().isAfter(apptDate.add(const Duration(days: 7)));
  }

  static bool isBeforeStart(String? appointmentDateStr) {
    if (appointmentDateStr == null || appointmentDateStr.isEmpty) return false;
    final raw = appointmentDateStr.split('T').first.trim();
    final apptDate = DateTime.tryParse(raw);
    if (apptDate == null) return false;
    return DateTime.now().isBefore(apptDate);
  }

  /// How many days remain in the chat window (0 = last day, negative = expired)
  static int daysRemaining(String? appointmentDateStr) {
    if (appointmentDateStr == null || appointmentDateStr.isEmpty) return -1;
    final raw = appointmentDateStr.split('T').first.trim();
    final apptDate = DateTime.tryParse(raw);
    if (apptDate == null) return -1;
    final windowEnd = apptDate.add(const Duration(days: 7));
    return windowEnd.difference(DateTime.now()).inDays;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DoctorChatRoomScreen
// ─────────────────────────────────────────────────────────────────────────────
class DoctorChatRoomScreen extends StatefulWidget {
  const DoctorChatRoomScreen({
    super.key,
    this.doctorName,
    this.specialization,
    this.clinicName,
    this.doctorImagePath,
    this.consultationType,
    this.selectedDate,
    this.selectedTime,
    // new fields for real API integration
    this.doctorId,
    this.patientId,
    this.appointmentDate,
    this.patientImageUrl,
  });

  final String? doctorName;
  final String? specialization;
  final String? clinicName;
  final String? doctorImagePath;
  final String? consultationType;
  final String? selectedDate;
  final String? selectedTime;
  final String? doctorId;
  final String? patientId;
  final String? appointmentDate; // ISO date string "2026-06-30"
  final String? patientImageUrl;

  @override
  State<DoctorChatRoomScreen> createState() => _DoctorChatRoomScreenState();
}

class _DoctorChatRoomScreenState extends State<DoctorChatRoomScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late final ChatCubit _chatCubit;
  late final UserSession _userSession;

  /// Local optimistic message list (real history replaces on load)
  final List<_UiMessage> _uiMessages = [];
  bool _historyLoaded = false;
  bool _isSending = false;

  // bg-removed avatar bytes
  Uint8List? _doctorAvatarBytes;
  Uint8List? _patientAvatarBytes;

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
    _chatCubit = getIt<ChatCubit>();
    _loadChatHistory();
    _prepareAvatars();

    // Mark as seen
    final otherId = _otherUserId;
    if (otherId != null && otherId.isNotEmpty) {
      _chatCubit.emitMarkChatAsSeen(otherId);
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _chatCubit.close();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String get _doctorName => widget.doctorName ?? 'Dr. Mai El Kady';
  String get _specialization => widget.specialization ?? 'Specialist';
  String get _clinicName => widget.clinicName ?? '';
  String get _doctorImageAsset =>
      widget.doctorImagePath ?? AppImages.imagesDoctorDRMaiElKady;
  bool get _isPatient => _userSession.userRole.isPatient;

  /// The other party's userId (doctor ID when I'm a patient, patient ID when I'm a doctor)
  String? get _otherUserId =>
      _isPatient ? widget.doctorId : widget.patientId;

  /// The effective date to use for the chat window check
  String? get _chatWindowDate =>
      widget.appointmentDate ?? widget.selectedDate;

  bool get _chatActive => _ChatWindow.isActive(_chatWindowDate);
  bool get _chatExpired => _ChatWindow.isExpired(_chatWindowDate);
  bool get _chatBeforeStart => _ChatWindow.isBeforeStart(_chatWindowDate);
  int get _daysRemaining => _ChatWindow.daysRemaining(_chatWindowDate);

  // ── Data loading ─────────────────────────────────────────────────────────

  Future<void> _loadChatHistory() async {
    final otherId = _otherUserId;
    if (otherId == null || otherId.isEmpty) return;
    await _chatCubit.emitGetChatHistory(otherId);
  }

  Future<void> _prepareAvatars() async {
    // Doctor avatar
    final docImg = widget.doctorImagePath;
    if (docImg != null && docImg.trim().isNotEmpty) {
      final bytes = await BgRemoverService.instance.processImage(docImg.trim());
      if (mounted) setState(() => _doctorAvatarBytes = bytes);
    }
    // Patient avatar (current user)
    final patImg = widget.patientImageUrl ?? _userSession.profileImage;
    if (patImg != null && patImg.trim().isNotEmpty) {
      final bytes = await BgRemoverService.instance.processImage(patImg.trim());
      if (mounted) setState(() => _patientAvatarBytes = bytes);
    }
  }

  // ── Send ─────────────────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    final otherId = _otherUserId;
    if (otherId == null || otherId.isEmpty) {
      _showSnack('Cannot send: recipient ID unavailable');
      return;
    }

    setState(() {
      _isSending = true;
      _uiMessages.add(
        _UiMessage(
          text: text,
          isMe: true,
          time: TimeOfDay.now().format(context),
          isSending: true,
        ),
      );
    });
    _inputCtrl.clear();
    _scrollToBottom();

    await _chatCubit.emitSendMessage(receiverId: otherId, message: text);

    if (mounted) {
      setState(() {
        _isSending = false;
        // mark last optimistic message as sent
        if (_uiMessages.isNotEmpty && _uiMessages.last.isSending) {
          final last = _uiMessages.removeLast();
          _uiMessages.add(last.copyWith(isSending: false));
        }
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatCubit,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: CustomAppBar(title: _doctorName, showNotification: false),
        body: SafeArea(
          child: Column(
            children: [
              _DoctorInfoCard(
                doctorName: _doctorName,
                specialization: _specialization,
                clinicName: _clinicName,
                doctorImageAsset: _doctorImageAsset,
                doctorAvatarBytes: _doctorAvatarBytes,
              ),
              _ChatWindowBanner(
                chatActive: _chatActive,
                chatExpired: _chatExpired,
                chatBeforeStart: _chatBeforeStart,
                daysRemaining: _daysRemaining,
                appointmentDate: _chatWindowDate,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocConsumer<ChatCubit, ChatState>(
                  bloc: _chatCubit,
                  listener: (context, state) {
                    state.whenOrNull(
                      historyLoaded: (messages) {
                        setState(() {
                          _historyLoaded = true;
                          _uiMessages
                            ..clear()
                            ..addAll(
                              messages.map(
                                (m) => _UiMessage.fromModel(
                                  m,
                                  myId: _userSession.userId ?? '',
                                ),
                              ),
                            );
                        });
                        _scrollToBottom();
                      },
                      error: (msg) {
                        if (!_historyLoaded) {
                          setState(() => _historyLoaded = true);
                        }
                        _showSnack(msg);
                      },
                    );
                  },
                  builder: (context, state) {
                    final isLoading = state.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    );
                    if (!_historyLoaded && isLoading) {
                      return const Center(child: SmartClinicLoader(size: 100));
                    }
                    if (_uiMessages.isEmpty) {
                      return _EmptyChat(isActive: _chatActive);
                    }
                    return RefreshIndicator(
                      onRefresh: _loadChatHistory,
                      child: ListView.separated(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: _uiMessages.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final msg = _uiMessages[i];
                          return _MessageBubble(
                            message: msg,
                            doctorAvatarBytes: _doctorAvatarBytes,
                            doctorImageAsset: _doctorImageAsset,
                            patientAvatarBytes: _patientAvatarBytes,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              _MessageInput(
                controller: _inputCtrl,
                enabled: _chatActive,
                isSending: _isSending,
                onSend: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _DoctorInfoCard extends StatelessWidget {
  const _DoctorInfoCard({
    required this.doctorName,
    required this.specialization,
    required this.clinicName,
    required this.doctorImageAsset,
    this.doctorAvatarBytes,
  });

  final String doctorName;
  final String specialization;
  final String clinicName;
  final String doctorImageAsset;
  final Uint8List? doctorAvatarBytes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                  backgroundImage: doctorAvatarBytes != null
                      ? MemoryImage(doctorAvatarBytes!) as ImageProvider
                      : AssetImage(doctorImageAsset),
                ),
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    clinicName.isEmpty
                        ? specialization
                        : '$specialization | $clinicName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatWindowBanner extends StatelessWidget {
  const _ChatWindowBanner({
    required this.chatActive,
    required this.chatExpired,
    required this.chatBeforeStart,
    required this.daysRemaining,
    this.appointmentDate,
  });

  final bool chatActive;
  final bool chatExpired;
  final bool chatBeforeStart;
  final int daysRemaining;
  final String? appointmentDate;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final String text;
    final IconData icon;

    if (chatActive) {
      bgColor = AppColors.skyBlue.withValues(alpha: 0.10);
      textColor = AppColors.skyBlue;
      icon = Icons.chat_bubble_outline_rounded;
      text = daysRemaining == 0
          ? 'Chat closes today — last chance to message your doctor.'
          : 'Chat open — $daysRemaining day${daysRemaining == 1 ? '' : 's'} remaining.';
    } else if (chatBeforeStart) {
      bgColor = const Color(0xFFFFF3CD);
      textColor = const Color(0xFF856404);
      icon = Icons.lock_clock_rounded;
      final dateStr = appointmentDate?.split('T').first ?? 'your appointment date';
      text = 'Chat unlocks on $dateStr (appointment day).';
    } else {
      // expired
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      icon = Icons.lock_rounded;
      text = 'The 7-day chat window for this appointment has ended.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.enabled,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                decoration: InputDecoration(
                  hintText: enabled
                      ? 'Write a message...'
                      : 'Chat is currently locked',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary
                        .withValues(alpha: enabled ? 1.0 : 0.5),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundColor: enabled
                  ? AppColors.deepNavy
                  : AppColors.deepNavy.withValues(alpha: 0.3),
              child: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: enabled ? onSend : null,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive
                  ? Icons.chat_bubble_outline_rounded
                  : Icons.lock_outline_rounded,
              size: 56,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              isActive
                  ? 'No messages yet\nSay hello to your doctor!'
                  : 'No messages in this conversation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    this.doctorAvatarBytes,
    required this.doctorImageAsset,
    this.patientAvatarBytes,
  });

  final _UiMessage message;
  final Uint8List? doctorAvatarBytes;
  final String doctorImageAsset;
  final Uint8List? patientAvatarBytes;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Row(
      mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          _MiniAvatar(
            bytes: doctorAvatarBytes,
            assetPath: doctorImageAsset,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.70,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isMe ? AppColors.deepNavy : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : AppColors.deepNavy,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.time,
                      style: TextStyle(
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.70)
                            : AppColors.textSecondary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isSending
                            ? Icons.access_time_rounded
                            : Icons.done_all_rounded,
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.70),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 8),
          _MiniAvatar(
            bytes: patientAvatarBytes,
            assetPath: AppImages.imagesDoctorDRMaiElKady, // fallback
            isPatient: true,
          ),
        ],
      ],
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({
    this.bytes,
    required this.assetPath,
    this.isPatient = false,
  });
  final Uint8List? bytes;
  final String assetPath;
  final bool isPatient;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: AppColors.accentBlue,
      backgroundImage: bytes != null
          ? MemoryImage(bytes!) as ImageProvider
          : AssetImage(assetPath),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Local UI model (merges API MessageModel + optimistic messages)
// ─────────────────────────────────────────────────────────────────────────────
class _UiMessage {
  const _UiMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.isSending = false,
  });

  factory _UiMessage.fromModel(MessageModel m, {required String myId}) {
    final dt = DateTime.tryParse(m.timestamp);
    final timeStr = dt != null
        ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : m.timestamp;
    return _UiMessage(
      text: m.message,
      isMe: m.senderId == myId,
      time: timeStr,
      isSending: false,
    );
  }

  final String text;
  final bool isMe;
  final String time;
  final bool isSending;

  _UiMessage copyWith({bool? isSending}) => _UiMessage(
        text: text,
        isMe: isMe,
        time: time,
        isSending: isSending ?? this.isSending,
      );
}