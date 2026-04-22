// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_records_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadRecordResponse _$UploadRecordResponseFromJson(
  Map<String, dynamic> json,
) => UploadRecordResponse(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  fileUrl: json['fileUrl'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$UploadRecordResponseToJson(
  UploadRecordResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'fileUrl': instance.fileUrl,
  'message': instance.message,
};
