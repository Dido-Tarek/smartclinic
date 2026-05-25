// ── Shared schedule slot used in multiple requests ────────────────────────────
class ScheduleSlotModel {
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int maxPatients;

  const ScheduleSlotModel({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.maxPatients,
  });

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
    'maxPatients': maxPatients,
  };

  factory ScheduleSlotModel.fromJson(Map<String, dynamic> json) =>
      ScheduleSlotModel(
        dayOfWeek: json['dayOfWeek'] as String? ?? '',
        startTime: json['startTime'] as String? ?? '',
        endTime: json['endTime'] as String? ?? '',
        maxPatients: json['maxPatients'] as int? ?? 0,
      );
}

// ── POST /api/Clinics/send-employment-request ─────────────────────────────────
class SendEmploymentRequestModel {
  final String doctorId;
  final int clinicId;
  final num examinationFee;
  final num homeVisitFee;
  final num onlineFee;
  final num followUpFee;
  final num emergencyFee;
  final int sessionDuration;
  final List<ScheduleSlotModel> schedules;

  const SendEmploymentRequestModel({
    required this.doctorId,
    required this.clinicId,
    required this.examinationFee,
    required this.homeVisitFee,
    required this.onlineFee,
    required this.followUpFee,
    required this.emergencyFee,
    required this.sessionDuration,
    required this.schedules,
  });

  Map<String, dynamic> toJson() => {
    'doctorId': doctorId,
    'clinicId': clinicId,
    'examinationFee': examinationFee,
    'homeVisitFee': homeVisitFee,
    'onlineFee': onlineFee,
    'followUpFee': followUpFee,
    'emergencyFee': emergencyFee,
    'sessionDuration': sessionDuration,
    'schedules': schedules.map((s) => s.toJson()).toList(),
  };
}

// ── POST /api/Clinics/respond-to-employment ───────────────────────────────────
class RespondToEmploymentRequestModel {
  final int requestId;
  final bool accept;
  final String? feedback;

  const RespondToEmploymentRequestModel({
    required this.requestId,
    required this.accept,
    this.feedback,
  });

  Map<String, dynamic> toJson() => {
    'requestId': requestId,
    'accept': accept,
    if (feedback != null) 'feedback': feedback,
  };
}

// ── PUT /api/Clinics/update-clinic-profile (multipart/form-data) ──────────────
class UpdateClinicProfileRequestModel {
  final int clinicId;
  final String? name;
  final String? address;
  final String? phoneNumber;
  final String? city;
  final String? area;
  final String? specialization;
  final double? latitude;
  final double? longitude;
  final int? sessionDuration;
  final num? clinicFee;
  final num? onlineFee;
  final num? homeVisitFee;
  final num? followUpFee;
  final num? emergencyFee;
  final String?
  clinicImagePath; // local file path — converted to MultipartFile in service

  const UpdateClinicProfileRequestModel({
    required this.clinicId,
    this.name,
    this.address,
    this.phoneNumber,
    this.city,
    this.area,
    this.specialization,
    this.latitude,
    this.longitude,
    this.sessionDuration,
    this.clinicFee,
    this.onlineFee,
    this.homeVisitFee,
    this.followUpFee,
    this.emergencyFee,
    this.clinicImagePath,
  });
}

// ── PUT /api/Clinics/update-financial-terms ───────────────────────────────────
class UpdateFinancialTermsRequestModel {
  final String doctorId;
  final int clinicId;
  final num examinationFee;
  final num followUpFee;
  final num onlineFee;
  final num homeVisitFee;
  final num emergencyFee;
  final int sessionDuration;

  const UpdateFinancialTermsRequestModel({
    required this.doctorId,
    required this.clinicId,
    required this.examinationFee,
    required this.followUpFee,
    required this.onlineFee,
    required this.homeVisitFee,
    required this.emergencyFee,
    required this.sessionDuration,
  });

  Map<String, dynamic> toJson() => {
    'doctorId': doctorId,
    'clinicId': clinicId,
    'examinationFee': examinationFee,
    'followUpFee': followUpFee,
    'onlineFee': onlineFee,
    'homeVisitFee': homeVisitFee,
    'emergencyFee': emergencyFee,
    'sessionDuration': sessionDuration,
  };
}

// ── PUT /api/Clinics/update-doctor-schedule ───────────────────────────────────
class UpdateDoctorScheduleRequestModel {
  final String doctorId;
  final int clinicId;
  final List<ScheduleSlotModel> schedules;

  const UpdateDoctorScheduleRequestModel({
    required this.doctorId,
    required this.clinicId,
    required this.schedules,
  });

  Map<String, dynamic> toJson() => {
    'doctorId': doctorId,
    'clinicId': clinicId,
    'schedules': schedules.map((s) => s.toJson()).toList(),
  };
}

// ── POST /api/Schedules/add-schedule ─────────────────────────────────────────
class AddScheduleRequestModel {
  final int clinicId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int maxPatientsPerShift;

  const AddScheduleRequestModel({
    required this.clinicId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.maxPatientsPerShift,
  });

  Map<String, dynamic> toJson() => {
    'clinicId': clinicId,
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
    'maxPatientsPerShift': maxPatientsPerShift,
  };
}
