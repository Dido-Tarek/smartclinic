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
    'date': _normalizeDate(date),
    'time': _normalizeTime(time),
    'type': type,
    if (familyMemberId != null) 'familyMemberId': familyMemberId,
    if (notes != null) 'notes': notes,
    if (patientName != null) 'patientName': patientName,
    if (patientPhone != null) 'patientPhone': patientPhone,
    'payFromWallet': payFromWallet,
  };
}

String _normalizeDate(String value) {
  final trimmed = value.trim();
  final parsed = DateTime.tryParse(trimmed);
  if (parsed != null) {
    return '${parsed.year.toString().padLeft(4, '0')}-'
        '${parsed.month.toString().padLeft(2, '0')}-'
        '${parsed.day.toString().padLeft(2, '0')}';
  }

  final namedDate = RegExp(
    r'^(?:[A-Za-z]{3,9},\s*)?(\d{1,2})\s+([A-Za-z]{3,9})\s+(\d{4})$',
  ).firstMatch(trimmed);
  if (namedDate != null) {
    final day = int.tryParse(namedDate.group(1)!);
    final month = _monthNumber(namedDate.group(2)!);
    final year = int.tryParse(namedDate.group(3)!);
    if (day != null && month != null && year != null) {
      return '${year.toString().padLeft(4, '0')}-'
          '${month.toString().padLeft(2, '0')}-'
          '${day.toString().padLeft(2, '0')}';
    }
  }

  return trimmed;
}

String _normalizeTime(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }

  final ampmMatch = RegExp(
    r'^(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([AaPp][Mm])\b',
  ).firstMatch(trimmed);
  if (ampmMatch != null) {
    final hour = int.parse(ampmMatch.group(1)!);
    final minute = int.parse(ampmMatch.group(2)!);
    final ampm = ampmMatch.group(4)!.toLowerCase();
    var hour24 = hour % 12;
    if (ampm == 'pm') {
      hour24 += 12;
    }
    return '${hour24.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  final hhmm = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
  if (hhmm != null) {
    return '${int.parse(hhmm.group(1)!).toString().padLeft(2, '0')}:${hhmm.group(2)!}';
  }

  final hhmmss = RegExp(r'^(\d{1,2}):(\d{2}):(\d{2})$').firstMatch(trimmed);
  if (hhmmss != null) {
    return '${int.parse(hhmmss.group(1)!).toString().padLeft(2, '0')}:${hhmmss.group(2)!}';
  }

  return trimmed;
}

int? _monthNumber(String monthName) {
  const monthNames = <String, int>{
    'january': 1,
    'february': 2,
    'march': 3,
    'april': 4,
    'may': 5,
    'june': 6,
    'july': 7,
    'august': 8,
    'september': 9,
    'october': 10,
    'november': 11,
    'december': 12,
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'sept': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  return monthNames[monthName.toLowerCase()];
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
