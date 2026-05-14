// ── Core appointment entity ───────────────────────────────────────────────────
class AppointmentModel {
  final int? id;
  final String? patientId;
  final String? patientName;
  final String? patientPhone;
  final String? doctorId;
  final String? doctorName;
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

  const AppointmentModel({
    this.id,
    this.patientId,
    this.patientName,
    this.patientPhone,
    this.doctorId,
    this.doctorName,
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
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      AppointmentModel(
        id: json['id'] as int?,
        patientId: json['patientId'] as String?,
        patientName: json['patientName'] as String?,
        patientPhone: json['patientPhone'] as String?,
        doctorId: json['doctorId'] as String?,
        doctorName: json['doctorName'] as String?,
        clinicId: json['clinicId'] as int?,
        clinicName: json['clinicName'] as String?,
        date: json['date'] as String?,
        time: json['time'] as String?,
        type: json['type'] as String?,
        status: json['status'] as String?,
        adminMessage: json['adminMessage'] as String?,
        payFromWallet: json['payFromWallet'] as bool?,
        familyMemberId: json['familyMemberId'] as int?,
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] as String?,
      );
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
