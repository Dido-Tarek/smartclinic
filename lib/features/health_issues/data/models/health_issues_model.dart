import 'package:json_annotation/json_annotation.dart';

part 'health_issues_model.g.dart';

@JsonSerializable()
class HealthIssueModel {
  final int? id; // يستخدم فقط في حالة الـ Update والـ Get
  final String name;
  final String status;
  @JsonKey(name: 'diagnosedDate')
  final String diagnosedDate;
  final bool isEstimated;
  final String? curedDate; // تاريخ الشفاء (Recovery Date)
  final String? notes;
  final int? linkedRecordId;

  HealthIssueModel({
    this.id,
    required this.name,
    required this.status,
    required this.diagnosedDate,
    this.isEstimated = false,
    this.curedDate,
    this.notes,
    this.linkedRecordId,
  });

  factory HealthIssueModel.fromJson(Map<String, dynamic> json) =>
      _$HealthIssueModelFromJson(json);
  Map<String, dynamic> toJson() => _$HealthIssueModelToJson(this);
}
