import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:smartclinic/core/helper/shared_preds_helper.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/network/dio_factory.dart';
import 'package:smartclinic/features/auth/data/api/auth_api_service.dart';
import 'package:smartclinic/features/auth/domain/auth_repo.dart';
import 'package:smartclinic/features/auth/domain/auth_repo_impl.dart';
import 'package:smartclinic/features/auth/presentation/manager/login_cubit.dart';
import 'package:smartclinic/features/auth/presentation/manager/register_cubit.dart';
import 'package:smartclinic/features/auth/presentation/manager/upload_credentials_cubit.dart';
import 'package:smartclinic/features/chat/data/api/chat_api_service.dart';
import 'package:smartclinic/features/chat/data/repo/chat_repo.dart';
import 'package:smartclinic/features/chat/presentation/manager/chat_cubit.dart';
import 'package:smartclinic/features/clinic/data/api/clinic_api_service.dart';
import 'package:smartclinic/features/clinic/domain/facility_repo.dart';
import 'package:smartclinic/features/clinic/domain/facility_repo_impl.dart';
import 'package:smartclinic/features/clinic/presentation/manager/add_clinic_cubit.dart';
import 'package:smartclinic/features/family_members/data/api/family_member_api_service.dart';
import 'package:smartclinic/features/family_members/data/repo/family_member_repo.dart';
import 'package:smartclinic/features/family_members/presentation/manager/family_member_cubit.dart';
import 'package:smartclinic/features/health_issues/data/api/health_issues_api_service.dart';
import 'package:smartclinic/features/health_issues/data/repo/health_issues_repo_impl.dart';
import 'package:smartclinic/features/health_issues/domain/repo/health_issues_repo.dart';
import 'package:smartclinic/features/health_issues/presentation/manager/health_issues_cubit.dart';
import 'package:smartclinic/features/medical_records/data/api/medical_records_api_service.dart';
import 'package:smartclinic/features/medical_records/data/repos/medical_records_repo_impl.dart';
import 'package:smartclinic/features/medical_records/domain/repos/medical_records_repo.dart';
import 'package:smartclinic/features/medical_records/presentation/manager/medical_records_cubit.dart';
import 'package:smartclinic/features/notification/data/api/notifications_api_service.dart';
import 'package:smartclinic/features/notification/domain/repo/notifications_repo.dart';
import 'package:smartclinic/features/notification/domain/repo/notifications_repo_impl.dart';
import 'package:smartclinic/features/notification/presentation/manager/notifications_cubit.dart';
import 'package:smartclinic/features/nouga/data/api/nouga_ai_api_service.dart';
import 'package:smartclinic/features/nouga/data/local/nouga_conversation_store.dart';
import 'package:smartclinic/features/nouga/data/repo/nouga_ai_repo.dart';
import 'package:smartclinic/features/nouga/presentation/manager/nouga_ai_cubit.dart';
import 'package:smartclinic/features/search/data/api/doctors_api_service.dart';
import 'package:smartclinic/features/search/data/repo/search_doctors_repo.dart';
import 'package:smartclinic/features/search/presentation/manager/search_doctors_cubit.dart';
import 'package:smartclinic/features/user_management/data/api/user_management_api_service.dart';
import 'package:smartclinic/features/user_management/data/repo/user_management_repo.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_cubit.dart';
import 'package:smartclinic/features/wallet/data/api/wallet_api_service.dart';
import 'package:smartclinic/features/wallet/data/repo/wallet_repo.dart';
import 'package:smartclinic/features/wallet/presentation/manager/wallet_cubit.dart';
import 'package:smartclinic/features/invoices/data/api/invoices_api_service.dart';
import 'package:smartclinic/features/invoices/data/repo/invoices_repo.dart';
import 'package:smartclinic/features/invoices/presentation/manager/invoices_cubit.dart';
import 'package:smartclinic/features/appointments/data/api/appointment_api_service.dart';
import 'package:smartclinic/features/appointments/data/repo/appointment_repo.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_cubit.dart';
import 'package:smartclinic/features/prescriptions/data/api/prescription_api_service.dart';
import 'package:smartclinic/features/prescriptions/data/repo/prescription_repo.dart';
import 'package:smartclinic/features/prescriptions/presentation/manager/prescriptions_cubit.dart';
import 'package:smartclinic/features/clinic_admin/data/api/clinic_admin_api_service.dart';
import 'package:smartclinic/features/clinic_admin/data/repo/clinic_admin_repo.dart';
import 'package:smartclinic/features/clinic_admin/presentation/manager/clinic_admin_cubit.dart';
import 'package:smartclinic/features/clinic_management/data/api/clinic_management_api_service.dart';
import 'package:smartclinic/features/clinic_management/data/repo/clinic_management_repo.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // 1. Core & Helpers (الأساسيات)
  // SharedPrefsHelper هو المسؤول الوحيد عن التعامل مع المكتبة
  getIt.registerLazySingleton<SharedPrefsHelper>(() => SharedPrefsHelper());

  // UserSession يعتمد على الـ Helper لإدارة الجلسة
  getIt.registerLazySingleton<UserSession>(() => UserSession());

  // 2. Network (Dio & DioClient)
  // بنسجل الـ Dio اللي جواه الـ Interceptors (الـ AuthInterceptor)
  getIt.registerLazySingleton<Dio>(() => DioFactory.getDio());

  // 3. API Services (Retrofit)
  // ملحوظة: بنمرر getIt<Dio>() اللي متسجل فوق عشان الـ Interceptor يشتغل
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<FamilyApiService>(
    () => FamilyApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<HealthIssuesApiService>(
    () => HealthIssuesApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<MedicalRecordsApiService>(
    () => MedicalRecordsApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ClinicApiService>(
    () => ClinicApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<NotificationsApiService>(
    () => NotificationsApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<MedicalChatApiService>(
    () => MedicalChatApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ChatApiService>(
    () => ChatApiService(getIt<Dio>()),
  );

  // 4. Repositories (Domain & Data)
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(getIt<AuthApiService>()),
  );
  getIt.registerLazySingleton<FamilyRepo>(
    () => FamilyRepoImpl(getIt<FamilyApiService>()),
  );
  getIt.registerLazySingleton<HealthIssuesRepo>(
    () => HealthIssuesRepoImpl(getIt<HealthIssuesApiService>()),
  );
  getIt.registerLazySingleton<MedicalRecordsRepo>(
    () => MedicalRecordsRepoImpl(getIt<MedicalRecordsApiService>()),
  );
  getIt.registerLazySingleton<FacilityRepo>(
    () => FacilityRepoImpl(getIt<ClinicApiService>()),
  );
  getIt.registerLazySingleton<NotificationsRepo>(
    () => NotificationsRepoImpl(getIt<NotificationsApiService>()),
  );
  getIt.registerLazySingleton<MedicalChatRepo>(
    () => MedicalChatRepoImpl(getIt<MedicalChatApiService>()),
  );
  getIt.registerLazySingleton<NougaConversationStore>(
    () => NougaConversationStore(),
  );
  getIt.registerLazySingleton<ChatRepo>(
    () => ChatRepo(getIt<ChatApiService>()),
  );
  getIt.registerLazySingleton<DoctorsApiService>(
    () => DoctorsApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<DoctorsRepo>(
    () => DoctorsRepoImpl(getIt<DoctorsApiService>()),
  );
  getIt.registerLazySingleton<UserManagementApiService>(
    () => UserManagementApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<WalletApiService>(
    () => WalletApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<UserManagementRepo>(
    () => UserManagementRepo(getIt<UserManagementApiService>()),
  );
  getIt.registerLazySingleton<WalletRepo>(
    () => WalletRepoImpl(getIt<WalletApiService>()),
  );
  // Invoices
  getIt.registerLazySingleton<InvoicesApiService>(
    () => InvoicesApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<InvoicesRepo>(
    () => InvoicesRepoImpl(getIt<InvoicesApiService>()),
  );

  // 5. Cubits (Factory لضمان حالة جديدة مع كل شاشة)
  getIt.registerFactory<RegisterCubit>(() => RegisterCubit(getIt<AuthRepo>()));
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt<AuthRepo>()));
  getIt.registerFactory<FamilyCubit>(() => FamilyCubit(getIt<FamilyRepo>()));
  getIt.registerFactory<HealthIssuesCubit>(
    () => HealthIssuesCubit(getIt<HealthIssuesRepo>()),
  );
  getIt.registerFactory<MedicalRecordsCubit>(
    () => MedicalRecordsCubit(getIt<MedicalRecordsRepo>()),
  );
  getIt.registerFactory<UploadCredentialsCubit>(
    () => UploadCredentialsCubit(getIt()),
  );
  getIt.registerFactory<AddClinicCubit>(
    () => AddClinicCubit(getIt<FacilityRepo>()),
  );
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(getIt<NotificationsRepo>()),
  );
  getIt.registerFactory<SendMessageCubit>(
    () => SendMessageCubit(getIt<MedicalChatRepo>()),
  );
  getIt.registerFactory<ChatCubit>(() => ChatCubit(getIt<ChatRepo>()));
  getIt.registerFactory<DoctorsCubit>(() => DoctorsCubit(getIt<DoctorsRepo>()));
  getIt.registerFactory<UserManagementCubit>(
    () => UserManagementCubit(getIt<UserManagementRepo>()),
  );
  getIt.registerFactory<WalletCubit>(() => WalletCubit(getIt<WalletRepo>()));
  getIt.registerFactory<InvoicesCubit>(() => InvoicesCubit(getIt<InvoicesRepo>()));

  // Clinic admin
  getIt.registerLazySingleton<ClinicAdminApiService>(
    () => ClinicAdminApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ClinicAdminRepo>(
    () => ClinicAdminRepoImpl(getIt<ClinicAdminApiService>()),
  );
  getIt.registerFactory<ClinicAdminCubit>(
    () => ClinicAdminCubit(getIt<ClinicAdminRepo>()),
  );

  // Clinic management
  getIt.registerLazySingleton<ClinicManagementApiService>(
    () => ClinicManagementApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ClinicManagementRepo>(
    () => ClinicManagementRepoImpl(getIt<ClinicManagementApiService>()),
  );
  getIt.registerFactory<ClinicManagementCubit>(
    () => ClinicManagementCubit(getIt<ClinicManagementRepo>()),
  );
  // Appointments
  getIt.registerLazySingleton<AppointmentsApiService>(
    () => AppointmentsApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AppointmentsRepo>(
    () => AppointmentsRepoImpl(getIt<AppointmentsApiService>()),
  );
  getIt.registerFactory<AppointmentsCubit>(() => AppointmentsCubit(getIt<AppointmentsRepo>()));
  // Prescriptions
  getIt.registerLazySingleton<PrescriptionsApiService>(
    () => PrescriptionsApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<PrescriptionsRepo>(
    () => PrescriptionsRepoImpl(getIt<PrescriptionsApiService>()),
  );
  getIt.registerFactory<PrescriptionsCubit>(
    () => PrescriptionsCubit(getIt<PrescriptionsRepo>()),
  );
}
