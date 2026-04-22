import 'dart:io';

class MedicalRecordRequestModel {
  final File file;
  final String title;
  final String description;
  final String patientId;
  final int? appointmentId;
  final String? doctorId;

  MedicalRecordRequestModel({
    required this.file,
    required this.title,
    required this.description,
    required this.patientId,
    this.appointmentId,
    this.doctorId,
  });
}
