// ── Single prescription ───────────────────────────────────────────────────────
import 'package:smartclinic/features/prescriptions/data/model/prescription_request_model.dart';

class PrescriptionModel {
  final int? id;
  final String? patientId;
  final String? patientName;
  final int? appointmentId;
  final String? doctorId;
  final String? doctorName;
  final String? diagnosis;
  final String? notes;
  final String? createdAt;
  final List<MedicineItemModel> medicines;

  const PrescriptionModel({
    this.id,
    this.patientId,
    this.patientName,
    this.appointmentId,
    this.doctorId,
    this.doctorName,
    this.diagnosis,
    this.notes,
    this.createdAt,
    this.medicines = const [],
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) =>
      PrescriptionModel(
        id: json['id'] as int?,
        patientId: json['patientId'] as String?,
        patientName: json['patientName'] as String?,
        appointmentId: json['appointmentId'] as int?,
        doctorId: json['doctorId'] as String?,
        doctorName: json['doctorName'] as String?,
        diagnosis: json['diagnosis'] as String?,
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] as String?,
        medicines: (json['medicines'] as List<dynamic>? ?? [])
            .map((e) => MedicineItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── POST /api/Prescriptions/add response ─────────────────────────────────────
// Returns the created prescription on success.
typedef AddPrescriptionResponseModel = PrescriptionModel;

// ── GET /api/Prescriptions/get/{id} response ─────────────────────────────────
// Returns a single prescription with full details.
typedef GetPrescriptionByIdResponseModel = PrescriptionModel;

// ── GET /api/Prescriptions/my-prescriptions response ─────────────────────────
class MyPrescriptionsResponseModel {
  final List<PrescriptionModel> prescriptions;

  const MyPrescriptionsResponseModel({required this.prescriptions});

  factory MyPrescriptionsResponseModel.fromJson(Map<String, dynamic> json) =>
      MyPrescriptionsResponseModel(
        // Backend may return a root list or a wrapped object — handle both.
        prescriptions:
            (json['prescriptions'] as List<dynamic>? ??
                    json['data'] as List<dynamic>? ??
                    [])
                .map(
                  (e) => PrescriptionModel.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
      );

  /// Convenience constructor when the API returns a raw JSON array at root level.
  factory MyPrescriptionsResponseModel.fromList(List<dynamic> list) =>
      MyPrescriptionsResponseModel(
        prescriptions: list
            .map((e) => PrescriptionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
