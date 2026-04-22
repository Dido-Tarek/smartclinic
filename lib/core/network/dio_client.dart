// core/networking/dio_client.dart
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  final Dio _dio;
  final SharedPreferences _sharedPreferences;

  DioClient(this._dio, this._sharedPreferences) {
    _dio
      ..options.baseUrl = "http://smartclinicccc.runasp.net/"
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.responseType = ResponseType.json;

    // إضافة Logger احترافي
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final lang = _sharedPreferences.getString('language_code') ?? 'en';
          options.headers['Accept-Language'] = lang;
          options.headers['Content-Type'] = 'application/json';

          final token = _sharedPreferences.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            _sharedPreferences.remove('auth_token');
          }
          return handler.next(e); // هنعالج الأخطاء في ملف الـ Error Handler
        },
      ),
    );
  }

  Dio get instance => _dio;
}
