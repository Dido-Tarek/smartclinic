import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/appointments/presentation/screens/booking_summary.dart';
import 'package:smartclinic/features/auth/presentation/manager/upload_credentials_cubit.dart';
import 'package:smartclinic/features/clinic/presentation/manager/add_clinic_cubit.dart';
import 'package:smartclinic/features/clinic/presentation/screens/appointment_details.dart';
import 'package:smartclinic/features/appointments/presentation/screens/appointments.dart';
import 'package:smartclinic/features/clinic/presentation/screens/clinic_details.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_cubit.dart';
import 'package:smartclinic/features/family_members/presentation/manager/family_member_cubit.dart';
import 'package:smartclinic/features/family_members/presentation/screens/family_member.dart';
import 'package:smartclinic/features/family_members/presentation/screens/add_family_member.dart';
import 'package:smartclinic/features/health_issues/presentation/screens/health_issues.dart';
import 'package:smartclinic/features/health_issues/presentation/screens/add_health_issue.dart';
import 'package:smartclinic/features/auth/presentation/manager/register_cubit.dart';
import 'package:smartclinic/features/health_issues/presentation/manager/health_issues_cubit.dart';
import 'package:smartclinic/features/home/presentation/screens/home_screen.dart';
import 'package:smartclinic/features/chat/presentation/screens/chat.dart';
import 'package:smartclinic/features/chat/presentation/screens/doctor_chat_room.dart';
import 'package:smartclinic/features/clinic_management/presentation/screens/clinic_management.dart';
import 'package:smartclinic/features/medical_records/presentation/manager/medical_records_cubit.dart';
import 'package:smartclinic/features/nouga/presentation/screens/nouga.dart';
import 'package:smartclinic/features/security/presentation/screens/verification_screen.dart';
import 'package:smartclinic/features/registeration/presentation/screens/facility/follow_up_registeration_medical_facility.dart';
import 'package:smartclinic/features/registeration/presentation/screens/facility/license_verification.dart';
import 'package:smartclinic/features/registeration/presentation/screens/facility/medical_facility_management.dart';
import 'package:smartclinic/features/notification/presentation/manager/notifications_cubit.dart';
import 'package:smartclinic/features/notification/presentation/screens/notifications_screen.dart';
import 'package:smartclinic/features/search/presentation/manager/search_doctors_cubit.dart';
import 'package:smartclinic/features/search/presentation/screens/search_page.dart';
import 'package:smartclinic/features/search/presentation/screens/search_filter.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_cubit.dart';
import 'package:smartclinic/features/user_management/presentation/screens/user_management.dart';
import 'package:smartclinic/features/user_management/presentation/screens/doctor_profile_settings.dart';
import 'package:smartclinic/features/user_management/presentation/screens/patient_profile_settings.dart';
import 'package:smartclinic/features/doctor_profile/presentation/screens/doctor_profile_view.dart';
import 'package:smartclinic/features/appointments/presentation/screens/booking_details.dart';
import 'package:smartclinic/features/appointments/presentation/screens/booking_information.dart';
import 'package:smartclinic/features/appointments/presentation/screens/appointment_summary.dart';
import 'package:smartclinic/features/appointments/presentation/screens/booking_confirmation.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_cubit.dart';
import 'package:smartclinic/features/wallet/presentation/manager/wallet_cubit.dart';
import 'package:smartclinic/features/wallet/presentation/screens/wallet_screen.dart';
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
import 'package:smartclinic/features/medical_records/presentation/screens/medical_records_history_screen.dart';

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
      case AppRoutes.followUpRegisterDoctor:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => getIt<RegisterCubit>(),
            child: const FollowUpRegisterDoctorScreen(),
          ),
        );
      case AppRoutes.uploadMedicalRecords:
        final source = settings.arguments;
        final medicalRecordsSource = source is MedicalRecordsSource
            ? source
            : MedicalRecordsSource.registration;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<MedicalRecordsCubit>(),
            child: UploadMedicalRecordsScreen(source: medicalRecordsSource),
          ),
        );
      case AppRoutes.medicalRecordsHistory:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<MedicalRecordsCubit>(),
            child: const MedicalRecordsHistoryScreen(),
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
      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<NotificationsCubit>(),
            child: const NotificationsScreen(),
          ),
        );
      case AppRoutes.appointments:
        final args = settings.arguments;
        final initialIndex = args is Map && args['initialIndex'] is int
            ? (args['initialIndex'] as int)
            : 0;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<AppointmentsCubit>(),
            child: AppointmentsScreen(initialIndex: initialIndex),
          ),
        );
      case AppRoutes.nouga:
        return MaterialPageRoute(builder: (_) => const NougaAiChatPage());
      case AppRoutes.inbox:
        return MaterialPageRoute(builder: (_) => const InboxChatRoomsScreen());
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<DoctorsCubit>(),
            child: const HomeScreen(),
          ),
        );
      case AppRoutes.hospitalhome:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Home Screen Placeholder for Hospital')),
          ),
        );
      case AppRoutes.verification:
        final arguments = settings.arguments;
        final email = arguments is Map
            ? (arguments['email'] ?? arguments['registrationEmail'])
                  ?.toString()
                  .trim()
            : arguments?.toString().trim();
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => VerificationPage(
            email: (email == null || email.isEmpty) ? '' : email,
          ),
        );
      case AppRoutes.verifyDoctor:
        final arguments = settings.arguments;
        final registrationArgs = arguments is Map
            ? arguments.map((key, value) => MapEntry(key.toString(), value))
            : null;
        return MaterialPageRoute(
          builder: (_) =>
              LicenseVerificationPage(registrationArgs: registrationArgs),
        );
      case AppRoutes.clinicDetails:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<ClinicManagementCubit>(),
            child: const ClinicDetailsPage(),
          ),
        );
      case AppRoutes.doctorProfileSettings:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<UserManagementCubit>(),
            child: const DoctorProfileSettingsPage(),
          ),
        );
      case AppRoutes.patientProfileSettings:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<UserManagementCubit>(),
            child: const PatientProfileSettingsPage(),
          ),
        );
      case AppRoutes.doctorProfileView:
        final args = settings.arguments;
        final data = args is Map ? args : null;
        final enabledTypes =
            data is Map && data['enabledConsultationTypes'] is Iterable
            ? (data['enabledConsultationTypes'] as Iterable)
                  .map((item) => item.toString())
                  .where((item) => item.isNotEmpty)
                  .toSet()
            : const {'clinic', 'online', 'homeVisit', 'emergency'};
        return MaterialPageRoute(
          builder: (_) => DoctorProfileView(
            doctorName: data is Map && data['name'] != null
                ? data['name'] as String
                : null,
            doctorImage: data is Map && data['doctorImage'] != null
                ? data['doctorImage'] as String
                : null,
            specialization: data is Map && data['specialization'] != null
                ? data['specialization'] as String
                : null,
            rating: data is Map && data['rating'] != null
                ? (data['rating'] as num).toDouble()
                : null,
            reviewsCount: data is Map && data['reviewsCount'] != null
                ? data['reviewsCount'] as int
                : null,
            enabledConsultationTypes: enabledTypes,
          ),
        );
      case AppRoutes.appointmentDetails:
        final args = settings.arguments;
        final hasTypeFlags =
            args is Map &&
            (args['clinic'] is bool ||
                args['online'] is bool ||
                args['homeVisit'] is bool ||
                args['emergency'] is bool);
        final appointmentTypes = hasTypeFlags
            ? {
                if (args['clinic'] == true) 'clinic',
                if (args['online'] == true) 'online',
                if (args['homeVisit'] == true) 'homeVisit',
                if (args['emergency'] == true) 'emergency',
              }
            : <String>{'clinic', 'online', 'homeVisit', 'emergency'};
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => getIt<AddClinicCubit>(),
            child: AppointmentDetailsPage(
              enabledAppointmentTypes: appointmentTypes,
            ),
          ),
        );
      case AppRoutes.bookingDetails:
        final args = settings.arguments;
        final data = args is Map ? args : null;
        final enabledTypes =
            data is Map && data['enabledAppointmentTypes'] is Iterable
            ? (data['enabledAppointmentTypes'] as Iterable)
                  .map((item) => item.toString())
                  .where((item) => item.isNotEmpty)
                  .toSet()
            : const {'clinic', 'online', 'homeVisit', 'emergency'};
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => getIt<AppointmentsCubit>(),
            child: BookingDetailsPage(
              doctorId: data is Map && data['doctorId'] != null
                  ? data['doctorId'] as String
                  : null,
              clinicId: data is Map && data['clinicId'] != null
                  ? data['clinicId'] as int
                  : null,
              doctorName: data is Map && data['name'] != null
                  ? data['name'] as String
                  : null,
              doctorImage: data is Map && data['image'] != null
                  ? data['image'] as String
                  : null,
              enabledAppointmentTypes: enabledTypes,
            ),
          ),
        );
      case AppRoutes.bookingInformation:
        final args = settings.arguments;
        final data = args is Map ? args : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => getIt<FamilyCubit>(),
            child: BookingInformationPage(
              doctorId: data is Map && data['doctorId'] != null
                  ? data['doctorId'] as String
                  : null,
              clinicId: data is Map && data['clinicId'] != null
                  ? data['clinicId'] as int
                  : null,
              doctorName: data is Map && data['doctorName'] != null
                  ? data['doctorName'] as String
                  : null,
              consultationType: data is Map && data['consultationType'] != null
                  ? data['consultationType'] as String
                  : null,
              selectedDate: data is Map && data['selectedDate'] != null
                  ? data['selectedDate'] as String
                  : null,
              selectedTime: data is Map && data['selectedTime'] != null
                  ? data['selectedTime'] as String
                  : null,
            ),
          ),
        );
      case AppRoutes.appointmentSummary:
        final args = settings.arguments;
        final data = args is Map ? args : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AppointmentSummaryPage(
            doctorName: data is Map && data['doctorName'] != null
                ? data['doctorName'] as String
                : null,
            specialization: data is Map && data['specialization'] != null
                ? data['specialization'] as String
                : null,
            clinicName: data is Map && data['clinicName'] != null
                ? data['clinicName'] as String
                : null,
            rating: data is Map && data['rating'] != null
                ? data['rating'] as double
                : null,
            doctorImage: data is Map && data['doctorImage'] != null
                ? data['doctorImage'] as String
                : null,
            yearsOfExperience: data is Map && data['yearsOfExperience'] != null
                ? data['yearsOfExperience'] as int
                : null,
            patientsCount: data is Map && data['patientsCount'] != null
                ? data['patientsCount'] as int
                : null,
            reviewsCount: data is Map && data['reviewsCount'] != null
                ? data['reviewsCount'] as int
                : null,
            consultationType: data is Map && data['consultationType'] != null
                ? data['consultationType'] as String
                : null,
            selectedDate: data is Map && data['selectedDate'] != null
                ? data['selectedDate'] as String
                : null,
            selectedTime: data is Map && data['selectedTime'] != null
                ? data['selectedTime'] as String
                : null,
            patientName: data is Map && data['patientName'] != null
                ? data['patientName'] as String
                : null,
            paymentMethod: data is Map && data['paymentMethod'] != null
                ? data['paymentMethod'] as String
                : null,
          ),
        );
      case AppRoutes.bookingSummary:
        final args = settings.arguments;
        final data = args is Map ? args : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BookingSummaryPage(
            doctorId: data is Map && data['doctorId'] != null
                ? data['doctorId'] as String
                : null,
            clinicId: data is Map && data['clinicId'] != null
                ? data['clinicId'] as int
                : null,
            doctorName: data is Map && data['doctorName'] != null
                ? data['doctorName'] as String
                : null,
            specialization: data is Map && data['specialization'] != null
                ? data['specialization'] as String
                : null,
            clinicName: data is Map && data['clinicName'] != null
                ? data['clinicName'] as String
                : null,
            rating: data is Map && data['rating'] != null
                ? data['rating'] as double
                : null,
            doctorImage: data is Map && data['doctorImage'] != null
                ? data['doctorImage'] as String
                : null,
            yearsOfExperience: data is Map && data['yearsOfExperience'] != null
                ? data['yearsOfExperience'] as int
                : null,
            patientsCount: data is Map && data['patientsCount'] != null
                ? data['patientsCount'] as int
                : null,
            reviewsCount: data is Map && data['reviewsCount'] != null
                ? data['reviewsCount'] as int
                : null,
            consultationType: data is Map && data['consultationType'] != null
                ? data['consultationType'] as String
                : null,
            selectedDate: data is Map && data['selectedDate'] != null
                ? data['selectedDate'] as String
                : null,
            selectedTime: data is Map && data['selectedTime'] != null
                ? data['selectedTime'] as String
                : null,
            patientName: data is Map && data['patientName'] != null
                ? data['patientName'] as String
                : null,
            familyMemberId: data is Map && data['familyMemberId'] != null
                ? data['familyMemberId'] as int
                : null,
            notes: data is Map && data['notes'] != null
                ? data['notes'] as String
                : null,
            paymentMethod: data is Map && data['paymentMethod'] != null
                ? data['paymentMethod'] as String
                : null,
          ),
        );
      case AppRoutes.doctorChatRoom:
        final args = settings.arguments;
        final data = args is Map ? args : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DoctorChatRoomScreen(
            doctorName: data is Map && data['doctorName'] != null
                ? data['doctorName'] as String
                : null,
            specialization: data is Map && data['specialization'] != null
                ? data['specialization'] as String
                : null,
            clinicName: data is Map && data['clinicName'] != null
                ? data['clinicName'] as String
                : null,
            doctorImagePath: data is Map && data['doctorImage'] != null
                ? data['doctorImage'] as String
                : null,
            consultationType: data is Map && data['consultationType'] != null
                ? data['consultationType'] as String
                : null,
            selectedDate: data is Map && data['selectedDate'] != null
                ? data['selectedDate'] as String
                : null,
            selectedTime: data is Map && data['selectedTime'] != null
                ? data['selectedTime'] as String
                : null,
          ),
        );
      case AppRoutes.clinicManagement:
        return MaterialPageRoute(builder: (_) => const ClinicManagementPage());
      case AppRoutes.bookingConfirmation:
        final args = settings.arguments;
        final data = args is Map ? args : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BookingConfirmationPage(
            doctorName: data is Map && data['doctorName'] != null
                ? data['doctorName'] as String
                : null,
            specialization: data is Map && data['specialization'] != null
                ? data['specialization'] as String
                : null,
            clinicName: data is Map && data['clinicName'] != null
                ? data['clinicName'] as String
                : null,
            rating: data is Map && data['rating'] != null
                ? data['rating'] as double
                : null,
            doctorImage: data is Map && data['doctorImage'] != null
                ? data['doctorImage'] as String
                : null,
            yearsOfExperience: data is Map && data['yearsOfExperience'] != null
                ? data['yearsOfExperience'] as int
                : null,
            patientsCount: data is Map && data['patientsCount'] != null
                ? data['patientsCount'] as int
                : null,
            reviewsCount: data is Map && data['reviewsCount'] != null
                ? data['reviewsCount'] as int
                : null,
            consultationType: data is Map && data['consultationType'] != null
                ? data['consultationType'] as String
                : null,
            selectedDate: data is Map && data['selectedDate'] != null
                ? data['selectedDate'] as String
                : null,
            selectedTime: data is Map && data['selectedTime'] != null
                ? data['selectedTime'] as String
                : null,
            patientName: data is Map && data['patientName'] != null
                ? data['patientName'] as String
                : null,
            paymentMethod: data is Map && data['paymentMethod'] != null
                ? data['paymentMethod'] as String
                : null,
          ),
        );
      case AppRoutes.medicalFacilityManagement:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<UploadCredentialsCubit>(),
            child: const MedicalFacilityManagementPage(),
          ),
        );
      case AppRoutes.search:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<DoctorsCubit>(),
            child: const SearchPage(),
          ),
        );
      case AppRoutes.searchFilter:
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (_, animation, secondaryAnimation) => BlocProvider(
            create: (context) => getIt<DoctorsCubit>(),
            child: const SearchFilterScreen(),
          ),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            final offset =
                Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
        );
      case AppRoutes.wallet:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<WalletCubit>(),
            child: const WalletScreen(),
          ),
        );
      case AppRoutes.userManagement:
        return MaterialPageRoute(builder: (_) => const UserManagementPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
