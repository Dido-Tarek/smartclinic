import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';

class AppointmentCardWidget extends StatelessWidget {
  final String doctorName;
  final String specialization;
  final String appointmentDate;
  final String appointmentTime;
  final String imagePath;
  final String? imageUrl;
  final VoidCallback onTap;
  final bool showArrow;
  final VoidCallback? onCancel;
  final VoidCallback? onChat;
  /// The raw ISO appointment date for determining chat window state
  final String? rawAppointmentDate;

  const AppointmentCardWidget({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.imagePath,
    this.imageUrl,
    required this.onTap,
    this.showArrow = true,
    this.onCancel,
    this.onChat,
    this.rawAppointmentDate,
  });

  Widget _buildDoctorImage() {
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset(imagePath, width: 70, height: 70, fit: BoxFit.cover),
      );
    }
    return Image.asset(imagePath, width: 70, height: 70, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ─── Main white card ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Doctor image ──────────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildDoctorImage(),
                  ),
                  const SizedBox(width: 14),

                  // ── Text info ─────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appointmentDate,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          doctorName,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.deepNavy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          specialization,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Time badge ────────────────────────────────────────────────
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF64748B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appointmentTime,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // ─── Cancel button (bottom-right, overflows the card) ──────────
            if (onCancel != null)
              Positioned(
                right: -10,
                bottom: -10,
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),

            // ─── Arrow button ──────────────────────────────────────────────
            if (showArrow && onCancel == null)
              Positioned(
                right: -10,
                bottom: -10,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.skyBlue.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.north_east_rounded,
                        color: AppColors.deepNavy,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),

            // ─── Chat button (bottom-left) ─────────────────────────────────
            if (onChat != null)
              Positioned(
                left: -10,
                bottom: -10,
                child: _ChatBadge(
                  onTap: onChat!,
                  rawDate: rawAppointmentDate,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat badge — teal when chat window is open, grey when locked
// ─────────────────────────────────────────────────────────────────────────────
class _ChatBadge extends StatelessWidget {
  const _ChatBadge({required this.onTap, this.rawDate});
  final VoidCallback onTap;
  final String? rawDate;

  bool get _isActive {
    if (rawDate == null || rawDate!.isEmpty) return false;
    final raw = rawDate!.split('T').first.trim();
    final apptDate = DateTime.tryParse(raw);
    if (apptDate == null) return false;
    final now = DateTime.now();
    return !now.isBefore(apptDate) &&
        now.isBefore(apptDate.add(const Duration(days: 7)));
  }

  @override
  Widget build(BuildContext context) {
    final active = _isActive;
    final Color bg =
        active ? const Color(0xFF1ABC9C) : const Color(0xFF94A3B8);
    final Color shadow =
        active ? const Color(0xFF1ABC9C) : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: shadow.withValues(alpha: active ? 0.45 : 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.chat_bubble_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
