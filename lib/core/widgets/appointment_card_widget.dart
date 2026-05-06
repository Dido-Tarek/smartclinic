import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';

class AppointmentCardWidget extends StatelessWidget {
  final String doctorName;
  final String specialization;
  final String appointmentDate;
  final String appointmentTime;
  final String imagePath;
  final VoidCallback onTap;

  const AppointmentCardWidget({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ─── Main white card ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            // right padding leaves room so content doesn't go under the button
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
                  child: Image.asset(
                    imagePath,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
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

          // ─── Time badge — top-right, sitting ON the card edge ──────────
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

          // ─── Arrow button — bottom-right, overflowing the card ─────────
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
        ],
      ),
    );
  }
}
