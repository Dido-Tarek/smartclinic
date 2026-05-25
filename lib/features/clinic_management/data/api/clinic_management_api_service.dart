import 'package:dio/dio.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_request_model.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_response_model.dart';

class ClinicManagementApiService {
  final Dio _dio;

  ClinicManagementApiService(this._dio);

  static const String _clinics = '/api/Clinics';
  static const String _schedules = '/api/Schedules';

  // ── POST /api/Clinics/send-employment-request ────────────────────────────
  Future<SendEmploymentResponseModel> sendEmploymentRequest(
    SendEmploymentRequestModel request,
  ) async {
    final response = await _dio.post(
      '$_clinics/send-employment-request',
      data: request.toJson(),
    );
    return EmploymentRequestModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── GET /api/Clinics/my-employment-requests ──────────────────────────────
  Future<MyEmploymentRequestsResponseModel> getMyEmploymentRequests() async {
    final response = await _dio.get('$_clinics/my-employment-requests');
    if (response.data is List) {
      return MyEmploymentRequestsResponseModel.fromList(
        response.data as List<dynamic>,
      );
    }
    return MyEmploymentRequestsResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── POST /api/Clinics/respond-to-employment ──────────────────────────────
  Future<RespondToEmploymentResponseModel> respondToEmployment(
    RespondToEmploymentRequestModel request,
  ) async {
    final response = await _dio.post(
      '$_clinics/respond-to-employment',
      data: request.toJson(),
    );
    return EmploymentRequestModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── GET /api/Clinics/my-clinics ──────────────────────────────────────────
  Future<MyClinicsResponseModel> getMyClinics() async {
    final response = await _dio.get('$_clinics/my-clinics');
    if (response.data is List) {
      return MyClinicsResponseModel.fromList(response.data as List<dynamic>);
    }
    return MyClinicsResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── DELETE /api/Clinics/remove-clinic/{clinicId} ─────────────────────────
  Future<RemoveClinicResponseModel> removeClinic(int clinicId) async {
    final response = await _dio.delete('$_clinics/remove-clinic/$clinicId');
    if (response.data == null || response.data is! Map) {
      return const RemoveClinicResponseModel(
        message: 'Clinic removed successfully',
      );
    }
    return RemoveClinicResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── PUT /api/Clinics/update-clinic-profile (multipart) ───────────────────
  Future<UpdateClinicProfileResponseModel> updateClinicProfile(
    UpdateClinicProfileRequestModel request,
  ) async {
    final formData = FormData.fromMap({
      'ClinicId': request.clinicId,
      if (request.name != null) 'Name': request.name,
      if (request.address != null) 'Address': request.address,
      if (request.phoneNumber != null) 'PhoneNumber': request.phoneNumber,
      if (request.city != null) 'City': request.city,
      if (request.area != null) 'Area': request.area,
      if (request.specialization != null) 'Specialization': request.specialization,
      if (request.latitude != null) 'Latitude': request.latitude,
      if (request.longitude != null) 'Longitude': request.longitude,
      if (request.sessionDuration != null) 'SessionDuration': request.sessionDuration,
      if (request.clinicFee != null) 'ClinicFee': request.clinicFee,
      if (request.onlineFee != null) 'OnlineFee': request.onlineFee,
      if (request.homeVisitFee != null) 'HomeVisitFee': request.homeVisitFee,
      if (request.followUpFee != null) 'FollowUpFee': request.followUpFee,
      if (request.emergencyFee != null) 'EmergencyFee': request.emergencyFee,
      if (request.clinicImagePath != null)
        'ClinicImage': await MultipartFile.fromFile(
          request.clinicImagePath!,
          filename: request.clinicImagePath!.split('/').last,
        ),
    });

    final response = await _dio.put(
      '$_clinics/update-clinic-profile',
      data: formData,
    );
    return ClinicModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── PUT /api/Clinics/update-financial-terms ──────────────────────────────
  Future<UpdateFinancialTermsResponseModel> updateFinancialTerms(
    UpdateFinancialTermsRequestModel request,
  ) async {
    final response = await _dio.put(
      '$_clinics/update-financial-terms',
      data: request.toJson(),
    );
    return EmploymentRequestModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── PUT /api/Clinics/update-doctor-schedule ──────────────────────────────
  Future<UpdateDoctorScheduleResponseModel> updateDoctorSchedule(
    UpdateDoctorScheduleRequestModel request,
  ) async {
    final response = await _dio.put(
      '$_clinics/update-doctor-schedule',
      data: request.toJson(),
    );
    return EmploymentRequestModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── POST /api/Schedules/add-schedule ─────────────────────────────────────
  Future<AddScheduleResponseModel> addSchedule(
    AddScheduleRequestModel request,
  ) async {
    final response = await _dio.post(
      '$_schedules/add-schedule',
      data: request.toJson(),
    );
    return ScheduleModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── DELETE /api/Schedules/delete-schedule/{id} ───────────────────────────
  Future<DeleteScheduleResponseModel> deleteSchedule(int id) async {
    final response = await _dio.delete('$_schedules/delete-schedule/$id');
    if (response.data == null || response.data is! Map) {
      return const DeleteScheduleResponseModel(
        message: 'Schedule deleted successfully',
      );
    }
    return DeleteScheduleResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── GET /api/Schedules/doctor-availability/{doctorId} ────────────────────
  Future<DoctorAvailabilityResponseModel> getDoctorAvailability(
    String doctorId,
  ) async {
    final response = await _dio.get(
      '$_schedules/doctor-availability/$doctorId',
    );
    if (response.data is List) {
      return DoctorAvailabilityResponseModel.fromList(
        response.data as List<dynamic>,
      );
    }
    return DoctorAvailabilityResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
