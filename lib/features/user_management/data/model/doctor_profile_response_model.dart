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
  final String? clinicName;
  final String? clinicAddress;
  final String? clinicPhone;
  final String? clinicWorkingHours;

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
    this.clinicName,
    this.clinicAddress,
    this.clinicPhone,
    this.clinicWorkingHours,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    final payload = _unwrapPayload(json);
    final pricing = _getMap(payload, ['pricing', 'Pricing']);
    final clinic = _getClinicMap(payload);

    return DoctorProfileModel(
      fullName:
          _readString(payload, ['fullName', 'FullName', 'name', 'Name']) ?? '',
      phoneNumber: _readString(payload, ['phoneNumber', 'PhoneNumber']),
      specialization:
          _readString(payload, ['specialization', 'Specialization']),
      bio: _readString(payload, ['bio', 'Bio']),
      yearsOfExperience:
          _readInt(payload, ['yearsOfExperience', 'YearsOfExperience']),
      clinicFee: _readDouble(pricing, ['clinicFee', 'ClinicFee']) ??
          _readDouble(payload, ['clinicFee', 'ClinicFee']),
      homeVisitFee: _readDouble(pricing, ['homeVisitFee', 'HomeVisitFee']) ??
          _readDouble(payload, ['homeVisitFee', 'HomeVisitFee']),
      onlineFee: _readDouble(pricing, ['onlineFee', 'OnlineFee']) ??
          _readDouble(payload, ['onlineFee', 'OnlineFee']),
      followUpFee: _readDouble(pricing, ['followUpFee', 'FollowUpFee']) ??
          _readDouble(payload, ['followUpFee', 'FollowUpFee']),
      emergencyFee: _readDouble(pricing, ['emergencyFee', 'EmergencyFee']) ??
          _readDouble(payload, ['emergencyFee', 'EmergencyFee']),
      profileImage: _readString(
        payload,
        ['profileImage', 'ProfileImage', 'profilePicture', 'ProfilePicture'],
      ),
      clinicName: _readString(
            payload,
            ['clinicName', 'ClinicName', 'clinic', 'Clinic'],
          ) ??
          _readString(clinic, ['name', 'clinicName', 'ClinicName', 'clinic', 'Clinic']),
      clinicAddress: _readString(
            payload,
            ['clinicAddress', 'ClinicAddress', 'address', 'Address', 'location', 'Location'],
          ) ??
          _readString(clinic, ['address', 'Address', 'location', 'Location']),
      clinicPhone: _readString(
            payload,
            ['clinicPhone', 'ClinicPhone', 'phone', 'Phone', 'phoneNumber', 'PhoneNumber', 'contact', 'Contact'],
          ) ??
          _readString(clinic, ['phone', 'Phone', 'phoneNumber', 'PhoneNumber', 'contact', 'Contact']),
      clinicWorkingHours: _readString(
            payload,
            ['workingHours', 'WorkingHours', 'workingTimes', 'WorkingTimes', 'hours', 'Hours'],
          ) ??
          _readString(clinic, ['workingHours', 'WorkingHours', 'workingTimes', 'WorkingTimes', 'hours', 'Hours']),
    );
  }

  static Map<String, dynamic> _unwrapPayload(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    final result = json['result'];
    if (result is Map<String, dynamic>) {
      return result;
    }

    return json;
  }

  static Map<String, dynamic>? _getMap(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _getClinicMap(Map<String, dynamic> json) {
    final clinic = _getMap(json, ['clinic', 'Clinic']);
    if (clinic != null) {
      return clinic;
    }

    final clinics = json['clinics'] ?? json['Clinics'];
    if (clinics is List && clinics.isNotEmpty) {
      final firstClinic = clinics.first;
      if (firstClinic is Map<String, dynamic>) {
        return firstClinic;
      }
    }

    return null;
  }

  static String? _readString(Map<String, dynamic>? json, List<String> keys) {
    if (json == null) {
      return null;
    }

    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is String) {
        return int.tryParse(value.trim());
      }
      if (value is num) {
        return value.toInt();
      }
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic>? json, List<String> keys) {
    if (json == null) return null;
    for (final key in keys) {
      final value = json[key];
      if (value is double) {
        return value;
      }
      if (value is int) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value.trim());
      }
      if (value is num) {
        return value.toDouble();
      }
    }
    return null;
  }
}
