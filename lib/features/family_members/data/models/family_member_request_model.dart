// ── POST /api/Family/add ──────────────────────────────────────────────────────
class AddFamilyMemberRequestModel {
  final String patientId;
  final String name;
  final String relation;
  final String gender;
  final String birthDate; // ISO-8601 e.g. "2000-05-15T00:00:00.000Z"
  final String bloodType;

  const AddFamilyMemberRequestModel({
    required this.patientId,
    required this.name,
    required this.relation,
    required this.gender,
    required this.birthDate,
    required this.bloodType,
  });

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'name': name,
    'relation': relation,
    'gender': gender,
    'birthDate': birthDate,
    'bloodType': bloodType,
  };
}
