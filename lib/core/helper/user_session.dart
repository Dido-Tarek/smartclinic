import 'package:smartclinic/core/helper/shared_preds_helper.dart';
import 'package:smartclinic/core/helper/user_roles.dart';

class UserSession {
  // مفاتيح التخزين الثابتة
  static const String _tokenKey = SharedPrefsHelper.tokenKey;
  static const String _userIdKey = SharedPrefsHelper.userIdKey;
  static const String _roleKey = SharedPrefsHelper.userRoleKey;

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

  /// حفظ الـ ID فقط (تستخدم بعد Register عندما لا يوجد Token)
  Future<void> saveUserId(String userId) async {
    await SharedPrefsHelper.setData(_userIdKey, userId);
  }

  /// حفظ الدور فقط (تستخدم من شاشة اختيار الحساب أو كـ fallback)
  Future<void> saveRole(String role) async {
    await SharedPrefsHelper.setData(_roleKey, role);
  }

  // --- Getters ---

  String? get token => SharedPrefsHelper.getString(_tokenKey);

  /// استرجاع الـ ID (سواء كان لمريض، دكتور، أو مستشفى)
  String? get userId => SharedPrefsHelper.getString(_userIdKey);

  /// استرجاع الـ Role كـ String
  String? get roleString => SharedPrefsHelper.getString(_roleKey);

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
}
