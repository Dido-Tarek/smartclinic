import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/main.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  Future<void> _setLanguage(BuildContext context, Locale locale) async {
    final navigator = Navigator.of(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    appKey.currentState?.setLocale(locale);
    navigator.pushReplacementNamed(AppRoutes.onboarding1);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    String translate(String key) => localizations?.translate(key) ?? key;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          SystemNavigator.pop();
        },
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.splashGradientStart,
                  AppColors.splashGradientEnd,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.08),
                    Text(
                      translate('lang_title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.075,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      translate('lang_subtext'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: AppColors.splashTextSubtle,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Image.asset(
                        AppImages.imagesLogoGif,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Spacer(),
                    _buildLangButton(
                      context: context,
                      label: translate('btn_arabic'),
                      isPrimary: true,
                      isArabic: true,
                      buttonHeight: height * 0.07,
                      onTap: () => _setLanguage(context, const Locale('ar')),
                    ),
                    SizedBox(height: height * 0.018),
                    _buildLangButton(
                      context: context,
                      label: translate('btn_english'),
                      isPrimary: false,
                      isArabic: false,
                      buttonHeight: height * 0.07,
                      onTap: () => _setLanguage(context, const Locale('en')),
                    ),
                    SizedBox(height: height * 0.075),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton({
    required BuildContext context,
    required String label,
    required bool isPrimary,
    required bool isArabic,
    required double buttonHeight,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: buttonHeight.clamp(48.0, 72.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppColors.skyBlue.withAlpha((0.9 * 255).round())
              : Colors.white24,
          side: BorderSide(
            color: isPrimary ? AppColors.accentBlue : Colors.white30,
            width: 1.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight * 0.3),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          style: TextStyle(
            fontSize: buttonHeight * 0.28,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
