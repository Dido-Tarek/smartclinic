// ── POST /api/Appointments/book ───────────────────────────────────────────────
class BookAppointmentRequestModel {
  final String patientId;
  final String doctorId;
  final int clinicId;
  final String date;
  final String time;
  final String type;
  final int? familyMemberId;
  final String? notes;
  final String? patientName;
  final String? patientPhone;
  final bool payFromWallet;

  const BookAppointmentRequestModel({
    required this.patientId,
    required this.doctorId,
    required this.clinicId,
    required this.date,
    required this.time,
    required this.type,
    this.familyMemberId,
    this.notes,
    this.patientName,
    this.patientPhone,
    this.payFromWallet = false,
  });

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'doctorId': doctorId,
    'clinicId': clinicId,
    'date': date,
    'time': time,
    'type': type,
    if (familyMemberId != null) 'familyMemberId': familyMemberId,
    if (notes != null) 'notes': notes,
    if (patientName != null) 'patientName': patientName,
    if (patientPhone != null) 'patientPhone': patientPhone,
    'payFromWallet': payFromWallet,
  };
}

// ── PUT /api/Appointments/update-status/{id} ──────────────────────────────────
class UpdateAppointmentStatusRequestModel {
  final String status;
  final String? adminMessage;

  const UpdateAppointmentStatusRequestModel({
    required this.status,
    this.adminMessage,
  });

  Map<String, dynamic> toJson() => {
    'status': status,
    if (adminMessage != null) 'adminMessage': adminMessage,
  };
}
