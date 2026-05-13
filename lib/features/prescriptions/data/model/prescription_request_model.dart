// ── Single medicine item inside a prescription ────────────────────────────────
class MedicineItemModel {
  final String medicineName;
  final String dosage;
  final int frequency;
  final int days;
  final String? notes;

  const MedicineItemModel({
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.days,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'medicineName': medicineName,
    'dosage': dosage,
    'frequency': frequency,
    'days': days,
    if (notes != null) 'notes': notes,
  };

  factory MedicineItemModel.fromJson(Map<String, dynamic> json) =>
      MedicineItemModel(
        medicineName: json['medicineName'] as String? ?? '',
        dosage: json['dosage'] as String? ?? '',
        frequency: json['frequency'] as int? ?? 0,
        days: json['days'] as int? ?? 0,
        notes: json['notes'] as String?,
      );
}

// ── POST /api/Prescriptions/add request ──────────────────────────────────────
class AddPrescriptionRequestModel {
  final String patientId;
  final int appointmentId;
  final String diagnosis;
  final String? notes;
  final List<MedicineItemModel> medicines;

  const AddPrescriptionRequestModel({
    required this.patientId,
    required this.appointmentId,
    required this.diagnosis,
    this.notes,
    required this.medicines,
  });

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'appointmentId': appointmentId,
    'diagnosis': diagnosis,
    if (notes != null) 'notes': notes,
    'medicines': medicines.map((m) => m.toJson()).toList(),
  };
}
