import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/features/notification/data/model/notifications_model.dart';
import 'package:smartclinic/features/notification/presentation/manager/notifications_cubit.dart';
import 'package:smartclinic/features/notification/presentation/manager/notifications_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationsCubit>().loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsCubit, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationsError) {
          CherryToast.error(
            title: const Text('Error'),
            description: Text(state.message),
          ).show(context);
        }
      },
      builder: (context, state) {
        final data = state is NotificationsSuccess ? state.data : null;
        final notifications =
            data?.notifications ?? const <NotificationModel>[];
        final unreadCount = data?.unreadCount ?? 0;
        final isLoading = state is NotificationsLoading;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: const CustomAppBar(
            title: 'Notifications',
            showNotification: false,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: unreadCount == 0
                            ? null
                            : () => context
                                  .read<NotificationsCubit>()
                                  .markAllAsRead(),
                        icon: const Icon(Icons.check_circle_outline),
                        tooltip: 'Mark all as read',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => context
                          .read<NotificationsCubit>()
                          .loadNotifications(),
                      child: isLoading && notifications.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : notifications.isEmpty
                          ? Center(child: _buildEmptyState())
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: notifications.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final notification = notifications[index];
                                return _NotificationCard(
                                  notification: notification,
                                  onTap: notification.isRead
                                      ? null
                                      : () => context
                                            .read<NotificationsCubit>()
                                            .markAsRead(notification.id),
                                  onDelete: () => context
                                      .read<NotificationsCubit>()
                                      .deleteNotification(notification.id),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          AppImages.emptyNotifications,
          width: MediaQuery.of(context).size.width * 0.65,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        const Text(
          'Opps, no notifications yet!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = notification.isRead
        ? Colors.white
        : AppColors.accentBlue.withAlpha(120);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notification.isRead
                  ? Colors.transparent
                  : AppColors.skyBlue.withAlpha(120),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                  color: AppColors.accentBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.isRead
                      ? Icons.notifications_none_outlined
                      : Icons.notifications_active_rounded,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.createdAt,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softLavender.withAlpha(30),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'New',
                              style: TextStyle(
                                color: AppColors.softLavender,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
