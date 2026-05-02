import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';

class TypeCard extends StatelessWidget {
  const TypeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentBlue.withValues(alpha: 0.32)
              : AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.skyBlue : AppColors.textPrimary,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.skyBlue.withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.deepNavy : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
