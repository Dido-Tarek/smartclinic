// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_issues_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthIssueModel _$HealthIssueModelFromJson(Map<String, dynamic> json) =>
    HealthIssueModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      status: json['status'] as String,
      diagnosedDate: json['diagnosedDate'] as String,
      isEstimated: json['isEstimated'] as bool? ?? false,
      curedDate: json['curedDate'] as String?,
      notes: json['notes'] as String?,
      linkedRecordId: (json['linkedRecordId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HealthIssueModelToJson(HealthIssueModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'diagnosedDate': instance.diagnosedDate,
      'isEstimated': instance.isEstimated,
      'curedDate': instance.curedDate,
      'notes': instance.notes,
      'linkedRecordId': instance.linkedRecordId,
    };
