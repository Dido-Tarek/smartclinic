import 'package:json_annotation/json_annotation.dart';

part 'medical_records_response.g.dart';

@JsonSerializable()
class UploadRecordResponse {
  final int? id;
  final String? title;
  final String? description;
  @JsonKey(
    name: 'fileUrl',
  ) // تأكد من اسم الحقل في السواجر (أحياناً يكون filePath)
  final String? fileUrl;
  final String? message; // لو السيرفر بيرجع رسالة نجاح

  UploadRecordResponse({
    this.id,
    this.title,
    this.description,
    this.fileUrl,
    this.message,
  });

  factory UploadRecordResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadRecordResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadRecordResponseToJson(this);
}
