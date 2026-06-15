// ── Core appointment entity ───────────────────────────────────────────────────
class AppointmentModel {
  final int? id;
  final String? patientId;
  final String? patientName;
  final String? patientPhone;
  final String? doctorId;
  final String? doctorName;
  final String? doctorImage;
  final int? clinicId;
  final String? clinicName;
  final String? date;
  final String? time;
  final String? type;
  final String? status;
  final String? adminMessage;
  final bool? payFromWallet;
  final int? familyMemberId;
  final String? notes;
  final String? createdAt;
  final String? meetingLink;
  final double? consultationFee;

  const AppointmentModel({
    this.id,
    this.patientId,
    this.patientName,
    this.patientPhone,
    this.doctorId,
    this.doctorName,
    this.doctorImage,
    this.clinicId,
    this.clinicName,
    this.date,
    this.time,
    this.type,
    this.status,
    this.adminMessage,
    this.payFromWallet,
    this.familyMemberId,
    this.notes,
    this.createdAt,
    this.meetingLink,
    this.consultationFee,
  });

  static const _baseUrl = 'http://smartclinicccc.runasp.net';

  static String? _resolveUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final t = raw.trim();
    return t.startsWith('http') ? t : '$_baseUrl${t.startsWith('/') ? '' : '/'}$t';
  }

  static String _generateMeetingLink(int id) {
    final h = ((id ^ (id << 13)) * 1540483477) & 0xFFFFFFFF;
    return 'https://meet.jit.si/SmartClinic-${h.toRadixString(16).padLeft(8, '0')}';
  }

  /// Returns just the date portion of the ISO datetime string (e.g. "2026-06-18").
  String get displayDate {
    final d = date?.trim() ?? '';
    if (d.isEmpty) return 'Date pending';
    final idx = d.indexOf('T');
    return idx > 0 ? d.substring(0, idx) : d;
  }

  /// Returns HH:mm extracted from the ISO datetime string or the explicit time field.
  String get displayTime {
    final t = time?.trim() ?? '';
    if (t.isNotEmpty) return t.length > 5 ? t.substring(0, 5) : t;
    final d = date?.trim() ?? '';
    final idx = d.indexOf('T');
    if (idx > 0 && idx + 1 < d.length) {
      final tp = d.substring(idx + 1);
      return tp.length > 5 ? tp.substring(0, 5) : tp;
    }
    return 'Time pending';
  }

  static bool _isVideoCallType(String? type) {
    final t = (type ?? '').toLowerCase();
    return t.contains('video') || t.contains('online') || t == 'videocall';
  }

  static double? _readFee(Map<String, dynamic> json) {
    for (final key in const [
      'consultationFee', 'ConsultationFee',
      'fee', 'Fee',
      'price', 'Price',
      'amount', 'Amount',
      'totalFee', 'TotalFee',
      'totalAmount', 'TotalAmount',
    ]) {
      final v = json[key];
      if (v is num) return v.toDouble();
      if (v is String) {
        final parsed = double.tryParse(v.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int?;
    final type = json['type'] as String?;
    final apiLink = (json['meetingLink'] ??
            json['meetingUrl'] ??
            json['videoCallLink'] ??
            json['videoLink'] ??
            json['joinUrl']) as String?;
    final meetingLink = apiLink ??
        (id != null && _isVideoCallType(type)
            ? _generateMeetingLink(id)
            : null);

    return AppointmentModel(
      id: id,
      patientId: json['patientId'] as String?,
      patientName: json['patientName'] as String?,
      patientPhone: json['patientPhone'] as String?,
      doctorId: json['doctorId'] as String?,
      doctorName: json['doctorName'] as String?,
      doctorImage: _resolveUrl(
        (json['doctorImage'] ?? json['doctorPhoto'] ?? json['photoUrl']) as String?,
      ),
      clinicId: json['clinicId'] as int?,
      clinicName: json['clinicName'] as String?,
      date: json['date'] as String?,
      time: json['time'] as String?,
      type: type,
      status: json['status'] as String?,
      adminMessage: json['adminMessage'] as String?,
      payFromWallet: json['payFromWallet'] as bool?,
      familyMemberId: json['familyMemberId'] as int?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String?,
      meetingLink: meetingLink,
      consultationFee: _readFee(json),
    );
  }
}

// ── POST /api/Appointments/book response ──────────────────────────────────────
typedef BookAppointmentResponseModel = AppointmentModel;

// ── GET /api/Appointments/my-appointments response ────────────────────────────
class MyAppointmentsResponseModel {
  final List<AppointmentModel> appointments;

  const MyAppointmentsResponseModel({required this.appointments});

  factory MyAppointmentsResponseModel.fromJson(Map<String, dynamic> json) =>
      MyAppointmentsResponseModel(
        appointments:
            (json['appointments'] as List<dynamic>? ??
                    json['data'] as List<dynamic>? ??
                    [])
                .map(
                  (e) => AppointmentModel.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
      );

  factory MyAppointmentsResponseModel.fromList(List<dynamic> list) =>
      MyAppointmentsResponseModel(
        appointments: list
            .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── GET /api/Appointments/doctor-requests/{clinicId} response ─────────────────
typedef DoctorRequestsResponseModel = MyAppointmentsResponseModel;

// ── PUT /api/Appointments/update-status/{id} response ────────────────────────
typedef UpdateAppointmentStatusResponseModel = AppointmentModel;

// ── PUT /api/Appointments/cancel-my-appointment/{id} response ────────────────
class CancelAppointmentResponseModel {
  final String? message;
  final bool? refundIssued;

  const CancelAppointmentResponseModel({this.message, this.refundIssued});

  factory CancelAppointmentResponseModel.fromJson(Map<String, dynamic> json) =>
      CancelAppointmentResponseModel(
        message: json['message'] as String?,
        refundIssued: json['refundIssued'] as bool?,
      );
}

// ── GET /api/Appointments/available-slots response ────────────────────────────
class AvailableSlotModel {
  final String? time;
  final bool? isAvailable;

  const AvailableSlotModel({this.time, this.isAvailable});

  factory AvailableSlotModel.fromJson(Map<String, dynamic> json) =>
      AvailableSlotModel(
        time: json['time'] as String?,
        isAvailable: json['isAvailable'] as bool?,
      );
}

class AvailableSlotsResponseModel {
  final List<AvailableSlotModel> slots;

  const AvailableSlotsResponseModel({required this.slots});

  factory AvailableSlotsResponseModel.fromJson(Map<String, dynamic> json) =>
      AvailableSlotsResponseModel(
        slots: (json['slots'] as List<dynamic>? ?? [])
            .map((e) => AvailableSlotModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  factory AvailableSlotsResponseModel.fromList(List<dynamic> list) =>
      AvailableSlotsResponseModel(
        slots: list
            .map((e) => AvailableSlotModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── GET /api/Appointments/queue-position/{appointmentId} response ─────────────
class QueuePositionResponseModel {
  final int? position;
  final int? totalInQueue;
  final String? estimatedWaitTime;

  const QueuePositionResponseModel({
    this.position,
    this.totalInQueue,
    this.estimatedWaitTime,
  });

  factory QueuePositionResponseModel.fromJson(Map<String, dynamic> json) =>
      QueuePositionResponseModel(
        position: json['position'] as int?,
        totalInQueue: json['totalInQueue'] as int?,
        estimatedWaitTime: json['estimatedWaitTime'] as String?,
      );
}
