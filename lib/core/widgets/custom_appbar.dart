import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/notification/data/model/notifications_model.dart';
import 'package:smartclinic/features/notification/domain/repo/notifications_repo.dart';
import 'package:smartclinic/injection_dependency.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotification;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showNotification = true,
    this.showBackButton = true,
    this.onBackTap,
    this.onNotificationTap,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _showNotificationDot = false;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    if (!widget.showNotification) {
      return;
    }

    final result = await getIt<NotificationsRepo>().getUnreadCount();
    if (!mounted) {
      return;
    }

    if (result is Success<UnreadCountResponse>) {
      setState(() {
        _showNotificationDot = result.data.count > 0;
      });
      return;
    }

    if (result is Failure<UnreadCountResponse>) {
      setState(() {
        _showNotificationDot = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final buttonSize = width * 0.065;
    final badgeSize = width * 0.028;
    final toolbarHeight = (height * 0.085).clamp(56.0, 90.0);

    return AppBar(
      toolbarHeight: toolbarHeight,
      backgroundColor: AppColors.scaffoldBg,
      elevation: 0,
      centerTitle: true,
      leading: widget.showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: buttonSize,
              ),
              onPressed: widget.onBackTap ?? () => Navigator.maybePop(context),
            )
          : null,
      title: Text(
        widget.title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: (width * 0.055).clamp(18.0, 24.0),
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        if (widget.showNotification)
          Padding(
            padding: EdgeInsets.only(right: width * 0.02),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none_outlined,
                    color: AppColors.textPrimary,
                    size: buttonSize,
                  ),
                  onPressed: widget.onNotificationTap,
                ),
                if (_showNotificationDot)
                  Positioned(
                    top: badgeSize * 0.35,
                    right: badgeSize * 0.35,
                    child: Container(
                      height: badgeSize,
                      width: badgeSize,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: badgeSize * 0.18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
