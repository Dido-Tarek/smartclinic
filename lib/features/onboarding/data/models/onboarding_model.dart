import 'package:smartclinic/core/constants/assets.dart';

class OnboardingModel {
  final String title;
  final String subTitle;
  final String image;
  final bool showPrevious;
  final String nextText;

  OnboardingModel({
    required this.title,
    required this.subTitle,
    required this.image,
    this.showPrevious = true,
    this.nextText = "Next",
  });

  static List<OnboardingModel> getPages() {
    return [
      OnboardingModel(
        title: "onboarding_title_1",
        subTitle: "onboarding_subtitle_1",
        image: AppImages.imagesOnboard1,
        showPrevious: false,
        nextText: "onboarding_next",
      ),
      OnboardingModel(
        title: "onboarding_title_2",
        subTitle: "onboarding_subtitle_2",
        image: AppImages.imagesOnboard2,
        nextText: "onboarding_next",
      ),
      OnboardingModel(
        title: "onboarding_title_3",
        subTitle: "onboarding_subtitle_3",
        image: AppImages.imagesOnboard3,
        nextText: "onboarding_get_started",
      ),
    ];
  }
}
