import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';

class MedicalRecordCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isActive;
  final String? relation;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const MedicalRecordCard({
    super.key,
    required this.title,
    required this.description,
    this.isActive = false,
    this.relation,
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
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (relation != null && relation!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        relation!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.deepNavy : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isActive
                        ? AppColors.deepNavy
                        : AppColors.textSecondary,
                    width: 2,
                  ),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onEditPressed,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.deepNavy,
                  size: 22,
                ),
              ),
              IconButton(
                onPressed: onDeletePressed,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
