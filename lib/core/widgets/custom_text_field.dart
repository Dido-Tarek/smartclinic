import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';

enum TextFormFieldType {
  text,
  password,
  date,
  location,
  speciality,
  fileUpload,
}

class AppTextFormField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final TextFormFieldType type;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final bool readOnly;

  const AppTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.type = TextFormFieldType.text,
    this.validator,
    this.onTap,
    this.onSuffixTap,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  bool _obscureText = true;

  IconData _getSuffixIcon() {
    switch (widget.type) {
      case TextFormFieldType.password:
        return _obscureText
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined;
      case TextFormFieldType.date:
        return Icons.calendar_month_outlined;
      case TextFormFieldType.location:
        return Icons.location_on_outlined;
      case TextFormFieldType.speciality:
        return Icons.menu_rounded;
      case TextFormFieldType.fileUpload:
        return Icons.cloud_upload_outlined;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveValidator = widget.validator ??
      (widget.type == TextFormFieldType.password
        ? _validatePasswordStrength
        : null);

    return TextFormField(
      controller: widget.controller,
      // تفعيل إخفاء النص فقط لو النوع password
      obscureText: (widget.type == TextFormFieldType.password)
          ? _obscureText
          : false,
      validator: effectiveValidator,
      onChanged: widget.onChanged,
      // جعل الحقل للقراءة فقط في حالة التاريخ أو الرفع أو القائمة المنسدلة
        readOnly:
          widget.readOnly ||
          widget.type == TextFormFieldType.date ||
          widget.type == TextFormFieldType.location ||
          widget.type == TextFormFieldType.fileUpload,
        onTap: (widget.type == TextFormFieldType.fileUpload ||
                widget.type == TextFormFieldType.location)
            ? null
            : widget.onTap,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        suffixIcon: _buildSuffixIcon(),

        filled: true,
        fillColor: AppColors.cardBg,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        border: _buildBorder(),
        enabledBorder: _buildBorder(color: AppColors.textPrimary),
        focusedBorder: _buildBorder(color: AppColors.skyBlue, width: 1.5),
        errorBorder: _buildBorder(color: Colors.redAccent),
      ),
    );
  }

  String? _validatePasswordStrength(String? value) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\/\[\]~`+=;]').hasMatch(password);

    if (!hasLowercase || !hasUppercase || !hasNumber || !hasSymbol) {
      return 'Password must include uppercase, lowercase, number, and symbol';
    }

    return null;
  }

  // بناء الأيقونة الخلفية بشكل ديناميكي
  Widget? _buildSuffixIcon() {
    switch (widget.type) {
      case TextFormFieldType.password:
        return IconButton(
          icon: Icon(_getSuffixIcon(), color: AppColors.textSecondary),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        );
      case TextFormFieldType.date:
        return Icon(_getSuffixIcon(), color: AppColors.textSecondary);
      case TextFormFieldType.location:
        return IconButton(
          icon: Icon(_getSuffixIcon(), color: AppColors.textSecondary),
          onPressed: widget.onSuffixTap,
        );
      case TextFormFieldType.speciality:
        return IconButton(
          icon: Icon(_getSuffixIcon(), color: AppColors.textSecondary),
          onPressed: widget.onSuffixTap,
        );
      case TextFormFieldType.fileUpload:
        return IconButton(
          icon: Icon(_getSuffixIcon(), color: AppColors.textPrimary),
          onPressed: widget.onSuffixTap,
        );
      default:
        return null;
    }
  }

  // توحيد شكل الـ Border
  OutlineInputBorder _buildBorder({Color? color, double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: color != null
          ? BorderSide(color: color, width: width)
          : BorderSide.none,
    );
  }
}
