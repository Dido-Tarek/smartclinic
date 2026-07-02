import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:smartclinic/features/clinic_admin/data/model/clinic_admin_request_model.dart';
import 'package:smartclinic/features/clinic_admin/data/model/clinic_admin_response_model.dart';
import 'package:smartclinic/features/clinic_admin/data/repo/clinic_admin_repo.dart';
import 'package:smartclinic/features/clinic_admin/presentation/manager/clinic_admin_cubit.dart';
import 'package:smartclinic/features/home/presentation/screens/hospital_home_screen.dart';

class _FakeClinicAdminRepo implements ClinicAdminRepo {
  @override
  Future<Either<String, CollectPaymentResponseModel>> collectPayment(
    int invoiceId,
  ) async {
    return const Right(
      CollectPaymentResponseModel(message: 'ok', success: true),
    );
  }

  @override
  Future<Either<String, ClinicStaffResponseModel>> getClinicStaff(
    int clinicId,
  ) async {
    return const Right(ClinicStaffResponseModel(staff: []));
  }

  @override
  Future<Either<String, FindDoctorResponseModel>> findDoctor(
    String contactInfo,
  ) async {
    return const Right(FindDoctorResponseModel(doctors: []));
  }

  @override
  Future<Either<String, FullDashboardResponseModel>> getFullDashboard(
    int clinicId,
  ) async {
    return const Right(ClinicDashboardModel());
  }

  @override
  Future<Either<String, RemoveDoctorResponseModel>> removeDoctor(
    RemoveDoctorRequestModel request,
  ) async {
    return const Right(RemoveDoctorResponseModel(message: 'ok'));
  }

  @override
  Future<Either<String, TodayQueueResponseModel>> getTodayQueue(
    int clinicId,
  ) async {
    return const Right(TodayQueueResponseModel(queue: []));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HospitalHomePage renders with a clinic admin cubit', (
    WidgetTester tester,
  ) async {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<ClinicAdminRepo>()) {
      getIt.unregister<ClinicAdminRepo>();
    }
    if (getIt.isRegistered<ClinicAdminCubit>()) {
      getIt.unregister<ClinicAdminCubit>();
    }
    getIt.registerSingleton<ClinicAdminRepo>(_FakeClinicAdminRepo());
    getIt.registerFactory<ClinicAdminCubit>(
      () => ClinicAdminCubit(getIt<ClinicAdminRepo>()),
    );

    await tester.pumpWidget(
      MaterialApp(home: const HospitalHomePage(clinicId: 42)),
    );
    await tester.pump();

    expect(find.byType(HospitalHomePage), findsOneWidget);
  });
}
