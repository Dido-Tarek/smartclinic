import 'dart:io';

class PatientRegisterRequestModel {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final String birthDate;
  final String gender;
  final String bloodGroup;
  final String address;
  final File nationalIdFront;
  final File nationalIdBack;

  PatientRegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    required this.birthDate,
    required this.gender,
    required this.bloodGroup,
    required this.address,
    required this.nationalIdFront,
    required this.nationalIdBack,
  });
}
