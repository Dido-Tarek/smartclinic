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
  final int? clinicId;
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
    this.clinicId,
    this.clinicName,
    this.clinicAddress,
    this.clinicPhone,
    this.clinicWorkingHours,
  });

  static const _baseUrl = 'http://smartclinicccc.runasp.net';

  static String? _resolveUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final t = raw.trim();
    if (t.startsWith('http')) return t;
    return '$_baseUrl${t.startsWith('/') ? '' : '/'}$t';
  }

  static String? _formatSchedules(Map<String, dynamic>? clinic) {
    if (clinic == null) return null;
    final list = clinic['schedules'] as List<dynamic>?;
    if (list == null || list.isEmpty) return null;
    final lines = list.map((s) {
      if (s is! Map<String, dynamic>) return null;
      final day = (s['day'] ?? s['Day']) as String? ?? '';
      final from = (s['from'] ?? s['From']) as String? ?? '';
      final to = (s['to'] ?? s['To']) as String? ?? '';
      if (day.isEmpty) return null;
      return from.isNotEmpty ? '$day: $from – $to' : day;
    }).whereType<String>().toList();
    return lines.isEmpty ? null : lines.join('\n');
  }

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    final payload = _unwrapPayload(json);
    final pricing = _getMap(payload, ['pricing', 'Pricing']);
    final clinic = _getClinicMap(payload);

    // Fees: try pricing object first, then clinic-level, then top-level
    double? readFee(List<String> keys) =>
        _readDouble(pricing, keys) ??
        _readDouble(clinic, keys) ??
        _readDouble(payload, keys);

    return DoctorProfileModel(
      fullName:
          _readString(payload, ['fullName', 'FullName', 'name', 'Name']) ?? '',
      phoneNumber: _readString(payload, ['phoneNumber', 'PhoneNumber',
          'doctorPhone', 'DoctorPhone']),
      specialization:
          _readString(payload, ['specialization', 'Specialization']),
      bio: _readString(payload, ['bio', 'Bio']),
      yearsOfExperience:
          _readInt(payload, ['yearsOfExperience', 'YearsOfExperience']),
      clinicFee: readFee(['clinicFee', 'ClinicFee', 'examinationFee', 'ExaminationFee']),
      homeVisitFee: readFee(['homeVisitFee', 'HomeVisitFee']),
      onlineFee: readFee(['onlineFee', 'OnlineFee']),
      followUpFee: readFee(['followUpFee', 'FollowUpFee']),
      emergencyFee: readFee(['emergencyFee', 'EmergencyFee']),
      // photoUrl is a relative path — prepend the base URL
      profileImage: _resolveUrl(
        _readString(payload, [
          'photoUrl', 'PhotoUrl',
          'profileImage', 'ProfileImage',
          'profilePicture', 'ProfilePicture',
        ]),
      ),
      clinicId: _readInt(clinic ?? {}, ['id', 'clinicId', 'ClinicId']) ??
          _readInt(payload, ['clinicId', 'ClinicId']),
      clinicName: _readString(clinic, ['name', 'clinicName', 'ClinicName']) ??
          _readString(payload, ['clinicName', 'ClinicName']),
      clinicAddress:
          _readString(clinic, ['address', 'Address', 'location', 'Location']) ??
          _readString(payload, ['clinicAddress', 'ClinicAddress', 'address', 'Address']),
      // doctorPhone lives at the top level of the payload, not inside the clinic
      clinicPhone:
          _readString(payload, ['doctorPhone', 'DoctorPhone', 'clinicPhone',
              'ClinicPhone', 'phone', 'Phone', 'phoneNumber', 'PhoneNumber']) ??
          _readString(clinic, ['phone', 'Phone', 'phoneNumber', 'PhoneNumber', 'contact']),
      // Format schedules array → "Thursday: 12:41 – 16:00"
      clinicWorkingHours:
          _readString(payload, ['workingHours', 'WorkingHours', 'workingTimes', 'WorkingTimes']) ??
          _readString(clinic, ['workingHours', 'WorkingHours', 'workingTimes', 'WorkingTimes']) ??
          _formatSchedules(clinic),
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
