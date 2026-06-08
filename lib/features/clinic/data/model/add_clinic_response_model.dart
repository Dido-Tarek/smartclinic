import 'package:json_annotation/json_annotation.dart';

part 'add_clinic_response_model.g.dart';

@JsonSerializable()
class AddClinicResponseModel {
  @JsonKey(readValue: _readId)
  final int? id;
  final String? name;
  final String? message;
  final String? status;

  AddClinicResponseModel({this.id, this.name, this.message, this.status});

  factory AddClinicResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AddClinicResponseModelFromJson(json);

  static int? _readId(Map<dynamic, dynamic> json, String key) {
    return (json['id'] as num?)?.toInt() ?? (json['clinicId'] as num?)?.toInt();
  }
}
