import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/notification/data/model/notifications_model.dart';

abstract class NotificationsRepo {
  Future<ApiResult<List<NotificationModel>>> getMyNotifications();
  Future<ApiResult<UnreadCountResponse>> getUnreadCount();
  Future<ApiResult<dynamic>> markAsRead(int id);
  Future<ApiResult<dynamic>> markAllAsRead();
  Future<ApiResult<dynamic>> deleteNotification(int id);
}
