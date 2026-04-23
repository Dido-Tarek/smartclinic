import 'package:json_annotation/json_annotation.dart';

/// الأدوار المتاحة في نظام Smart Clinic +
enum UserRole {
  @JsonValue('Patient')
  patient,

  @JsonValue('Doctor')
  doctor,

  @JsonValue('Hospital')
  hospital,
}

/// Extension لتسهيل التعامل مع الـ Enum في الكود والـ UI
extension UserRoleExtension on UserRole {
  // تحويل الـ Enum لنص للعرض (لو محتاج تعرضه في الـ UI)
  String get name {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.hospital:
        return 'Hospital';
    }
  }

  // ميثود مساعدة للتأكد من الدور بسرعة
  bool get isPatient => this == UserRole.patient;
  bool get isDoctor => this == UserRole.doctor;
  bool get isHospital => this == UserRole.hospital;
}

/// تحويل الـ String القادم من السيرفر أو الـ SharedPrefs إلى Enum
UserRole getRoleEnum(String? role) {
  switch (role) {
    case 'Patient':
      return UserRole.patient;
    case 'Doctor':
      return UserRole.doctor;
    case 'Hospital':
      return UserRole.hospital;
    default:
      return UserRole.patient; // القيمة الافتراضية في حالة عدم التحديد
  }
}
