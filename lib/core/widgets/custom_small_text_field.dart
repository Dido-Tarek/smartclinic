import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/localization/app_localization.dart';

// --- النوع الأول: Small Input Field مع أيقونات ديناميكية ---
enum SmallFieldIcon { upload, menu, clock }

class CustomSmallTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController controller;
  final SmallFieldIcon? iconType;
  final String? suffixText;
  final VoidCallback? onTap;
  final TextInputType keyboardType;
  final bool readOnly;
  final double widthFactor;

  const CustomSmallTextField({
    super.key,
    this.hintText,
    required this.controller,
    this.iconType,
    this.suffixText,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.widthFactor = 0.40,
  });

  IconData _getIcon(SmallFieldIcon iconType) {
    switch (iconType) {
      case SmallFieldIcon.upload:
        return Icons.upload_file_outlined;
      case SmallFieldIcon.menu:
        return Icons.menu_rounded;
      case SmallFieldIcon.clock:
        return Icons.access_time_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width * widthFactor,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly || onTap != null,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          suffixText: suffixText,
          suffixStyle: const TextStyle(
            color: AppColors.skyBlue,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          suffixIcon: suffixText == null && iconType != null
              ? Icon(
                  _getIcon(iconType!),
                  color: AppColors.textPrimary,
                  size: 22,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textPrimary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

// --- النوع الثاني: Gender Selection Toggle ---
class GenderSelectionField extends StatefulWidget {
  final Function(String selectedGender)? onGenderChanged;

  const GenderSelectionField({super.key, this.onGenderChanged});

  @override
  State<GenderSelectionField> createState() => _GenderSelectionFieldState();
}

class _GenderSelectionFieldState extends State<GenderSelectionField> {
  String? selectedGender; // 'male' or 'female'

  void _handleGenderSelection(String gender) {
    setState(() {
      selectedGender = gender;
    });
    if (widget.onGenderChanged != null) {
      widget.onGenderChanged!(gender);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 0.45,
      height: 60, // نفس ارتفاع الـ TextField الموحد
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textPrimary),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Row(
          children: [
            // Male Part
            Expanded(
              child: GestureDetector(
                onTap: () => _handleGenderSelection('male'),
                child: Container(
                  color: selectedGender == 'male'
                      ? Colors.blue.withValues(alpha: 0.2)
                      : Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male,
                        color: selectedGender == 'male'
                            ? Colors.blue
                            : Colors.black,
                      ),
                      Text(
                        localizations.translate("male"),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.textPrimary),
            // Female Part
            Expanded(
              child: GestureDetector(
                onTap: () => _handleGenderSelection('female'),
                child: Container(
                  color: selectedGender == 'female'
                      ? Colors.pink.withValues(alpha: 0.2)
                      : Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female,
                        color: selectedGender == 'female'
                            ? Colors.pink
                            : Colors.black,
                      ),
                      Text(
                        localizations.translate("female"),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
