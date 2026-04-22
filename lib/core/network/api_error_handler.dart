import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "Connection timeout with server";
        case DioExceptionType.sendTimeout:
          return "Send timeout in association with server";
        case DioExceptionType.receiveTimeout:
          return "Receive timeout in connection with server";
        case DioExceptionType.badResponse:
          return _handleError(error.response?.statusCode, error.response?.data);
        case DioExceptionType.cancel:
          return "Request to server was cancelled";
        default:
          return "Unexpected error occurred";
      }
    } else {
      return "Something went wrong";
    }
  }

  static String _handleError(int? statusCode, dynamic error) {
    if (error != null && error is Map) {
      // بناءً على الـ Swagger بتاعك، بنشوف الـ Key اللي راجع فيه الخطأ
      return error['message'] ?? error['title'] ?? "Error $statusCode";
    }
    switch (statusCode) {
      case 400:
        return "Bad request";
      case 401:
        return "Unauthorized";
      case 403:
        return "Forbidden";
      case 404:
        return "Not found";
      case 500:
        return "Internal server error";
      default:
        return "Oops, something went wrong";
    }
  }
}
