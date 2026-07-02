// ─────────────────────────────────────────────────────────────────────────────
// Core entities
// ─────────────────────────────────────────────────────────────────────────────

// ── Queue patient entry ───────────────────────────────────────────────────────
class QueueEntryModel {
  final int? id;
  final String? patientId;
  final String? patientName;
  final String? patientPhone;
  final String? appointmentTime;
  final String? status;
  final int? queuePosition;
  final String? type; // e.g. 'clinic', 'online', 'home'

  const QueueEntryModel({
    this.id,
    this.patientId,
    this.patientName,
    this.patientPhone,
    this.appointmentTime,
    this.status,
    this.queuePosition,
    this.type,
  });

  factory QueueEntryModel.fromJson(Map<String, dynamic> json) =>
      QueueEntryModel(
        id: json['id'] as int?,
        patientId: json['patientId'] as String?,
        patientName: json['patientName'] as String?,
        patientPhone: json['patientPhone'] as String?,
        appointmentTime: json['appointmentTime'] as String?,
        status: json['status'] as String?,
        queuePosition: json['queuePosition'] as int?,
        type: json['type'] as String?,
      );
}

// ── Staff member ──────────────────────────────────────────────────────────────
class StaffMemberModel {
  final String? id;
  final String? name;
  final String? role; // 'doctor', 'nurse', etc.
  final String? specialization;
  final String? email;
  final String? phone;
  final String? imageUrl;
  final bool? isActive;

  const StaffMemberModel({
    this.id,
    this.name,
    this.role,
    this.specialization,
    this.email,
    this.phone,
    this.imageUrl,
    this.isActive,
  });

  factory StaffMemberModel.fromJson(Map<String, dynamic> json) =>
      StaffMemberModel(
        id: json['id'] as String?,
        name: json['name'] as String?,
        role: json['role'] as String?,
        specialization: json['specialization'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        imageUrl: json['imageUrl'] as String?,
        isActive: json['isActive'] as bool?,
      );
}

// ── Doctor search result ──────────────────────────────────────────────────────
class DoctorSearchResultModel {
  final String? id;
  final String? name;
  final String? specialization;
  final String? email;
  final String? phone;
  final String? imageUrl;

  const DoctorSearchResultModel({
    this.id,
    this.name,
    this.specialization,
    this.email,
    this.phone,
    this.imageUrl,
  });

  factory DoctorSearchResultModel.fromJson(Map<String, dynamic> json) =>
      DoctorSearchResultModel(
        id: json['id'] as String?,
        name: json['name'] as String?,
        specialization: json['specialization'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        imageUrl: json['imageUrl'] as String?,
      );
}

// ── Full dashboard stats ──────────────────────────────────────────────────────
class ClinicDashboardModel {
  final int? clinicId;
  final String? clinicName;
  final String? clinicAddress;
  final String? clinicImageUrl;
  final int? todayAppointmentsCount;
  final int? totalPatientsCount;
  final int? activeDoctorsCount;
  final int? queueLength;
  final num? totalRevenue;
  final num? todayRevenue;
  final List<QueueEntryModel> todayQueue;
  final List<StaffMemberModel> staff;

  const ClinicDashboardModel({
    this.clinicId,
    this.clinicName,
    this.clinicAddress,
    this.clinicImageUrl,
    this.todayAppointmentsCount,
    this.totalPatientsCount,
    this.activeDoctorsCount,
    this.queueLength,
    this.totalRevenue,
    this.todayRevenue,
    this.todayQueue = const [],
    this.staff = const [],
  });

  factory ClinicDashboardModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final stats = payload['stats'] as Map<String, dynamic>?;
    final finances = payload['finances'] as Map<String, dynamic>?;
    final todayStats = stats?['todayStats'] as Map<String, dynamic>?;

    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    num? parseNum(dynamic value) {
      if (value is num) return value;
      if (value is String) return num.tryParse(value);
      return null;
    }

    return ClinicDashboardModel(
      clinicId: parseInt(payload['clinicId']),
      clinicName: payload['clinicName'] as String?,
      clinicAddress: payload['clinicAddress'] as String?,
      clinicImageUrl: payload['clinicImageUrl'] as String?,
      todayAppointmentsCount: parseInt(todayStats?['totalToday']),
      totalPatientsCount: parseInt(stats?['totalAllTime']),
      activeDoctorsCount: parseInt(payload['activeDoctorsCount']),
      queueLength: parseInt(payload['queueLength']),
      totalRevenue: parseNum(finances?['totalRevenue']),
      todayRevenue: parseNum(finances?['todayRevenue']),
      todayQueue: (payload['todayQueue'] as List<dynamic>? ?? [])
          .map((e) => QueueEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      staff: (payload['staff'] as List<dynamic>? ?? [])
          .map((e) => StaffMemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Response models
// ─────────────────────────────────────────────────────────────────────────────

// GET /api/ClinicAdmin/today-queue/{clinicId}
class TodayQueueResponseModel {
  final List<QueueEntryModel> queue;

  const TodayQueueResponseModel({required this.queue});

  factory TodayQueueResponseModel.fromJson(Map<String, dynamic> json) =>
      TodayQueueResponseModel(
        queue:
            (json['queue'] as List<dynamic>? ??
                    json['data'] as List<dynamic>? ??
                    [])
                .map((e) => QueueEntryModel.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

  factory TodayQueueResponseModel.fromList(List<dynamic> list) =>
      TodayQueueResponseModel(
        queue: list
            .map((e) => QueueEntryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// GET /api/ClinicAdmin/{clinicId}/staff
class ClinicStaffResponseModel {
  final List<StaffMemberModel> staff;

  const ClinicStaffResponseModel({required this.staff});

  factory ClinicStaffResponseModel.fromJson(Map<String, dynamic> json) =>
      ClinicStaffResponseModel(
        staff:
            (json['staff'] as List<dynamic>? ??
                    json['data'] as List<dynamic>? ??
                    [])
                .map(
                  (e) => StaffMemberModel.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
      );

  factory ClinicStaffResponseModel.fromList(List<dynamic> list) =>
      ClinicStaffResponseModel(
        staff: list
            .map((e) => StaffMemberModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// DELETE /api/ClinicAdmin/remove-doctor
class RemoveDoctorResponseModel {
  final String? message;

  const RemoveDoctorResponseModel({this.message});

  factory RemoveDoctorResponseModel.fromJson(Map<String, dynamic> json) =>
      RemoveDoctorResponseModel(message: json['message'] as String?);
}

// GET /api/ClinicAdmin/find-doctor
class FindDoctorResponseModel {
  final List<DoctorSearchResultModel> doctors;

  const FindDoctorResponseModel({required this.doctors});

  factory FindDoctorResponseModel.fromJson(Map<String, dynamic> json) =>
      FindDoctorResponseModel(
        doctors:
            (json['doctors'] as List<dynamic>? ??
                    json['data'] as List<dynamic>? ??
                    [])
                .map(
                  (e) => DoctorSearchResultModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList(),
      );

  factory FindDoctorResponseModel.fromList(List<dynamic> list) =>
      FindDoctorResponseModel(
        doctors: list
            .map(
              (e) =>
                  DoctorSearchResultModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );

  /// Single doctor returned directly as a map (not a list)
  factory FindDoctorResponseModel.fromSingle(Map<String, dynamic> json) =>
      FindDoctorResponseModel(
        doctors: [DoctorSearchResultModel.fromJson(json)],
      );
}

// PUT /api/ClinicAdmin/collect-payment/{invoiceId}
class CollectPaymentResponseModel {
  final String? message;
  final bool? success;

  const CollectPaymentResponseModel({this.message, this.success});

  factory CollectPaymentResponseModel.fromJson(Map<String, dynamic> json) =>
      CollectPaymentResponseModel(
        message: json['message'] as String?,
        success: json['success'] as bool?,
      );
}

// GET /api/ClinicAdmin/full-dashboard/{clinicId}
typedef FullDashboardResponseModel = ClinicDashboardModel;
