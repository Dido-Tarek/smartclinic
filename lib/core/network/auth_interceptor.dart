import 'package:dio/dio.dart';
import 'package:smartclinic/injection_dependency.dart';
import 'package:smartclinic/main.dart';
import '../helper/user_session.dart';
import '../routes/app_routes.dart';

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
    // لو السيرفر رجع 401 (Unauthorized)، امسح الجلسة وارجع للـ Login
    if (err.response?.statusCode == 401) {
      getIt<UserSession>().clearSession().then((_) {
        // Navigate to login and clear the entire navigation stack
        appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      });
    }
    super.onError(err, handler);
  }
}
