import 'package:json_annotation/json_annotation.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  final String? message;
  final String? token;
  @JsonKey(name: 'username') // لو الاسم في السيرفر مختلف
  final String? userName;

  LoginResponseModel({this.message, this.token, this.userName});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}
