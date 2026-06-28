import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/appointments/presentation/screens/booking_summary.dart';
import 'package:smartclinic/features/prescriptions/presentation/manager/prescriptions_cubit.dart';
import 'package:smartclinic/features/prescriptions/presentation/screens/add_prescription_screen.dart';
import 'package:smartclinic/features/prescriptions/presentation/screens/prescription_detail_screen.dart';
import 'package:smartclinic/features/prescriptions/presentation/screens/prescriptions_screen.dart';
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
import 'package:smartclinic/features/chat/presentation/manager/chat_cubit.dart';
import 'package:smartclinic/features/appointments/data/model/appointment_response_model.dart';
import 'package:smartclinic/features/clinic_management/presentation/screens/clinic_management.dart';
import 'package:smartclinic/features/clinic_management/presentation/screens/employment_screen.dart';
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
import 'package:smartclinic/features/search/presentation/screens/emergency_search_screen.dart';
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
import 'package:smartclinic/features/invoices/presentation/manager/invoices_cubit.dart';
import 'package:smartclinic/features/clinic_management/presentation/screens/clinic_payment_settings.dart';
import 'package:smartclinic/features/clinic_management/presentation/screens/clinic_schedule_management.dart';
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
    final data = settings.arguments;

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
        final inboxArgs = settings.arguments;
        final inboxAppts = inboxArgs is List<AppointmentModel>
            ? inboxArgs
            : const <AppointmentModel>[];
        return MaterialPageRoute(
          builder: (_) => InboxChatRoomsScreen(appointments: inboxAppts),
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<DoctorsCubit>()),
              BlocProvider(create: (_) => getIt<AppointmentsCubit>()),
              BlocProvider(create: (_) => getIt<HealthIssuesCubit>()),
            ],
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
        final enabledTypes = <String>{};

        if (data is Map && data['enabledConsultationTypes'] is Iterable) {
          enabledTypes.addAll(
            (data['enabledConsultationTypes'] as Iterable)
                .map((item) => item.toString())
                .where((item) => item.isNotEmpty),
          );
        } else if (data is Map &&
            (data['clinic'] is bool ||
                data['online'] is bool ||
                data['homeVisit'] is bool ||
                data['emergency'] is bool)) {
          if (data['clinic'] == true) enabledTypes.add('InClinic');
          if (data['online'] == true) enabledTypes.add('VideoCall');
          if (data['homeVisit'] == true) enabledTypes.add('HomeVisit');
          if (data['emergency'] == true) enabledTypes.add('Emergency');
        }

        if (enabledTypes.isEmpty) {
          enabledTypes.addAll({'InClinic', 'VideoCall', 'HomeVisit', 'FollowUp', 'Emergency'});
        }

        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<UserManagementCubit>(),
            child: DoctorProfileView(
              doctorId: data is Map && data['doctorId'] != null
                  ? data['doctorId'] as String
                  : null,
              clinicId: data is Map && data['clinicId'] != null
                  ? (data['clinicId'] as num).toInt()
                  : null,
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
              yearsOfExperience:
                  data is Map && data['yearsOfExperience'] != null
                  ? (data['yearsOfExperience'] as num).toInt()
                  : null,
              clinicFee: data is Map && data['clinicFee'] != null
                  ? (data['clinicFee'] as num).toDouble()
                  : null,
              onlineFee: data is Map && data['onlineFee'] != null
                  ? (data['onlineFee'] as num).toDouble()
                  : null,
              homeVisitFee: data is Map && data['homeVisitFee'] != null
                  ? (data['homeVisitFee'] as num).toDouble()
                  : null,
              followUpFee: data is Map && data['followUpFee'] != null
                  ? (data['followUpFee'] as num).toDouble()
                  : null,
              emergencyFee: data is Map && data['emergencyFee'] != null
                  ? (data['emergencyFee'] as num).toDouble()
                  : null,
              clinicName: data is Map && data['clinicName'] != null
                  ? data['clinicName'] as String
                  : null,
              clinicAddress: data is Map && data['clinicAddress'] != null
                  ? data['clinicAddress'] as String
                  : data is Map && data['address'] != null
                  ? data['address'] as String
                  : null,
              clinicPhone: data is Map && data['clinicPhone'] != null
                  ? data['clinicPhone'] as String
                  : data is Map && data['phoneNumber'] != null
                  ? data['phoneNumber'] as String
                  : null,
              clinicWorkingHours:
                  data is Map && data['clinicWorkingHours'] != null
                  ? data['clinicWorkingHours'] as String
                  : null,
              enabledConsultationTypes: enabledTypes,
              showBookButton: data is Map && data['showBookButton'] == false
                  ? false
                  : true,
            ),
          ),
        );
      case AppRoutes.appointmentDetails:
        final args = settings.arguments;
        final data = args is Map ? args : null;
        final enabledTypes = <String>{};

        if (data is Map && data['enabledAppointmentTypes'] is Iterable) {
          enabledTypes.addAll(
            (data['enabledAppointmentTypes'] as Iterable)
                .map((item) => item.toString())
                .where((item) => item.isNotEmpty),
          );
        } else if (data is Map &&
            (data['clinic'] is bool ||
                data['online'] is bool ||
                data['homeVisit'] is bool ||
                data['emergency'] is bool)) {
          if (data['clinic'] == true) enabledTypes.add('InClinic');
          if (data['online'] == true) enabledTypes.add('VideoCall');
          if (data['homeVisit'] == true) enabledTypes.add('HomeVisit');
          if (data['emergency'] == true) enabledTypes.add('Emergency');
        }

        if (enabledTypes.isEmpty) {
          enabledTypes.addAll({'InClinic', 'VideoCall', 'HomeVisit', 'FollowUp', 'Emergency'});
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getIt<AddClinicCubit>()),
              BlocProvider(create: (context) => getIt<ClinicManagementCubit>()),
            ],
            child: AppointmentDetailsPage(
              enabledAppointmentTypes: enabledTypes,
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
            : const {'InClinic', 'VideoCall', 'HomeVisit', 'FollowUp', 'Emergency'};
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<ClinicManagementCubit>(),
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
              specialization: data is Map && data['specialization'] != null
                  ? data['specialization'] as String
                  : null,
              clinicName: data is Map && data['clinicName'] != null
                  ? data['clinicName'] as String
                  : null,
              rating: data is Map && data['rating'] != null
                  ? (data['rating'] as num).toDouble()
                  : null,
              reviewsCount: data is Map && data['reviewsCount'] != null
                  ? (data['reviewsCount'] as num).toInt()
                  : null,
              yearsOfExperience:
                  data is Map && data['yearsOfExperience'] != null
                  ? (data['yearsOfExperience'] as num).toInt()
                  : null,
              patientsCount: data is Map && data['patientsCount'] != null
                  ? (data['patientsCount'] as num).toInt()
                  : null,
              enabledAppointmentTypes: enabledTypes,
              clinicFee: data is Map && data['clinicFee'] != null
                  ? (data['clinicFee'] as num).toDouble()
                  : null,
              onlineFee: data is Map && data['onlineFee'] != null
                  ? (data['onlineFee'] as num).toDouble()
                  : null,
              homeVisitFee: data is Map && data['homeVisitFee'] != null
                  ? (data['homeVisitFee'] as num).toDouble()
                  : null,
              followUpFee: data is Map && data['followUpFee'] != null
                  ? (data['followUpFee'] as num).toDouble()
                  : null,
              emergencyFee: data is Map && data['emergencyFee'] != null
                  ? (data['emergencyFee'] as num).toDouble()
                  : null,
            ),
          ),
        );
      case AppRoutes.bookingInformation:
        final args = settings.arguments;
        final data = args is Map ? args : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<FamilyCubit>()),
              BlocProvider(create: (_) => getIt<UserManagementCubit>()),
            ],
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
              doctorImage: data is Map && data['doctorImage'] != null
                  ? data['doctorImage'] as String
                  : null,
              specialization: data is Map && data['specialization'] != null
                  ? data['specialization'] as String
                  : null,
              clinicName: data is Map && data['clinicName'] != null
                  ? data['clinicName'] as String
                  : null,
              rating: data is Map && data['rating'] != null
                  ? (data['rating'] as num).toDouble()
                  : null,
              reviewsCount: data is Map && data['reviewsCount'] != null
                  ? (data['reviewsCount'] as num).toInt()
                  : null,
              yearsOfExperience: data is Map && data['yearsOfExperience'] != null
                  ? (data['yearsOfExperience'] as num).toInt()
                  : null,
              patientsCount: data is Map && data['patientsCount'] != null
                  ? (data['patientsCount'] as num).toInt()
                  : null,
              consultationFee: data is Map && data['consultationFee'] != null
                  ? (data['consultationFee'] as num).toDouble()
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
            consultationFee: data is Map && data['consultationFee'] != null
                ? (data['consultationFee'] as num).toDouble()
                : null,
          ),
        );
      case AppRoutes.doctorChatRoom:
        final args = settings.arguments;
        final data = args is Map ? args : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<ChatCubit>(),
            child: DoctorChatRoomScreen(
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
              doctorId: data is Map && data['doctorId'] != null
                  ? data['doctorId'] as String
                  : null,
              patientId: data is Map && data['patientId'] != null
                  ? data['patientId'] as String
                  : null,
              appointmentDate: data is Map && data['appointmentDate'] != null
                  ? data['appointmentDate'] as String
                  : null,
              patientImageUrl: data is Map && data['patientImageUrl'] != null
                  ? data['patientImageUrl'] as String
                  : null,
            ),
          ),
        );
      case AppRoutes.clinicManagement:
        return MaterialPageRoute(
          builder: (_) => ClinicManagementPage(),
          settings: settings,
        );
      case AppRoutes.clinicSchedule:
        final scheduleArgs = settings.arguments;
        final scheduleData = scheduleArgs is Map ? scheduleArgs : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<ClinicManagementCubit>(),
            child: ClinicScheduleManagementView(
              clinicId: scheduleData != null && scheduleData['clinicId'] != null
                  ? scheduleData['clinicId'] as int
                  : null,
              isOwner: scheduleData != null && scheduleData['isOwner'] == true,
              currentDoctorId:
                  scheduleData != null &&
                      scheduleData['currentDoctorId'] != null
                  ? scheduleData['currentDoctorId'] as String
                  : null,
            ),
          ),
        );
      case AppRoutes.clinicPaymentSettings:
        final billingArgs = settings.arguments;
        final billingClinicId = billingArgs is Map && billingArgs['clinicId'] != null
            ? (billingArgs['clinicId'] as num).toInt()
            : 0;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<WalletCubit>()),
              BlocProvider(create: (_) => getIt<InvoicesCubit>()),
            ],
            child: ClinicPaymentSettingsView(clinicId: billingClinicId),
          ),
        );
      case AppRoutes.bookingConfirmation:
        final args = settings.arguments;
        final data = args is Map ? args : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BookingConfirmationPage(
            appointmentId: data is Map && data['appointmentId'] != null
                ? (data['appointmentId'] as num).toInt()
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
                ? (data['rating'] as num).toDouble()
                : null,
            doctorImage: data is Map && data['doctorImage'] != null
                ? data['doctorImage'] as String
                : null,
            yearsOfExperience: data is Map && data['yearsOfExperience'] != null
                ? (data['yearsOfExperience'] as num).toInt()
                : null,
            patientsCount: data is Map && data['patientsCount'] != null
                ? (data['patientsCount'] as num).toInt()
                : null,
            reviewsCount: data is Map && data['reviewsCount'] != null
                ? (data['reviewsCount'] as num).toInt()
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
            consultationFee: data is Map && data['consultationFee'] != null
                ? (data['consultationFee'] as num).toDouble()
                : null,
            meetingLink: data is Map && data['meetingLink'] != null
                ? data['meetingLink'] as String
                : null,
          ),
        );
      case AppRoutes.medicalFacilityManagement:
        final args = data is Map<String, dynamic> ? data : <String, dynamic>{};
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<UploadCredentialsCubit>(),
            child: MedicalFacilityManagementPage(
              redirectOnExistingClinics:
                  args['redirectOnExistingClinics'] as bool? ?? true,
            ),
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
      case AppRoutes.emergencySearch:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<DoctorsCubit>(),
            child: const EmergencySearchScreen(),
          ),
        );
      case AppRoutes.wallet:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<WalletCubit>(),
            child: const WalletScreen(),
          ),
        );
      case AppRoutes.employment:
        final args = settings.arguments;
        final clinicId = args is Map && args['clinicId'] != null
            ? (args['clinicId'] as num).toInt()
            : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<ClinicManagementCubit>(),
            child: EmploymentScreen(clinicId: clinicId),
          ),
        );
      case AppRoutes.userManagement:
        return MaterialPageRoute(builder: (_) => const UserManagementPage());
      case AppRoutes.prescriptions:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<PrescriptionsCubit>()),
              BlocProvider(create: (_) => getIt<AppointmentsCubit>()),
            ],
            child: const PrescriptionsScreen(),
          ),
        );
      case AppRoutes.prescriptionDetail:
        final args = settings.arguments;
        final prescId = args is Map && args['id'] != null
            ? (args['id'] as num).toInt()
            : 0;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<PrescriptionsCubit>(),
            child: PrescriptionDetailScreen(prescriptionId: prescId),
          ),
        );
      case AppRoutes.addPrescription:
        return MaterialPageRoute(
          builder: (_) => const AddPrescriptionScreen(),
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
