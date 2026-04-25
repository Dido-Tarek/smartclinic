import 'dart:io';

class MedicalFacilityRequestModel {
  final String fullname;
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final String address;
  final String birthDate;
  final String gender;
  final String specialization;
  final File nationalIdFront;
  final File nationalIdBack;

  MedicalFacilityRequestModel({
    required this.fullname,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phone,
    required this.address,
    required this.birthDate,
    required this.gender,
    required this.specialization,
    required this.nationalIdFront,
    required this.nationalIdBack,
  });
}
