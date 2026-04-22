import 'package:flutter/foundation.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/routes/app_routes.dart';

class AccountSelectionOption {
  final String titleKey;
  final String imagePath;
  final String routeName;
  final String role; // Add role field

  const AccountSelectionOption({
    required this.titleKey,
    required this.imagePath,
    required this.routeName,
    required this.role,
  });
}

class AccountSelectionModel {
  final bool canNavigateToLogin;
  final VoidCallback? onLoginTap;
  bool agreeToTerms;

  AccountSelectionModel({
    this.canNavigateToLogin = false,
    this.onLoginTap,
    this.agreeToTerms = false,
  });

  static const List<AccountSelectionOption> options = [
    AccountSelectionOption(
      titleKey: 'account_type_patient',
      imagePath: AppImages.imagesIconsPatient,
      routeName: AppRoutes.mainRegister,
      role: 'Patient',
    ),
    AccountSelectionOption(
      titleKey: 'account_type_doctor',
      imagePath: AppImages.imagesIconsDoctor,
      routeName: AppRoutes.mainRegister,
      role: 'Doctor',
    ),
    AccountSelectionOption(
      titleKey: 'account_type_hospital',
      imagePath: AppImages.imagesIconsHospital,
      routeName: AppRoutes.mainRegister,
      role: 'MedicalFacility',
    ),
  ];

  void toggleAgreeToTerms(bool value) {
    agreeToTerms = value;
  }

  void handleLoginTap() {
    if (canNavigateToLogin && onLoginTap != null) {
      onLoginTap!();
    }
  }
}
