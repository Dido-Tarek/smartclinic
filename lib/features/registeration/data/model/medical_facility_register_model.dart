// import 'package:json_annotation/json_annotation.dart';
// import 'package:smartclinic/features/auth/data/models/registeration_request_model.dart';

// part 'medical_facility_register_model.g.dart';

// @JsonSerializable()
// class MedicalFacilityRegisterModel extends RegisterRequestModel {
//   final String? licenseNumber;
//   final String? facilityType; // Clinic, Hospital, Lab
//   final String? specialization;
//   final String? locationUrl;

//   MedicalFacilityRegisterModel({
//     required super.name,
//     required super.email,
//     required super.phone,
//     required super.password,
//     required super.confirmPassword,
//     required super.role,
//     this.licenseNumber,
//     this.facilityType,
//     this.specialization,
//     this.locationUrl,
//   });

//   factory MedicalFacilityRegisterModel.fromJson(Map<String, dynamic> json) =>
//       _$MedicalFacilityRegisterModelFromJson(json);

//   @override
//   Map<String, dynamic> toJson() => _$MedicalFacilityRegisterModelToJson(this);
// }
