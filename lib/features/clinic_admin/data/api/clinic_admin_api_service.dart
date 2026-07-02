import 'package:dio/dio.dart';
import 'package:smartclinic/features/clinic_admin/data/model/clinic_admin_response_model.dart';
import '../model/clinic_admin_request_model.dart';

class ClinicAdminApiService {
  final Dio _dio;

  ClinicAdminApiService(this._dio);

  static const String _base = '/api/ClinicAdmin';

  // ── GET /api/ClinicAdmin/today-queue/{clinicId} ──────────────────────────
  Future<TodayQueueResponseModel> getTodayQueue(int clinicId) async {
    final response = await _dio.get('$_base/today-queue/$clinicId');
    if (response.data is List) {
      return TodayQueueResponseModel.fromList(response.data as List<dynamic>);
    }
    return TodayQueueResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── GET /api/ClinicAdmin/{clinicId}/staff ────────────────────────────────
  Future<ClinicStaffResponseModel> getClinicStaff(int clinicId) async {
    final response = await _dio.get('$_base/$clinicId/staff');
    if (response.data is List) {
      return ClinicStaffResponseModel.fromList(response.data as List<dynamic>);
    }
    return ClinicStaffResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── DELETE /api/ClinicAdmin/remove-doctor ────────────────────────────────
  Future<RemoveDoctorResponseModel> removeDoctor(
    RemoveDoctorRequestModel request,
  ) async {
    final response = await _dio.delete(
      '$_base/remove-doctor',
      queryParameters: request.toQueryParams(),
    );
    if (response.data == null || response.data is! Map) {
      return const RemoveDoctorResponseModel(
        message: 'Doctor removed successfully',
      );
    }
    return RemoveDoctorResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── GET /api/ClinicAdmin/find-doctor ─────────────────────────────────────
  Future<FindDoctorResponseModel> findDoctor(String contactInfo) async {
    final response = await _dio.get(
      '$_base/find-doctor',
      queryParameters: {'contactInfo': contactInfo},
    );
    if (response.data is List) {
      return FindDoctorResponseModel.fromList(response.data as List<dynamic>);
    }
    // Some backends return a single object when there's one result
    return FindDoctorResponseModel.fromSingle(
      response.data as Map<String, dynamic>,
    );
  }

  // ── PUT /api/ClinicAdmin/collect-payment/{invoiceId} ─────────────────────
  Future<CollectPaymentResponseModel> collectPayment(int invoiceId) async {
    final response = await _dio.put('$_base/collect-payment/$invoiceId');
    if (response.data == null || response.data is! Map) {
      return const CollectPaymentResponseModel(
        message: 'Payment collected',
        success: true,
      );
    }
    return CollectPaymentResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── GET /api/ClinicAdmin/full-dashboard/{clinicId} ───────────────────────
  Future<FullDashboardResponseModel> getFullDashboard(int clinicId) async {
    final response = await _dio.get('$_base/full-dashboard/$clinicId');
    return ClinicDashboardModel.fromJson(response.data as Map<String, dynamic>);
  }
}
