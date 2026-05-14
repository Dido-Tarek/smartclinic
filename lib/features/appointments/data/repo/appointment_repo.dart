import 'package:dartz/dartz.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/features/appointments/data/api/appointment_api_service.dart';
import 'package:smartclinic/features/appointments/data/model/appointment_request_model.dart';
import 'package:smartclinic/features/appointments/data/model/appointment_response_model.dart';

abstract class AppointmentsRepo {
  Future<Either<String, BookAppointmentResponseModel>> bookAppointment(
    BookAppointmentRequestModel request,
  );

  Future<Either<String, MyAppointmentsResponseModel>> getMyAppointments();

  Future<Either<String, DoctorRequestsResponseModel>> getDoctorRequests(
    int clinicId,
  );

  Future<Either<String, UpdateAppointmentStatusResponseModel>>
  updateAppointmentStatus({
    required int id,
    required UpdateAppointmentStatusRequestModel request,
  });

  Future<Either<String, CancelAppointmentResponseModel>> cancelMyAppointment(
    int id,
  );

  Future<Either<String, AvailableSlotsResponseModel>> getAvailableSlots({
    required String doctorId,
    required int clinicId,
    required String date,
  });

  Future<Either<String, QueuePositionResponseModel>> getQueuePosition(
    int appointmentId,
  );
}

class AppointmentsRepoImpl implements AppointmentsRepo {
  final AppointmentsApiService _apiService;

  AppointmentsRepoImpl(this._apiService);

  @override
  Future<Either<String, BookAppointmentResponseModel>> bookAppointment(
    BookAppointmentRequestModel request,
  ) async {
    try {
      return Right(await _apiService.bookAppointment(request));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, MyAppointmentsResponseModel>>
  getMyAppointments() async {
    try {
      return Right(await _apiService.getMyAppointments());
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, DoctorRequestsResponseModel>> getDoctorRequests(
    int clinicId,
  ) async {
    try {
      return Right(await _apiService.getDoctorRequests(clinicId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, UpdateAppointmentStatusResponseModel>>
  updateAppointmentStatus({
    required int id,
    required UpdateAppointmentStatusRequestModel request,
  }) async {
    try {
      return Right(
        await _apiService.updateAppointmentStatus(id: id, request: request),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, CancelAppointmentResponseModel>> cancelMyAppointment(
    int id,
  ) async {
    try {
      return Right(await _apiService.cancelMyAppointment(id));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, AvailableSlotsResponseModel>> getAvailableSlots({
    required String doctorId,
    required int clinicId,
    required String date,
  }) async {
    try {
      return Right(
        await _apiService.getAvailableSlots(
          doctorId: doctorId,
          clinicId: clinicId,
          date: date,
        ),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, QueuePositionResponseModel>> getQueuePosition(
    int appointmentId,
  ) async {
    try {
      return Right(await _apiService.getQueuePosition(appointmentId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
