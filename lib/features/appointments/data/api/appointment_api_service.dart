import 'package:dio/dio.dart';
import 'package:smartclinic/features/appointments/data/model/appointment_request_model.dart';
import 'package:smartclinic/features/appointments/data/model/appointment_response_model.dart';

class AppointmentsApiService {
  final Dio _dio;

  AppointmentsApiService(this._dio);

  static const String _base = '/api/Appointments';

  // ── POST /api/Appointments/book ──────────────────────────────────────────
  Future<BookAppointmentResponseModel> bookAppointment(
    BookAppointmentRequestModel request,
  ) async {
    final response = await _dio.post('$_base/book', data: request.toJson());
    return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── GET /api/Appointments/my-appointments ────────────────────────────────
  Future<MyAppointmentsResponseModel> getMyAppointments() async {
    final response = await _dio.get('$_base/my-appointments');
    if (response.data is List) {
      return MyAppointmentsResponseModel.fromList(
        response.data as List<dynamic>,
      );
    }
    return MyAppointmentsResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── GET /api/Appointments/doctor-requests/{clinicId} ────────────────────
  Future<DoctorRequestsResponseModel> getDoctorRequests(int clinicId) async {
    final response = await _dio.get('$_base/doctor-requests/$clinicId');
    if (response.data is List) {
      return MyAppointmentsResponseModel.fromList(
        response.data as List<dynamic>,
      );
    }
    return MyAppointmentsResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── PUT /api/Appointments/update-status/{id} ─────────────────────────────
  Future<UpdateAppointmentStatusResponseModel> updateAppointmentStatus({
    required int id,
    required UpdateAppointmentStatusRequestModel request,
  }) async {
    final response = await _dio.put(
      '$_base/update-status/$id',
      data: request.toJson(),
    );
    return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── PUT /api/Appointments/cancel-my-appointment/{id} ────────────────────
  Future<CancelAppointmentResponseModel> cancelMyAppointment(int id) async {
    final response = await _dio.put('$_base/cancel-my-appointment/$id');
    return CancelAppointmentResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── GET /api/Appointments/available-slots ────────────────────────────────
  Future<AvailableSlotsResponseModel> getAvailableSlots({
    required String doctorId,
    required int clinicId,
    required String date,
  }) async {
    final response = await _dio.get(
      '$_base/available-slots',
      queryParameters: {
        'doctorId': doctorId,
        'clinicId': clinicId,
        'date': date,
      },
    );
    if (response.data is List) {
      return AvailableSlotsResponseModel.fromList(
        response.data as List<dynamic>,
      );
    }
    return AvailableSlotsResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── GET /api/Appointments/queue-position/{appointmentId} ─────────────────
  Future<QueuePositionResponseModel> getQueuePosition(int appointmentId) async {
    final response = await _dio.get('$_base/queue-position/$appointmentId');
    return QueuePositionResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
