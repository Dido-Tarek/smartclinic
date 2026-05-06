import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/notification/domain/repo/notifications_repo.dart';
import 'package:smartclinic/features/notification/presentation/manager/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepo _repo;

  NotificationsCubit(this._repo) : super(const NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());
    await _fetchNotifications();
  }

  Future<void> markAsRead(int id) async {
    await _performMutation(() => _repo.markAsRead(id));
  }

  Future<void> markAllAsRead() async {
    await _performMutation(_repo.markAllAsRead);
  }

  Future<void> deleteNotification(int id) async {
    await _performMutation(() => _repo.deleteNotification(id));
  }

  Future<void> _performMutation(
    Future<ApiResult<dynamic>> Function() action,
  ) async {
    emit(const NotificationsLoading());
    final result = await action();
    await result.when(
      success: (_) async {
        await _fetchNotifications();
      },
      failure: (error) async {
        emit(NotificationsError(message: error));
      },
    );
  }

  Future<void> _fetchNotifications() async {
    final notificationsResult = await _repo.getMyNotifications();
    await notificationsResult.when(
      success: (notifications) async {
        final unreadResult = await _repo.getUnreadCount();
        await unreadResult.when(
          success: (countResponse) async {
            emit(
              NotificationsSuccess(
                NotificationsData(
                  notifications: notifications,
                  unreadCount: countResponse.count,
                ),
              ),
            );
          },
          failure: (error) async {
            emit(NotificationsError(message: error));
          },
        );
      },
      failure: (error) async {
        emit(NotificationsError(message: error));
      },
    );
  }
}
