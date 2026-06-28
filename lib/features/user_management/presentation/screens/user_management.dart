import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_nav_bar.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_cubit.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_state.dart';
import 'package:smartclinic/features/medical_records/presentation/screens/upload_medical_records.dart';
import 'package:smartclinic/injection_dependency.dart';
import 'package:smartclinic/main.dart'; // للوصول لـ appKey لتغيير الـ Locale الفوري

const String _remoteImageBaseUrl = 'http://smartclinicccc.runasp.net/';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late final UserSession _userSession;

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = _userSession.userRole.isDoctor;
    final profile = _ProfileData(
      name: _userSession.fullName?.trim().isNotEmpty == true
          ? _userSession.fullName!.trim()
          : (isDoctor ? 'Doctor' : 'Patient'),
      email: _userSession.email?.trim().isNotEmpty == true
          ? _userSession.email!.trim()
          : '',
      imagePath: _userSession.profileImage,
      fallbackAsset: isDoctor
          ? AppImages.imagesDoctorDRMahmoudAboLeila
          : AppImages.imagesIconsPatient,
    );

    final items = isDoctor ? _doctorItems : _patientItems;

    return BlocProvider(
      create: (_) => getIt<UserManagementCubit>(),
      child: BlocConsumer<UserManagementCubit, UserManagementState>(
        listener: (context, state) async {
          if (state is LogoutSuccess) {
            await _userSession.clearSession();
            if (!context.mounted) {
              return;
            }

            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }

          if (state is UserManagementError) {
            CherryToast.error(
              title: const Text('Error'),
              description: Text(state.message),
            ).show(context);
          }
        },
        builder: (context, state) {
          final isLoggingOut = state is UserManagementLoading;

          return Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            extendBody: true,
            bottomNavigationBar: CustomNavBar(
              selectedIndex: 3,
              userRole: _userSession.userRole,
              onChatbotPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.nouga),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileHeader(profile: profile),
                      const SizedBox(height: 18),
                      Text(
                        'Account Settings',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.95,
                          ),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _SettingTile(
                            label: item.label,
                            icon: item.icon,
                            onTap: () async {
                              if (item.label == 'Clinic Settings') {
                                final role =
                                    _userSession.roleString ?? 'Doctor';
                                final userId =
                                    _userSession.userId?.trim() ?? '';
                                if (userId.isNotEmpty) {
                                  if (!_userSession.isSetupCompleted(
                                    role: role,
                                    userId: userId,
                                  )) {
                                    _navigateTo(
                                      AppRoutes.medicalFacilityManagement,
                                    );
                                    return;
                                  }
                                }
                              }
                              _navigateTo(switch (item.label) {
                                'Profile Settings' =>
                                  isDoctor
                                      ? AppRoutes.doctorProfileSettings
                                      : AppRoutes.patientProfileSettings,
                                'Notifications' => AppRoutes.notifications,
                                'Payment Settings' => AppRoutes.wallet,
                                'Clinic Settings' => AppRoutes.clinicManagement,
                                'Family Members' => AppRoutes.familyMember,
                                'Medical Records' =>
                                  AppRoutes.uploadMedicalRecords,
                                'Health Issues' => AppRoutes.healthIssues,
                                'Prescriptions' => AppRoutes.prescriptions,
                                String() => throw UnimplementedError(
                                  'No route defined for ${item.label}',
                                ),
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: _LogoutButton(
                            isLoading: isLoggingOut,
                            onPressed: () => context
                                .read<UserManagementCubit>()
                                .emitLogout(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateTo(String route) {
    if (route == AppRoutes.uploadMedicalRecords) {
      Navigator.pushNamed(
        context,
        route,
        arguments: MedicalRecordsSource.profile,
      ).whenComplete(() {
        if (mounted) {
          setState(() {});
        }
      });
      return;
    }

    Navigator.pushNamed(context, route).whenComplete(() {
      if (mounted) {
        setState(() {});
      }
    });
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final _ProfileData profile;

  Widget _buildAvatar(_ProfileData profile) {
    final imagePath = profile.imagePath;
    final imageSource = imagePath?.trim();

    if (imageSource == null || imageSource.isEmpty) {
      return Image.asset(profile.fallbackAsset, fit: BoxFit.cover);
    }

    if (imageSource.startsWith('assets/')) {
      return Image.asset(imageSource, fit: BoxFit.cover);
    }

    final file = File(imageSource);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset(profile.fallbackAsset, fit: BoxFit.cover),
      );
    }

    final remoteUrl =
        imageSource.startsWith('http://') || imageSource.startsWith('https://')
        ? imageSource
        : '${_remoteImageBaseUrl}${imageSource.startsWith('/') ? imageSource.substring(1) : imageSource}';

    return Image.network(
      remoteUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Image.asset(profile.fallbackAsset, fit: BoxFit.cover),
    );
  }

  // ميثود حركية مضافة لتبديل لغة التطبيق وحفظ الـ Code الجديد
  Future<void> _toggleLanguage(BuildContext context) async {
    final currentLocale = Localizations.localeOf(context);
    final nextLocale = currentLocale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', nextLocale.languageCode);
    appKey.currentState?.setLocale(nextLocale); // تغيير لغة التطبيق في الحال
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    final isArabic = currentLocale.languageCode == 'ar';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.deepNavy, width: 2.2),
              ),
              child: ClipOval(child: _buildAvatar(profile)),
            ),
            Positioned(
              right: -2,
              bottom: 2,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.deepNavy,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.deepNavy,
                  fontSize: 22, // الحفاظ على حجم الخط الأصلي كما هو
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      profile.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.skyBlue,
                        fontSize: 15, // الحفاظ على حجم الخط الأصلي كما هو
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // إضافة زر تبديل اللغة التفاعلي الصغير بجوار الإيميل مباشرة
                  InkWell(
                    onTap: () => _toggleLanguage(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.skyBlue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            size: 14,
                            color: AppColors.deepNavy,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isArabic ? 'English' : 'العربية',
                            style: const TextStyle(
                              color: AppColors.deepNavy,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE7EFF8),
              ),
              child: Icon(icon, size: 19, color: AppColors.deepNavy),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.deepNavy,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: Color(0xFF4B5563),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed, required this.isLoading});

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.softLavender,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.softLavender.withValues(alpha: 0.65),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              'Log out',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
    );
  }
}

class _ProfileData {
  const _ProfileData({
    required this.name,
    required this.email,
    required this.imagePath,
    required this.fallbackAsset,
  });

  final String name;
  final String email;
  final String? imagePath;
  final String fallbackAsset;
}

class _SettingItem {
  const _SettingItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const List<_SettingItem> _patientItems = <_SettingItem>[
  _SettingItem(label: 'Profile Settings', icon: Icons.manage_accounts_rounded),
  _SettingItem(label: 'Notifications', icon: Icons.notifications_rounded),
  _SettingItem(label: 'Reset Password', icon: Icons.security_rounded),
  _SettingItem(label: 'Payment Settings', icon: Icons.credit_card_rounded),
  _SettingItem(label: 'Family Members', icon: Icons.family_restroom_rounded),
  _SettingItem(label: 'Medical Records', icon: Icons.folder_shared_rounded),
  _SettingItem(label: 'Health Issues', icon: Icons.health_and_safety_rounded),
  _SettingItem(label: 'Prescriptions', icon: Icons.medication_rounded),
  _SettingItem(label: 'Help Center', icon: Icons.question_mark_rounded),
];

const List<_SettingItem> _doctorItems = <_SettingItem>[
  _SettingItem(label: 'Profile Settings', icon: Icons.manage_accounts_rounded),
  _SettingItem(label: 'Notifications', icon: Icons.notifications_rounded),
  _SettingItem(label: 'Reset Password', icon: Icons.security_rounded),
  _SettingItem(label: 'Payment Settings', icon: Icons.credit_card_rounded),
  _SettingItem(label: 'Clinic Settings', icon: Icons.local_hospital_rounded),
  _SettingItem(label: 'Prescriptions', icon: Icons.medication_rounded),
  _SettingItem(label: 'Help Center', icon: Icons.question_mark_rounded),
];
