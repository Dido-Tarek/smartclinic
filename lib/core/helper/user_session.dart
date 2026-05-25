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
  static const String _setupCompletedPrefix = 'setup_completed';

  /// حفظ بيانات الجلسة بالكامل (تستخدم بعد Login أو Register ناجح)
  Future<void> saveUserSession({
    required String token,
    required String userId,
    required String role,
  }) async {
    await SharedPrefsHelper.setData(_tokenKey, token);
    await SharedPrefsHelper.setData(_userIdKey, userId);
    await SharedPrefsHelper.setData(_roleKey, role);
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

  Future<void> markSetupCompleted({
    required String role,
    required String userId,
  }) async {
    final key = _setupCompletedKey(role: role, userId: userId);
    await SharedPrefsHelper.setData(key, true);
  }

  bool isSetupCompleted({
    required String role,
    required String userId,
  }) {
    final key = _setupCompletedKey(role: role, userId: userId);
    return SharedPrefsHelper.getBool(key) ?? false;
  }

  // --- Getters ---

  String? get token => SharedPrefsHelper.getString(_tokenKey);

  /// استرجاع الـ ID (سواء كان لمريض، دكتور، أو مستشفى)
  String? get userId => SharedPrefsHelper.getString(_userIdKey);

  /// استرجاع الـ Role كـ String
  String? get roleString => SharedPrefsHelper.getString(_roleKey);

  String? get fullName => SharedPrefsHelper.getString(_fullNameKey);

  String? get email => SharedPrefsHelper.getString(_emailKey);

  String? get deviceToken => SharedPrefsHelper.getString(_fcmTokenKey);

  /// استرجاع الـ Role كـ Enum لسهولة التعامل في الـ Logic
  UserRole get userRole => getRoleEnum(roleString);

  /// التحقق هل المستخدم مسجل دخول أم لا
  bool get isLoggedIn => token != null && userId != null;

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
  }

  Future<void> initMockSession({
    required UserRole role,
    required String userId,
    required String token,
  }) async {
    await saveUserSession(
      token: token,
      userId: userId,
      role: role
          .name, // بيستخدم الـ name من الـ Enum اللي عملناه (Doctor, Patient, Hospital)
    );

    print("🚀 [DEBUG MODE]: Session Initialized as ${role.name}");
    print("🆔 User ID: $userId");
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
}
