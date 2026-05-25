import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';

class MedicalRecordCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isActive;
  final String? relation;
  final String? badgeLabel;
  final bool showEditButton;
  final bool showDeleteButton;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const MedicalRecordCard({
    super.key,
    required this.title,
    required this.description,
    this.isActive = false,
    this.relation,
    this.badgeLabel,
    this.showEditButton = true,
    this.showDeleteButton = true,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.deepNavy, width: 1),
        boxShadow: [
          const BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF6D7A90),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if ((badgeLabel ?? relation)?.isNotEmpty == true)
                Container(
                  constraints: const BoxConstraints(minWidth: 132),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    badgeLabel ?? relation!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showEditButton) ...[
                _ActionButton(
                  onTap: onEditPressed,
                  borderColor: const Color(0xFFA6C8ED),
                  iconColor: const Color(0xFFA6C8ED),
                  icon: Icons.edit_outlined,
                ),
                const SizedBox(width: 20),
              ],
              if (showDeleteButton)
                _ActionButton(
                  onTap: onDeletePressed,
                  borderColor: const Color(0xFFFF5A5A),
                  iconColor: const Color(0xFFE10000),
                  icon: Icons.close,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;

  const _ActionButton({
    required this.onTap,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
