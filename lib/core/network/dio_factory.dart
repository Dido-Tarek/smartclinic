import 'package:dio/dio.dart';
import 'package:smartclinic/core/network/auth_interceptor.dart';

class DioFactory {
  // ... الكود السابق الخاص بإنشاء الـ Dio

  static Dio getDio() {
    Duration timeout = const Duration(seconds: 30);
    Dio dio = Dio();

    dio.options
      ..baseUrl = "http://smartclinicccc.runasp.net/"
      ..connectTimeout = timeout
      ..receiveTimeout = timeout;

    // إضافة الـ Interceptors
    dio.interceptors.add(AuthInterceptor()); // أضفنا الـ AuthInterceptor هنا

    // إضافة LogInterceptor للـ Debugging (اختياري)
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }
}
