import 'package:dio/dio.dart';
import 'package:smartclinic/features/invoices/data/model/invoices_response_model.dart';

class InvoicesApiService {
  final Dio _dio;

  InvoicesApiService(this._dio);

  static const String _markAsPaidEndpoint = '/api/Invoices/mark-as-paid';
  static const String _clinicReportEndpoint = '/api/Invoices/clinic-report';

  // ── PUT /api/Invoices/mark-as-paid/{appointmentId} ────────────────────────
  // Doctor or clinic owner — for appointments registered as cash payment only.
  Future<MarkInvoiceAsPaidResponseModel> markAsPaid(int appointmentId) async {
    final response = await _dio.put('$_markAsPaidEndpoint/$appointmentId');
    return MarkInvoiceAsPaidResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── GET /api/Invoices/clinic-report/{clinicId} ────────────────────────────
  // Clinic owner sees overall revenue; doctor sees only their personal share.
  Future<ClinicReportResponseModel> getClinicReport(int clinicId) async {
    final response = await _dio.get('$_clinicReportEndpoint/$clinicId');
    return ClinicReportResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
