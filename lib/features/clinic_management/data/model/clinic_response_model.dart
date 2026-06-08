// ── Core clinic entity ────────────────────────────────────────────────────────
import 'package:smartclinic/features/clinic_management/data/model/clinic_request_model.dart';

class ClinicModel {
  final int? id;
  final String? name;
  final String? address;
  final String? phoneNumber;
  final String? city;
  final String? area;
  final String? specialization;
  final String? clinicImageUrl;
  final double? latitude;
  final double? longitude;
  final int? sessionDuration;
  final num? clinicFee;
  final num? onlineFee;
  final num? homeVisitFee;
  final num? followUpFee;
  final num? emergencyFee;

  const ClinicModel({
    this.id,
    this.name,
    this.address,
    this.phoneNumber,
    this.city,
    this.area,
    this.specialization,
    this.clinicImageUrl,
    this.latitude,
    this.longitude,
    this.sessionDuration,
    this.clinicFee,
    this.onlineFee,
    this.homeVisitFee,
    this.followUpFee,
    this.emergencyFee,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) => ClinicModel(
    id: json['id'] as int?,
    name: json['name'] as String?,
    address: json['address'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    city: json['city'] as String?,
    area: json['area'] as String?,
    specialization: json['specialization'] as String?,
    clinicImageUrl: json['clinicImageUrl'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    sessionDuration: json['sessionDuration'] as int?,
    clinicFee: json['clinicFee'] as num?,
    onlineFee: json['onlineFee'] as num?,
    homeVisitFee: json['homeVisitFee'] as num?,
    followUpFee: json['followUpFee'] as num?,
    emergencyFee: json['emergencyFee'] as num?,
  );
}

// ── Core employment request entity ────────────────────────────────────────────
class EmploymentRequestModel {
  final int? id;
  final String? doctorId;
  final String? doctorName;
  final int? clinicId;
  final String? clinicName;
  final String? status;
  final String? feedback;
  final num? examinationFee;
  final num? homeVisitFee;
  final num? onlineFee;
  final num? followUpFee;
  final num? emergencyFee;
  final int? sessionDuration;
  final List<ScheduleSlotModel> schedules;
  final String? createdAt;

  const EmploymentRequestModel({
    this.id,
    this.doctorId,
    this.doctorName,
    this.clinicId,
    this.clinicName,
    this.status,
    this.feedback,
    this.examinationFee,
    this.homeVisitFee,
    this.onlineFee,
    this.followUpFee,
    this.emergencyFee,
    this.sessionDuration,
    this.schedules = const [],
    this.createdAt,
  });

  factory EmploymentRequestModel.fromJson(Map<String, dynamic> json) =>
      EmploymentRequestModel(
        id: json['id'] as int?,
        doctorId: json['doctorId'] as String?,
        doctorName: json['doctorName'] as String?,
        clinicId: json['clinicId'] as int?,
        clinicName: json['clinicName'] as String?,
        status: json['status'] as String?,
        feedback: json['feedback'] as String?,
        examinationFee: json['examinationFee'] as num?,
        homeVisitFee: json['homeVisitFee'] as num?,
        onlineFee: json['onlineFee'] as num?,
        followUpFee: json['followUpFee'] as num?,
        emergencyFee: json['emergencyFee'] as num?,
        sessionDuration: json['sessionDuration'] as int?,
        schedules: (json['schedules'] as List<dynamic>? ?? [])
            .map((e) => ScheduleSlotModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt'] as String?,
      );
}

// ── Core schedule entity ──────────────────────────────────────────────────────
class ScheduleModel {
  final int? id;
  final int? clinicId;
  final String? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final int? maxPatientsPerShift;

  const ScheduleModel({
    this.id,
    this.clinicId,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.maxPatientsPerShift,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
    id: json['id'] as int?,
    clinicId: json['clinicId'] as int?,
    dayOfWeek: json['dayOfWeek'] as String?,
    startTime: json['startTime'] as String?,
    endTime: json['endTime'] as String?,
    maxPatientsPerShift: json['maxPatientsPerShift'] as int?,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Response models (typedef or wrapper)
// ─────────────────────────────────────────────────────────────────────────────

// POST /api/Clinics/send-employment-request
typedef SendEmploymentResponseModel = EmploymentRequestModel;

// GET /api/Clinics/my-employment-requests
class MyEmploymentRequestsResponseModel {
  final List<EmploymentRequestModel> requests;
  const MyEmploymentRequestsResponseModel({required this.requests});

  factory MyEmploymentRequestsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => MyEmploymentRequestsResponseModel(
    requests:
        (json['requests'] as List<dynamic>? ??
                json['data'] as List<dynamic>? ??
                [])
            .map(
              (e) => EmploymentRequestModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
  );

  factory MyEmploymentRequestsResponseModel.fromList(List<dynamic> list) =>
      MyEmploymentRequestsResponseModel(
        requests: list
            .map(
              (e) => EmploymentRequestModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
}

// POST /api/Clinics/respond-to-employment
typedef RespondToEmploymentResponseModel = EmploymentRequestModel;

// GET /api/Clinics/my-clinics
class MyClinicsResponseModel {
  final List<ClinicModel> clinics;
  const MyClinicsResponseModel({required this.clinics});

  factory MyClinicsResponseModel.fromJson(Map<String, dynamic> json) =>
      MyClinicsResponseModel(
        clinics:
            (json['clinics'] as List<dynamic>? ??
                    json['data'] as List<dynamic>? ??
                    [])
                .map((e) => ClinicModel.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

  factory MyClinicsResponseModel.fromList(List<dynamic> list) =>
      MyClinicsResponseModel(
        clinics: list
            .map((e) => ClinicModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// DELETE /api/Clinics/remove-clinic/{clinicId}
class RemoveClinicResponseModel {
  final String? message;
  const RemoveClinicResponseModel({this.message});
  factory RemoveClinicResponseModel.fromJson(Map<String, dynamic> json) =>
      RemoveClinicResponseModel(message: json['message'] as String?);
}

// PUT /api/Clinics/update-clinic-profile
typedef UpdateClinicProfileResponseModel = ClinicModel;

// PUT /api/Clinics/update-financial-terms
typedef UpdateFinancialTermsResponseModel = EmploymentRequestModel;

// PUT /api/Clinics/update-doctor-schedule
typedef UpdateDoctorScheduleResponseModel = EmploymentRequestModel;

// POST /api/Schedules/add-schedule
typedef AddScheduleResponseModel = ScheduleModel;

// DELETE /api/Schedules/delete-schedule/{id}
class DeleteScheduleResponseModel {
  final String? message;
  const DeleteScheduleResponseModel({this.message});
  factory DeleteScheduleResponseModel.fromJson(Map<String, dynamic> json) =>
      DeleteScheduleResponseModel(message: json['message'] as String?);
}

// GET /api/Schedules/doctor-availability/{doctorId}
class DoctorAvailabilityResponseModel {
  final List<ScheduleModel> schedules;
  const DoctorAvailabilityResponseModel({required this.schedules});

  factory DoctorAvailabilityResponseModel.fromJson(Map<String, dynamic> json) =>
      DoctorAvailabilityResponseModel(
        schedules:
            (json['schedules'] as List<dynamic>? ??
                    json['data'] as List<dynamic>? ??
                    [])
                .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

  factory DoctorAvailabilityResponseModel.fromList(List<dynamic> list) =>
      DoctorAvailabilityResponseModel(
        schedules: list
            .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// GET /api/Clinics/unowned-list
class UnownedClinicsResponseModel {
  final List<ClinicModel> clinics;
  const UnownedClinicsResponseModel({required this.clinics});

  factory UnownedClinicsResponseModel.fromJson(Map<String, dynamic> json) =>
      UnownedClinicsResponseModel(
        clinics:
            (json['clinics'] as List<dynamic>? ??
                    json['data'] as List<dynamic>? ??
                    [])
                .map((e) => ClinicModel.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

  factory UnownedClinicsResponseModel.fromList(List<dynamic> list) =>
      UnownedClinicsResponseModel(
        clinics: list
            .map((e) => ClinicModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
