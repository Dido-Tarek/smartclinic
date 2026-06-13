// ── PUT /api/Invoices/mark-as-paid/{appointmentId} response ──────────────────
class MarkInvoiceAsPaidResponseModel {
  final String? message;
  final bool? success;

  const MarkInvoiceAsPaidResponseModel({this.message, this.success});

  factory MarkInvoiceAsPaidResponseModel.fromJson(Map<String, dynamic> json) =>
      MarkInvoiceAsPaidResponseModel(
        message: json['message'] as String?,
        success: json['success'] as bool?,
      );
}

// ── GET /api/Invoices/clinic-report/{clinicId} response ──────────────────────
class ClinicReportResponseModel {
  final num? totalRevenue;
  final num? totalAppointments;
  final num? totalInvoices;
  final num? doctorShare;
  final num? clinicShare;

  const ClinicReportResponseModel({
    this.totalRevenue,
    this.totalAppointments,
    this.totalInvoices,
    this.doctorShare,
    this.clinicShare,
  });

  factory ClinicReportResponseModel.fromJson(Map<String, dynamic> json) =>
      ClinicReportResponseModel(
        totalRevenue: json['totalRevenue'] as num?,
        totalAppointments: json['totalAppointments'] as num?,
        totalInvoices: json['totalInvoices'] as num?,
        doctorShare: json['doctorShare'] as num?,
        clinicShare: json['clinicShare'] as num?,
      );
}
