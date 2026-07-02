import 'package:dartz/dartz.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/features/clinic_admin/data/model/clinic_admin_request_model.dart';
import 'package:smartclinic/features/clinic_admin/data/model/clinic_admin_response_model.dart';
import '../api/clinic_admin_api_service.dart';

abstract class ClinicAdminRepo {
  Future<Either<String, TodayQueueResponseModel>> getTodayQueue(int clinicId);
  Future<Either<String, ClinicStaffResponseModel>> getClinicStaff(int clinicId);
  Future<Either<String, RemoveDoctorResponseModel>> removeDoctor(
    RemoveDoctorRequestModel request,
  );
  Future<Either<String, FindDoctorResponseModel>> findDoctor(
    String contactInfo,
  );
  Future<Either<String, CollectPaymentResponseModel>> collectPayment(
    int invoiceId,
  );
  Future<Either<String, FullDashboardResponseModel>> getFullDashboard(
    int clinicId,
  );
}

class ClinicAdminRepoImpl implements ClinicAdminRepo {
  final ClinicAdminApiService _api;
  ClinicAdminRepoImpl(this._api);

  @override
  Future<Either<String, TodayQueueResponseModel>> getTodayQueue(
    int clinicId,
  ) async {
    try {
      return Right(await _api.getTodayQueue(clinicId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, ClinicStaffResponseModel>> getClinicStaff(
    int clinicId,
  ) async {
    try {
      return Right(await _api.getClinicStaff(clinicId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, RemoveDoctorResponseModel>> removeDoctor(
    RemoveDoctorRequestModel request,
  ) async {
    try {
      return Right(await _api.removeDoctor(request));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, FindDoctorResponseModel>> findDoctor(
    String contactInfo,
  ) async {
    try {
      return Right(await _api.findDoctor(contactInfo));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, CollectPaymentResponseModel>> collectPayment(
    int invoiceId,
  ) async {
    try {
      return Right(await _api.collectPayment(invoiceId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, FullDashboardResponseModel>> getFullDashboard(
    int clinicId,
  ) async {
    try {
      return Right(await _api.getFullDashboard(clinicId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
