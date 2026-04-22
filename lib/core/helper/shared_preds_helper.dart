import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String tokenKey = 'token';
  static const String patientIdKey = 'patient_id';

  // كائن الـ SharedPreferences الحقيقي
  static SharedPreferences? _sharedPreferences;

  SharedPreferences get _prefs {
    final prefs = _sharedPreferences;
    if (prefs == null) {
      throw StateError(
        'SharedPrefsHelper is not initialized. Call SharedPrefsHelper.init() before using it.',
      );
    }
    return prefs;
  }

  // دالة الـ Init (بيتم استدعاؤها في الـ main قبل تشغيل الـ App)
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  /// حفظ البيانات بأي نوع (String, int, bool, double)
  Future<bool> setData(String key, dynamic value) async {
    if (value is String) return await _prefs.setString(key, value);
    if (value is int) return await _prefs.setInt(key, value);
    if (value is bool) return await _prefs.setBool(key, value);
    if (value is double) return await _prefs.setDouble(key, value);
    return false;
  }

  /// الحصول على String (للتوكين والـ Patient ID)
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// الحصول على Boolean (مثلاً لو عاوز تعرف المستخدم شاف الـ Onboarding ولا لأ)
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// الحصول على Integer
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// حذف مفتاح معين (عند الـ Logout مثلاً)
  Future<bool> removeData(String key) async {
    return await _prefs.remove(key);
  }

  /// مسح كل البيانات المخزنة
  Future<bool> clearAllData() async {
    return await _prefs.clear();
  }
}
