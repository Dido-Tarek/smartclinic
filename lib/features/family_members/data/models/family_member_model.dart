import 'package:json_annotation/json_annotation.dart';

part 'family_member_model.g.dart';

@JsonSerializable()
class FamilyMemberModel {
  final int? id; // يستخدم للـ Delete والـ Get
  final String patientId;
  final String name;
  final String relation;
  final String gender;
  final String birthDate;
  final String bloodType;

  FamilyMemberModel({
    this.id,
    required this.patientId,
    required this.name,
    required this.relation,
    required this.gender,
    required this.birthDate,
    required this.bloodType,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberModelFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyMemberModelToJson(this);
}
