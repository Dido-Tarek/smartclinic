import 'package:dartz/dartz.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_request_model.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_response_model.dart';
import '../api/clinic_management_api_service.dart';

abstract class ClinicManagementRepo {
  Future<Either<String, SendEmploymentResponseModel>> sendEmploymentRequest(
    SendEmploymentRequestModel request,
  );

  Future<Either<String, MyEmploymentRequestsResponseModel>>
  getMyEmploymentRequests();

  Future<Either<String, RespondToEmploymentResponseModel>> respondToEmployment(
    RespondToEmploymentRequestModel request,
  );

  Future<Either<String, MyClinicsResponseModel>> getMyClinics();

  Future<Either<String, RemoveClinicResponseModel>> removeClinic(int clinicId);

  Future<Either<String, UpdateClinicProfileResponseModel>> updateClinicProfile(
    UpdateClinicProfileRequestModel request,
  );

  Future<Either<String, UpdateFinancialTermsResponseModel>>
  updateFinancialTerms(UpdateFinancialTermsRequestModel request);

  Future<Either<String, UpdateDoctorScheduleResponseModel>>
  updateDoctorSchedule(UpdateDoctorScheduleRequestModel request);

  Future<Either<String, AddScheduleResponseModel>> addSchedule(
    AddScheduleRequestModel request,
  );

  Future<Either<String, DeleteScheduleResponseModel>> deleteSchedule(int id);

  Future<Either<String, DoctorAvailabilityResponseModel>> getDoctorAvailability(
    String doctorId,
  );
}

class ClinicManagementRepoImpl implements ClinicManagementRepo {
  final ClinicManagementApiService _api;
  ClinicManagementRepoImpl(this._api);

  @override
  Future<Either<String, SendEmploymentResponseModel>> sendEmploymentRequest(
    SendEmploymentRequestModel request,
  ) async {
    try {
      return Right(await _api.sendEmploymentRequest(request));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, MyEmploymentRequestsResponseModel>>
  getMyEmploymentRequests() async {
    try {
      return Right(await _api.getMyEmploymentRequests());
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, RespondToEmploymentResponseModel>> respondToEmployment(
    RespondToEmploymentRequestModel request,
  ) async {
    try {
      return Right(await _api.respondToEmployment(request));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, MyClinicsResponseModel>> getMyClinics() async {
    try {
      return Right(await _api.getMyClinics());
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, RemoveClinicResponseModel>> removeClinic(
    int clinicId,
  ) async {
    try {
      return Right(await _api.removeClinic(clinicId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, UpdateClinicProfileResponseModel>> updateClinicProfile(
    UpdateClinicProfileRequestModel request,
  ) async {
    try {
      return Right(await _api.updateClinicProfile(request));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, UpdateFinancialTermsResponseModel>>
  updateFinancialTerms(UpdateFinancialTermsRequestModel request) async {
    try {
      return Right(await _api.updateFinancialTerms(request));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, UpdateDoctorScheduleResponseModel>>
  updateDoctorSchedule(UpdateDoctorScheduleRequestModel request) async {
    try {
      return Right(await _api.updateDoctorSchedule(request));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, AddScheduleResponseModel>> addSchedule(
    AddScheduleRequestModel request,
  ) async {
    try {
      return Right(await _api.addSchedule(request));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, DeleteScheduleResponseModel>> deleteSchedule(
    int id,
  ) async {
    try {
      return Right(await _api.deleteSchedule(id));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, DoctorAvailabilityResponseModel>> getDoctorAvailability(
    String doctorId,
  ) async {
    try {
      return Right(await _api.getDoctorAvailability(doctorId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
