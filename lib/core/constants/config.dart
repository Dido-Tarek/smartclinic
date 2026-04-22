import 'package:flutter/foundation.dart';

/// Provides global app configuration constants and environment-specific endpoints.
class AppConfig {
  AppConfig._();

  static const String appName = 'SmartClinic+';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  /// Global request timeout in seconds.
  static const int requestTimeoutSeconds = 20;

  /// تم تعديل الـ Prefix ليتوافق مع الـ Default في ASP.NET Swagger
  /// معظم الـ Endpoints في الرابط بتاعك بتبدأ بـ /api فقط
  static const String apiPrefix = '/api';

  static AppEnvironment environment = AppEnvironment.development;

  static bool get enableVerboseLogging => !isProduction;
  static bool get isProduction => environment == AppEnvironment.production;
  static bool get isStaging => environment == AppEnvironment.staging;
  static bool get isDevelopment => environment == AppEnvironment.development;

  static void init(AppEnvironment env) {
    environment = env;
  }

  /// تحديث الـ URLs بناءً على سيرفر الـ Backend الفعلي
  static String get baseApiUrl {
    switch (environment) {
      case AppEnvironment.production:
        // هنا تحط الدومين النهائي لما ترفع المشروع (Production)
        return 'http://smartclinicccc.runasp.net';
      case AppEnvironment.staging:
        return 'http://smartclinicccc.runasp.net';
      case AppEnvironment.development:
        // حالياً بنستخدم رابط الـ Swagger للـ Development
        return 'http://smartclinicccc.runasp.net';
    }
  }

  /// Build full API endpoint for a relative route.
  /// مثال: AppConfig.endpoint('Account/Register') -> http://smartclinicccc.runasp.net/api/Account/Register
  static String endpoint(String route) {
    final cleanRoute = route.startsWith('/') ? route.substring(1) : route;
    return '$baseApiUrl$apiPrefix/$cleanRoute';
  }

  static String resourceUrl(String path) {
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return '$baseApiUrl/$clean';
  }

  static AppEnvironment detectEnvFromFlags() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    switch (flavor.toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.production;
      case 'staging':
        return AppEnvironment.staging;
      default:
        return AppEnvironment.development;
    }
  }

  static void log(String message) {
    if (kDebugMode || enableVerboseLogging) {
      // ignore: avoid_print
      print('[AppConfig][$environment] $message');
    }
  }
}

enum AppEnvironment { development, staging, production }
