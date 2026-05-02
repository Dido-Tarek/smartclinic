import 'dart:io';

class VerificationFileModel {
  final File syndicatCard;
  final File license;
  final File nationalId;
  final File specializationCert;

  VerificationFileModel({
    required this.syndicatCard,
    required this.license,
    required this.nationalId,
    required this.specializationCert,
  });
}
