import 'package:smartclinic/core/helper/shared_preds_helper.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/routes/app_routes.dart';

class UserSession {
  // مفاتيح التخزين الثابتة
  static const String _tokenKey = SharedPrefsHelper.tokenKey;
  static const String _userIdKey = SharedPrefsHelper.userIdKey;
  static const String _roleKey = SharedPrefsHelper.userRoleKey;
  static const String _fullNameKey = SharedPrefsHelper.userFullNameKey;
  static const String _emailKey = SharedPrefsHelper.userEmailKey;
  static const String _fcmTokenKey = SharedPrefsHelper.fcmTokenKey;
  static const String _clinicIdsKey = SharedPrefsHelper.clinicIdsKey;
  static const String _phoneKey = 'user_phone';
  static const String _birthDateKey = 'user_birth_date';
  static const String _addressKey = 'user_address';
  static const String _genderKey = 'user_gender';
  static const String _bloodGroupKey = 'user_blood_group';
  static const String _profileImageKey = 'user_profile_image';
  static const String _setupCompletedPrefix = 'setup_completed';
  static const String _facilityVerificationPendingPrefix =
      'facility_verification_pending';
  static const String _loginTimestampKey = SharedPrefsHelper.loginTimestampKey;

  /// Session lifetime: 3 hours in milliseconds
  static const int _sessionDurationMs = 3 * 60 * 60 * 1000;

  /// حفظ بيانات الجلسة بالكامل (تستدعى بعد Login أو Register ناجح)
  Future<void> saveUserSession({
    required String token,
    required String userId,
    required String role,
  }) async {
    await SharedPrefsHelper.setData(_tokenKey, token);
    await SharedPrefsHelper.setData(_userIdKey, userId);
    await SharedPrefsHelper.setData(_roleKey, role);
    await saveLoginTimestamp();
  }

  /// حفظ وقت تسجيل الدخول (epoch milliseconds)
  Future<void> saveLoginTimestamp() async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await SharedPrefsHelper.setData(_loginTimestampKey, nowMs);
  }

  Future<void> saveToken(String token) async {
    await SharedPrefsHelper.setData(_tokenKey, token);
  }

  Future<void> saveFullName(String fullName) async {
    await SharedPrefsHelper.setData(_fullNameKey, fullName);
  }

  Future<void> saveEmail(String email) async {
    await SharedPrefsHelper.setData(_emailKey, email);
  }

  Future<void> savePhone(String phone) async {
    await SharedPrefsHelper.setData(_phoneKey, phone);
  }

  Future<void> saveBirthDate(String birthDate) async {
    await SharedPrefsHelper.setData(_birthDateKey, birthDate);
  }

  Future<void> saveAddress(String address) async {
    await SharedPrefsHelper.setData(_addressKey, address);
  }

  Future<void> saveGender(String gender) async {
    await SharedPrefsHelper.setData(_genderKey, gender);
  }

  Future<void> saveBloodGroup(String bloodGroup) async {
    await SharedPrefsHelper.setData(_bloodGroupKey, bloodGroup);
  }

  Future<void> saveProfileImage(String profileImage) async {
    await SharedPrefsHelper.setData(_profileImageKey, profileImage);
  }

  Future<void> saveDeviceToken(String token) async {
    await SharedPrefsHelper.setData(_fcmTokenKey, token);
  }

  /// حفظ الـ ID فقط (تستخدم بعد Register عندما لا يوجد Token)
  Future<void> saveUserId(String userId) async {
    await SharedPrefsHelper.setData(_userIdKey, userId);
  }

  /// حفظ الدور فقط (تستخدم من شاشة اختيار الحساب أو كـ fallback)
  Future<void> saveRole(String role) async {
    await SharedPrefsHelper.setData(_roleKey, role);
  }

  /// حفظ قائمة العيادات (مرتبة تصاعدياً حسب الـ ID)
  Future<void> saveClinicIds(List<int> ids) async {
    final sorted = List<int>.from(ids)..sort();
    await SharedPrefsHelper.setData(_clinicIdsKey, sorted.join(','));
  }

  Future<void> clearClinicIds() async {
    await SharedPrefsHelper.removeData(_clinicIdsKey);
  }

  Future<void> markSetupCompleted({
    required String role,
    required String userId,
  }) async {
    final key = _setupCompletedKey(role: role, userId: userId);
    await SharedPrefsHelper.setData(key, true);
  }

  bool isSetupCompleted({required String role, required String userId}) {
    final key = _setupCompletedKey(role: role, userId: userId);
    return SharedPrefsHelper.getBool(key) ?? false;
  }

  Future<void> markFacilityVerificationPending({
    required String role,
    required String userId,
  }) async {
    final key = _facilityVerificationKey(role: role, userId: userId);
    await SharedPrefsHelper.setData(key, true);
  }

  Future<void> clearFacilityVerificationPending({
    required String role,
    required String userId,
  }) async {
    final key = _facilityVerificationKey(role: role, userId: userId);
    await SharedPrefsHelper.removeData(key);
  }

  bool isFacilityVerificationPending({
    required String role,
    required String userId,
  }) {
    final key = _facilityVerificationKey(role: role, userId: userId);
    return SharedPrefsHelper.getBool(key) ?? false;
  }

  // --- Getters ---

  String? get token => SharedPrefsHelper.getString(_tokenKey);

  /// استرجاع الـ ID (سواء كان لمريض، دكتور، أو مستشفى)
  String? get userId => SharedPrefsHelper.getString(_userIdKey);

  /// Doctor ID — only meaningful when role is Doctor
  String? get doctorId => userRole.isDoctor ? userId : null;

  /// Patient ID — only meaningful when role is Patient
  String? get patientId => userRole.isPatient ? userId : null;

  /// All clinic IDs the doctor/hospital owns (sorted ascending)
  List<int> get clinicIds {
    final raw = SharedPrefsHelper.getString(_clinicIdsKey);
    if (raw == null || raw.isEmpty) return [];
    return raw
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
  }

  /// The primary (lowest-ID) clinic for this doctor/hospital, or null
  int? get primaryClinicId {
    final ids = clinicIds;
    return ids.isEmpty ? null : ids.first;
  }

  /// استرجاع الـ Role كـ String
  String? get roleString => SharedPrefsHelper.getString(_roleKey);

  String? get fullName => SharedPrefsHelper.getString(_fullNameKey);

  String? get email => SharedPrefsHelper.getString(_emailKey);

  String? get phone => SharedPrefsHelper.getString(_phoneKey);

  String? get birthDate => SharedPrefsHelper.getString(_birthDateKey);

  String? get address => SharedPrefsHelper.getString(_addressKey);

  String? get gender => SharedPrefsHelper.getString(_genderKey);

  String? get bloodGroup => SharedPrefsHelper.getString(_bloodGroupKey);

  String? get profileImage => SharedPrefsHelper.getString(_profileImageKey);

  String? get deviceToken => SharedPrefsHelper.getString(_fcmTokenKey);

  /// استرجاع الـ Role كـ Enum لسهولة التعامل في الـ Logic
  UserRole get userRole => getRoleEnum(roleString);

  /// التحقق هل انتهت صلاحية الجلسة (أكثر من 3 ساعات)
  bool get isSessionExpired {
    final timestampMs = SharedPrefsHelper.getInt(_loginTimestampKey);
    if (timestampMs == null) return true; // no timestamp → treat as expired
    final loginTime = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    return DateTime.now().difference(loginTime).inMilliseconds >
        _sessionDurationMs;
  }

  /// التحقق هل المستخدم مسجل دخول أم لا (ويأخذ انتهاء الصلاحية بعين الاعتبار)
  bool get isLoggedIn => token != null && userId != null && !isSessionExpired;

  // --- Methods ---

  /// مسح بيانات الـ ID فقط
  Future<void> clearUserId() async {
    await SharedPrefsHelper.removeData(_userIdKey);
  }

  /// مسح الدور فقط
  Future<void> clearRole() async {
    await SharedPrefsHelper.removeData(_roleKey);
  }

  /// تسجيل الخروج (مسح كل بيانات الجلسة)
  Future<void> clearSession() async {
    await SharedPrefsHelper.removeData(_tokenKey);
    await SharedPrefsHelper.removeData(_userIdKey);
    await SharedPrefsHelper.removeData(_roleKey);
    await SharedPrefsHelper.removeData(_fullNameKey);
    await SharedPrefsHelper.removeData(_emailKey);
    await SharedPrefsHelper.removeData(_fcmTokenKey);
    await SharedPrefsHelper.removeData(_phoneKey);
    await SharedPrefsHelper.removeData(_birthDateKey);
    await SharedPrefsHelper.removeData(_addressKey);
    await SharedPrefsHelper.removeData(_genderKey);
    await SharedPrefsHelper.removeData(_bloodGroupKey);
    await SharedPrefsHelper.removeData(_profileImageKey);
    await SharedPrefsHelper.removeData(_clinicIdsKey);
    await SharedPrefsHelper.removeData(_loginTimestampKey);
  }

  String resolvePostLoginRoute({required String role, required String userId}) {
    final roleEnum = getRoleEnum(role);
    final normalizedUserId = userId.trim();

    if (normalizedUserId.isEmpty ||
        !isSetupCompleted(role: role, userId: normalizedUserId)) {
      if (roleEnum.isDoctor || roleEnum.isHospital) {
        return AppRoutes.medicalFacilityManagement;
      }
      return AppRoutes.uploadMedicalRecords;
    }

    if (roleEnum.isHospital) {
      return AppRoutes.hospitalhome;
    }

    return AppRoutes.home;
  }

  String _setupCompletedKey({required String role, required String userId}) {
    final normalizedRole = getRoleEnum(role).name.toLowerCase();
    return '${_setupCompletedPrefix}_${normalizedRole}_${userId.trim()}';
  }

  String _facilityVerificationKey({
    required String role,
    required String userId,
  }) {
    final normalizedRole = getRoleEnum(role).name.toLowerCase();
    return '${_facilityVerificationPendingPrefix}_${normalizedRole}_${userId.trim()}';
  }
}
