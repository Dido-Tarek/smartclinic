import 'dart:io';

class AddClinicRequestModel {
  final String name;
  final String address;
  final String phoneNumber;
  final String city;
  final String area;
  final File? clinicImage;
  final double? latitude;
  final double? longitude;
  final String? specialization;
  final int? sessionDuration;
  final bool isOwner;
  final File? legalDocument1;
  final File? legalDocument2;
  final File? legalDocument3;
  final double? clinicFee;
  final double? onlineFee;
  final double? homeVisitFee;
  final double? followUpFee;
  final double? emergencyFee;

  AddClinicRequestModel({
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.city,
    required this.area,
    required this.isOwner,
    this.clinicImage,
    this.latitude,
    this.longitude,
    this.specialization,
    this.sessionDuration,
    this.legalDocument1,
    this.legalDocument2,
    this.legalDocument3,
    this.clinicFee,
    this.onlineFee,
    this.homeVisitFee,
    this.followUpFee,
    this.emergencyFee,
  });
}
