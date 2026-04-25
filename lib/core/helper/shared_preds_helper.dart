import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  // مفاتيح التخزين (Keys) - ثابتة وموحدة
  static const String tokenKey = 'token';
  static const String userIdKey =
      'user_id'; // مفتاح موحد للـ IDs (مريض/دكتور/مستشفى)
  static const String userRoleKey = 'user_role'; // مفتاح الدور الحالي

  // كائن الـ SharedPreferences الحقيقي
  static SharedPreferences? _sharedPreferences;

  // دالة الـ Init (تستدعى في الـ main)
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // Getter خاص للتأكد من الـ Initialization
  static SharedPreferences get _prefs {
    if (_sharedPreferences == null) {
      throw StateError(
        'SharedPrefsHelper is not initialized. Call SharedPrefsHelper.init() before using it.',
      );
    }
    return _sharedPreferences!;
  }

  /// حفظ البيانات (String, int, bool, double)
  /// تم جعلها static لسهولة الوصول من أي مكان
  static Future<bool> setData(String key, dynamic value) async {
    if (value is String) return await _prefs.setString(key, value);
    if (value is int) return await _prefs.setInt(key, value);
    if (value is bool) return await _prefs.setBool(key, value);
    if (value is double) return await _prefs.setDouble(key, value);
    return false;
  }

  /// الحصول على String
  static String? getString(String key) {
    return _prefs.getString(key);
  }

  /// الحصول على Boolean
  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// الحصول على Integer
  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// حذف مفتاح معين
  static Future<bool> removeData(String key) async {
    return await _prefs.remove(key);
  }

  /// مسح كل البيانات المخزنة
  static Future<bool> clearAllData() async {
    return await _prefs.clear();
  }
}
