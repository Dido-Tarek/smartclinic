class DoctorProfileModel {
  final String fullName;
  final String? phoneNumber;
  final String? specialization;
  final String? bio;
  final int? yearsOfExperience;
  final double? clinicFee;
  final double? homeVisitFee;
  final double? onlineFee;
  final double? followUpFee;
  final double? emergencyFee;
  final String? profileImage;

  DoctorProfileModel({
    required this.fullName,
    this.phoneNumber,
    this.specialization,
    this.bio,
    this.yearsOfExperience,
    this.clinicFee,
    this.homeVisitFee,
    this.onlineFee,
    this.followUpFee,
    this.emergencyFee,
    this.profileImage,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    return DoctorProfileModel(
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'],
      specialization: json['specialization'],
      bio: json['bio'],
      yearsOfExperience: json['yearsOfExperience'] as int?,
      clinicFee: (json['clinicFee'] as num?)?.toDouble(),
      homeVisitFee: (json['homeVisitFee'] as num?)?.toDouble(),
      onlineFee: (json['onlineFee'] as num?)?.toDouble(),
      followUpFee: (json['followUpFee'] as num?)?.toDouble(),
      emergencyFee: (json['emergencyFee'] as num?)?.toDouble(),
      profileImage: json['profileImage'],
    );
  }
}
