import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smartclinic/features/notification/data/model/notifications_model.dart';

part 'notifications_api_service.g.dart';

@RestApi()
abstract class NotificationsApiService {
  factory NotificationsApiService(Dio dio, {String baseUrl}) =
      _NotificationsApiService;

  // جلب كافة الإشعارات الخاصة بالمستخدم الحالي مرتبة من الأحدث للأقدم
  @GET('/api/Notifications/my-notifications')
  Future<List<NotificationModel>> getMyNotifications();

  // حساب عدد الإشعارات التي لم يقم المستخدم بقراءتها بعد لإظهار شارة التنبيه
  @GET('/api/Notifications/unread-count')
  Future<UnreadCountResponse> getUnreadNotificationsCount();

  // تحديث حالة إشعار محدد إلى "مقروء" بناءً على الـ ID الخاص به
  @POST('/api/Notifications/mark-read/{id}')
  Future<dynamic> markNotificationAsRead(@Path("id") int id);

  // تحويل كافة إشعارات المستخدم الحالي غير المقروءة إلى حالة "مقروءة" دفعة واحدة
  @POST('/api/Notifications/mark-all-read')
  Future<dynamic> markAllNotificationsAsRead();

  // حذف إشعار محدد نهائياً من سجل المستخدم
  @DELETE('/api/Notifications/{id}')
  Future<dynamic> deleteNotification(@Path("id") int id);
}
