import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/widgets/auth_header.dart';
import 'package:smartclinic/features/auth/data/models/account_selection_model.dart';
import 'package:smartclinic/core/widgets/login_redirect.dart';
import 'package:smartclinic/injection_dependency.dart';

class AccountSelectionScreen extends StatefulWidget {
  final bool canNavigateToLogin;
  final VoidCallback? onLoginTap;

  const AccountSelectionScreen({
    super.key,
    this.canNavigateToLogin = true,
    this.onLoginTap,
  });

  @override
  State<AccountSelectionScreen> createState() => _AccountSelectionScreenState();
}

class _AccountSelectionScreenState extends State<AccountSelectionScreen> {
  late final AccountSelectionModel _model;

  @override
  void initState() {
    super.initState();
    _model = AccountSelectionModel(
      canNavigateToLogin: widget.canNavigateToLogin,
      onLoginTap: widget.onLoginTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Basic dynamic sizing calculations
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final localizations = AppLocalizations.of(context)!;

    // Standard horizontal padding for all auth screens
    final horizontalPadding = width * 0.08;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height - MediaQuery.of(context).padding.vertical,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.04),
                  AuthHeader(
                    title: localizations.translate("auth_welcome_title"),
                    subTitle: localizations.translate("auth_welcome_subtitle"),
                  ),

                  SizedBox(height: height * 0.03),
                  for (
                    var index = 0;
                    index < AccountSelectionModel.options.length;
                    index++
                  ) ...[
                    _buildSelectionCard(
                      option: AccountSelectionModel.options[index],
                      width: width,
                      height: height,
                      localizations: localizations,
                    ),
                    if (index < AccountSelectionModel.options.length - 1)
                      SizedBox(height: height * 0.035),
                  ],

                  const Spacer(), // Pushes the rest to the bottom
                  // 3. TERMS AND SERVICES CHECKBOX
                  _buildTermsAndServices(width, localizations),

                  SizedBox(height: height * 0.03),

                  // 4. ALREADY HAVE AN ACCOUNT / LOGIN
                  LoginRedirectSection(
                    canLogin: _model.canNavigateToLogin,
                    onLoginPressed: _model.onLoginTap,
                  ),

                  SizedBox(height: height * 0.04), // Dynamic bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper to build individual selection cards ---
  Widget _buildSelectionCard({
    required AccountSelectionOption option,
    required double width,
    required double height,
    required AppLocalizations localizations,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double cardHeight =
        screenWidth *
        0.38; // Adjust height based on screen width for better aspect ratio
    final double cardwidth = screenWidth * 0.7; // Account for horizontal

    return GestureDetector(
      onTap: () async {
        if (!_model.agreeToTerms) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please agree to the Terms and Privacy Policy to continue.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Store selected role for Login/Register/Splash routing.
        await getIt<UserSession>().saveRole(option.role);
        if (mounted) {
          Navigator.pushNamed(context, option.routeName);
        }
      },
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: cardwidth,
          height: cardHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.deepNavy,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.skyBlue.withOpacity(0.18),
                blurRadius: 18,
                spreadRadius: 3,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: width * 0.26,
                height: width * 0.26,
                padding: EdgeInsets.all(width * 0.04),
                child: Image.asset(option.imagePath, fit: BoxFit.contain),
              ),
              Text(
                localizations.translate(option.titleKey),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.048,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper to build Terms and Services section ---
  Widget _buildTermsAndServices(double width, AppLocalizations localizations) {
    return Row(
      children: [
        Checkbox(
          value: _model.agreeToTerms,
          activeColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ), // Match UI rounded look
          onChanged: (newValue) {
            setState(() {
              _model.toggleAgreeToTerms(newValue ?? false);
            });
          },
        ),
        SizedBox(width: width * 0.01),
        Expanded(
          child: Wrap(
            children: [
              Text(
                localizations.translate("auth_terms_prefix"),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: width * 0.035,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle Terms of Service link click
                  debugPrint("ToS Clicked");
                },
                child: Text(
                  localizations.translate("auth_terms_link"),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                " ${localizations.translate("auth_terms_and")} ",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: width * 0.035,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle Privacy Policy link click
                  debugPrint("PP Clicked");
                },
                child: Text(
                  localizations.translate("auth_terms_privacy_link"),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
