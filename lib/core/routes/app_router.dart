import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/family_members/presentation/manager/family_member_cubit.dart';
import 'package:smartclinic/features/family_members/presentation/screens/family_member.dart';
import 'package:smartclinic/features/family_members/presentation/screens/add_family_member.dart';
import 'package:smartclinic/features/health_issues/presentation/screens/health_issues.dart';
import 'package:smartclinic/features/health_issues/presentation/screens/add_health_issue.dart';
import 'package:smartclinic/features/auth/presentation/manager/register_cubit.dart';
import 'package:smartclinic/features/health_issues/presentation/manager/health_issues_cubit.dart';
import 'package:smartclinic/features/medical_records/presentation/manager/medical_records_cubit.dart';
import 'package:smartclinic/injection_dependency.dart';
import 'app_routes.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/splash/presentation/screens/language_selection_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/screens/account_selection_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/main_registeration_screen.dart';
import '../../features/registeration/presentation/screens/patient/follow_up_registeration_patient.dart';
import 'package:smartclinic/features/medical_records/presentation/screens/upload_medical_records.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '';
    final uri = Uri.parse(routeName);

    switch (uri.path) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.lngSelect:
        return MaterialPageRoute(
          builder: (_) => const LanguageSelectionScreen(),
        );
      case AppRoutes.onboarding1:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(pageIndex: 0),
        );
      case AppRoutes.onboarding2:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(pageIndex: 1),
        );
      case AppRoutes.onboarding3:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(pageIndex: 2),
        );
      case AppRoutes.accountSelection:
        return MaterialPageRoute(
          builder: (_) => const AccountSelectionScreen(),
        );
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.mainRegister:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<RegisterCubit>(),
            child: const MainRegisterScreen(),
          ),
        );
      case AppRoutes.followUpRegisterPatient:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => getIt<RegisterCubit>(),
            child: const FollowUpRegisterScreen(),
          ),
        );
      // case AppRoutes.followUpRegisterDoctor:
      //   return MaterialPageRoute(
      //     builder: (_) => const FollowUpRegisterDoctorScreen(),
      case AppRoutes.uploadMedicalRecords:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<MedicalRecordsCubit>(),
            child: const UploadMedicalRecordsScreen(),
          ),
        );
      case AppRoutes.healthIssues:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<HealthIssuesCubit>(),
            child: const HealthIssues(),
          ),
        );
      case AppRoutes.addHealthIssue:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<HealthIssuesCubit>(),
            child: const AddHealthIssue(),
          ),
        );
      case AppRoutes.familyMember:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<FamilyCubit>(),
            child: const FamilyMember(),
          ),
        );
      case AppRoutes.addFamilyMember:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<FamilyCubit>(),
            child: const AddFamilyMember(),
          ),
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) =>
              Scaffold(body: Center(child: Text('Home Screen Placeholder'))),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
