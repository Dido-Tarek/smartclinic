import 'package:dio/dio.dart';
import 'package:smartclinic/injection_dependency.dart';

import '../helper/user_session.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // جلب الـ Token من الـ UserSession المخزن
    final token = getIt<UserSession>().token;

    if (token != null && token.isNotEmpty) {
      // إضافة الـ Token في الهيدر لكل طلب يخرج من التطبيق
      options.headers['Authorization'] = 'Bearer $token';
    }

    // استكمال الطلب
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // لو السيرفر رجع 401 (Unauthorized)، ممكن تعمل Logout تلقائي هنا
    if (err.response?.statusCode == 401) {
      getIt<UserSession>().clearSession();
      // هنا ممكن تضيف كود يرجع المستخدم لصفحة الـ Login
    }
    super.onError(err, handler);
  }
}
