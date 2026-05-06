import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/notification/data/api/notifications_api_service.dart';
import 'package:smartclinic/features/notification/data/model/notifications_model.dart';
import 'package:smartclinic/features/notification/domain/repo/notifications_repo.dart';

class NotificationsRepoImpl implements NotificationsRepo {
  final NotificationsApiService _notificatinosApi;
  NotificationsRepoImpl(this._notificatinosApi);

  @override
  Future<ApiResult<List<NotificationModel>>> getMyNotifications() async {
    try {
      final response = await _notificatinosApi.getMyNotifications();
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<UnreadCountResponse>> getUnreadCount() async {
    try {
      final response = await _notificatinosApi.getUnreadNotificationsCount();
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<dynamic>> markAsRead(int id) async {
    try {
      final response = await _notificatinosApi.markNotificationAsRead(id);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<dynamic>> markAllAsRead() async {
    try {
      final response = await _notificatinosApi.markAllNotificationsAsRead();
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<dynamic>> deleteNotification(int id) async {
    try {
      final response = await _notificatinosApi.deleteNotification(id);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
