import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/core/widgets/auth_header.dart';
import 'package:smartclinic/core/widgets/custom_button.dart';
import 'package:smartclinic/core/widgets/login_redirect.dart';
import 'package:smartclinic/injection_dependency.dart';

class MainRegisterScreen extends StatefulWidget {
  const MainRegisterScreen({super.key});

  @override
  State<MainRegisterScreen> createState() => _MainRegisterScreenState();
}

class _MainRegisterScreenState extends State<MainRegisterScreen> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    // 2. تنظيف الـ Controllers مهم جداً للأداء
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              AuthHeader(
                title: localizations.translate("register_header_title"),
                subTitle: localizations.translate("register_header_subtitle"),
              ),

              const SizedBox(height: 20),

              // حقول إدخال البيانات باستخدام الـ Master Widget
              _buildLabel(localizations.translate("Full_Name_title")),
              AppTextFormField(
                hintText: localizations.translate("Full_Name_hint"),
                controller: nameController,
                type: TextFormFieldType.text,
              ),
              const SizedBox(height: 18),

              _buildLabel(localizations.translate("Phone_Number_title")),
              AppTextFormField(
                hintText: localizations.translate("Phone_Number_hint"),
                controller: phoneController,
                type: TextFormFieldType.text,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 18),
              _buildLabel(localizations.translate("Email_title")),
              AppTextFormField(
                hintText: localizations.translate("Email_hint"),
                controller: emailController,
                type: TextFormFieldType.text,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),

              _buildLabel(localizations.translate("Password_title")),
              AppTextFormField(
                hintText: localizations.translate("Password_hint"),
                controller: passwordController,
                type: TextFormFieldType.password,
              ),
              const SizedBox(height: 18),

              _buildLabel(localizations.translate("Confirm_Password_title")),
              AppTextFormField(
                hintText: localizations.translate("Confirm_Password_hint"),
                controller: confirmPasswordController,
                type: TextFormFieldType.password,
              ),

              const SizedBox(height: 30),

              // الزر المخصص بنفس تصميم الصورة
              CustomButton(
                text: localizations.translate("Save"),
                onPressed: _onSavePressed,
              ),

              const SizedBox(height: 20),

              // رابط تسجيل الدخول السفلي
              Center(
                child: LoginRedirectSection(
                  canLogin: true,
                  onLoginPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget بسيط لرسم الـ Labels فوق الحقول كما في التصميم
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // دالة الانتقال لملء البيانات الإضافية في الشاشة التالية
  void _onSavePressed() async {
    final passwordError = _validatePassword(passwordController.text);

    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError), backgroundColor: Colors.red),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedRole = getIt<UserSession>().roleString ?? 'Patient';

    Navigator.pushNamed(
      context,
      AppRoutes.followUpRegisterPatient,
      arguments: {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'password': passwordController.text,
        'confirmPassword': confirmPasswordController.text,
        'role': selectedRole,
      },
    );
  }

  String? _validatePassword(String password) {
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSymbol = RegExp(
      r'[!@#\$%^&*(),.?":{}|<>_\-\\/\[\]~`+=;]',
    ).hasMatch(password);

    if (!hasUppercase || !hasLowercase || !hasNumber || !hasSymbol) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one symbol.';
    }

    return null;
  }
}
