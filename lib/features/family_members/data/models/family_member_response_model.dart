// ── Core family member entity ─────────────────────────────────────────────────
class FamilyMemberModel {
  final int? id;
  final String? patientId;
  final String? name;
  final String? relation;
  final String? gender;
  final String? birthDate;
  final String? bloodType;

  const FamilyMemberModel({
    this.id,
    this.patientId,
    this.name,
    this.relation,
    this.gender,
    this.birthDate,
    this.bloodType,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) =>
      FamilyMemberModel(
        id: json['id'] as int?,
        patientId: json['patientId'] as String?,
        name: json['name'] as String?,
        relation: json['relation'] as String?,
        gender: json['gender'] as String?,
        birthDate: json['birthDate'] as String?,
        bloodType: json['bloodType'] as String?,
      );
}

// ── POST /api/Family/add response ─────────────────────────────────────────────
// Returns the created member on success.
typedef AddFamilyMemberResponseModel = FamilyMemberModel;

// ── GET /api/Family/my-family response ───────────────────────────────────────
class MyFamilyResponseModel {
  final List<FamilyMemberModel> members;

  const MyFamilyResponseModel({required this.members});

  factory MyFamilyResponseModel.fromJson(Map<String, dynamic> json) =>
      MyFamilyResponseModel(
        members:
            (json['members'] as List<dynamic>? ??
                    json['data'] as List<dynamic>? ??
                    [])
                .map(
                  (e) => FamilyMemberModel.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
      );

  /// Fallback when API returns a raw JSON array at root level.
  factory MyFamilyResponseModel.fromList(List<dynamic> list) =>
      MyFamilyResponseModel(
        members: list
            .map((e) => FamilyMemberModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── DELETE /api/Family/remove/{id} response ───────────────────────────────────
class RemoveFamilyMemberResponseModel {
  final String? message;

  const RemoveFamilyMemberResponseModel({this.message});

  factory RemoveFamilyMemberResponseModel.fromJson(Map<String, dynamic> json) =>
      RemoveFamilyMemberResponseModel(message: json['message'] as String?);
}
