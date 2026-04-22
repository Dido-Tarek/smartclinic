import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
// import 'package:smartclinic/core/utils/loader_bridge.dart'; // # تأكد من المسار
import '../data/models/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.pageIndex});

  final int pageIndex;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.pageIndex;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final localizations = AppLocalizations.of(context)!;
    final pages = OnboardingModel.getPages();
    final currentModel = pages[_currentPage];

    // --- إضافة الـ PopScope هنا ---
    return PopScope(
      canPop: false, // نمنع الخروج التلقائي
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // منطق الرجوع: لو مش في أول صفحة، ارجع للي قبلها
        if (_currentPage > 0) {
          final previousRoute = _currentPage == 1
              ? AppRoutes.onboarding1
              : AppRoutes.onboarding2;
          Navigator.pushReplacementNamed(context, previousRoute);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.lngSelect);
        }
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
          child: Stack(
            children: [
              // Top part: Image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: height * 0.55,
                child: Image.asset(
                  currentModel.image,
                  fit: BoxFit.cover,
                  width: width,
                  height: height * 0.55,
                ),
              ),

              // Bottom part: White card
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: height * 0.5,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.05),

                        // Translated title
                        Text(
                          localizations.translate(currentModel.title),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        SizedBox(height: height * 0.02),

                        // Translated subtitle
                        Text(
                          localizations.translate(currentModel.subTitle),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),

                        const Spacer(),

                        // Page indicators (Dots)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            pages.length,
                            (index) => _buildDot(index, width),
                          ),
                        ),

                        SizedBox(height: height * 0.03),

                        // Action buttons
                        _buildActionButtons(localizations, width, height),

                        SizedBox(height: height * 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index, double width) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentPage == index ? width * 0.055 : width * 0.02,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.textPrimary
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _buildActionButtons(
    AppLocalizations localizations,
    double width,
    double height,
  ) {
    final isLastPage = _currentPage == 2;
    final isFirstPage = _currentPage == 0;
    final buttonHeight = height * 0.065;

    if (isFirstPage) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.onboarding2);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textPrimary,
            minimumSize: Size(double.infinity, buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            elevation: 0,
          ),
          child: Text(
            localizations.translate("onboarding_next"),
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.045,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: () {
                final previousRoute = _currentPage == 1
                    ? AppRoutes.onboarding1
                    : AppRoutes.onboarding2;
                Navigator.pushReplacementNamed(context, previousRoute);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textSecondary,
                minimumSize: Size(double.infinity, buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 0,
              ),
              child: Text(
                localizations.translate("onboarding_previous"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: width * 0.04),
        Expanded(
          child: SizedBox(
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: () async {
                if (!isLastPage) {
                  final nextRoute = _currentPage == 1
                      ? AppRoutes.onboarding3
                      : AppRoutes.onboarding3;
                  Navigator.pushReplacementNamed(context, nextRoute);
                } else {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.accountSelection,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                minimumSize: Size(double.infinity, buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 0,
              ),
              child: Text(
                localizations.translate(
                  isLastPage ? "onboarding_get_started" : "onboarding_next",
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
