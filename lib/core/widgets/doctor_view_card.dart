import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';

class DoctorViewCard extends StatelessWidget {
  final String doctorName;
  final String specialization;
  final String clinicName;
  final double rating;
  final String doctorImagePath;
  final int yearsOfExperience;
  final int patientsCount;
  final int reviewsCount;

  const DoctorViewCard({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.clinicName,
    required this.rating,
    required this.doctorImagePath,
    this.yearsOfExperience = 5,
    this.patientsCount = 500,
    this.reviewsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final imageSource = doctorImagePath.trim();
    final isNetworkImage =
        imageSource.startsWith('http://') || imageSource.startsWith('https://');
    final isLocalFile =
        imageSource.isNotEmpty && File(imageSource).existsSync();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Half-circle doctor image ──
          ClipOval(
            child: ColoredBox(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.centerRight,
                widthFactor: 0.70,
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: isNetworkImage
                      ? Image.network(
                          imageSource,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Image.asset(doctorImagePath, fit: BoxFit.cover),
                        )
                      : isLocalFile
                      ? Image.file(File(imageSource), fit: BoxFit.cover)
                      : Image.asset(
                          doctorImagePath,
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.srcOver,
                        ),
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name + verified icon
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.deepNavy,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.skyBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Specialization | Clinic
                    Text(
                      '$specialization  |  $clinicName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rating + reviews count
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.yellowRating,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepNavy,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '($reviewsCount reviews)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Badges row — single row
                    Row(
                      children: [
                        Expanded(
                          child: _BadgeItem(
                            icon: Icons.emoji_events_outlined,
                            label: '+$yearsOfExperience Years EXP',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _BadgeItem(
                            icon: Icons.people_alt_outlined,
                            label: '+$patientsCount Patients',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge widget ──────────────────────────────────────────────────────────────
class _BadgeItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BadgeItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.skyBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.skyBlue, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.skyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
