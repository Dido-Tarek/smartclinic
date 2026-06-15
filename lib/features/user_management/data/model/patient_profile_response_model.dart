class PatientProfileModel {
  final String fullName;
  final String? phoneNumber;
  final String? address;
  final String? bloodGroup;
  final String? profilePicture;
  final String? gender;
  final String? birthDate;

  PatientProfileModel({
    required this.fullName,
    this.phoneNumber,
    this.address,
    this.bloodGroup,
    this.profilePicture,
    this.gender,
    this.birthDate,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    final payload = _unwrapPayload(json);
    return PatientProfileModel(
      fullName:
          _readString(payload, ['fullName', 'FullName', 'name', 'Name']) ?? '',
      phoneNumber: _readString(payload, ['phoneNumber', 'PhoneNumber']),
      address: _readString(payload, ['address', 'Address']),
      bloodGroup: _readString(payload, ['bloodGroup', 'BloodGroup']),
      profilePicture: _readString(
        payload,
        ['profilePicture', 'ProfilePicture', 'profileImage', 'ProfileImage',
         'profileImageUrl', 'ProfileImageUrl'],
      ),
      gender: _readString(payload, ['gender', 'Gender']),
      birthDate: _readString(payload, ['birthDate', 'BirthDate']),
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

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
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
}
