import 'package:smartclinic/features/notification/data/model/notifications_model.dart';

sealed class NotificationsState {
  const NotificationsState();
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsSuccess extends NotificationsState {
  final NotificationsData data;

  const NotificationsSuccess(this.data);
}

final class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError({required this.message});
}

class NotificationsData {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationsData({
    required this.notifications,
    required this.unreadCount,
  });
}
