import 'package:smartclinic/core/helper/shared_preds_helper.dart';

class UserSession {
  final SharedPrefsHelper _prefs;
  UserSession(this._prefs);

  // حفظ بيانات المستخدم عند النجاح في الـ Login أو الـ Register
  Future<void> saveUserSession({
    required String token,
    required String patientId,
  }) async {
    await _prefs.setData(SharedPrefsHelper.tokenKey, token);
    await savePatientId(patientId);
  }

  Future<void> savePatientId(String patientId) async {
    await _prefs.setData(SharedPrefsHelper.patientIdKey, patientId);
    // Backward compatibility for older keys used previously.
    await _prefs.setData('patientId', patientId);
  }

  // الحصول على الـ Token (مفيد للـ Interceptors)
  String? get token => _prefs.getString(SharedPrefsHelper.tokenKey);

  // الحصول على الـ Patient ID (مفيد للـ Features اللي بتحتاجه في الـ Body)
  String? get patientId =>
      _prefs.getString(SharedPrefsHelper.patientIdKey) ??
      _prefs.getString('patientId');

  // التأكد من أن المستخدم مسجل دخول (للـ Routing)
  bool get isLoggedIn => token != null && patientId != null;

  Future<void> clearPatientId() async {
    await _prefs.removeData(SharedPrefsHelper.patientIdKey);
    await _prefs.removeData('patientId');
  }

  // مسح الجلسة (Logout)
  Future<void> clearSession() async {
    await _prefs.removeData(SharedPrefsHelper.tokenKey);
    await clearPatientId();
  }
}
