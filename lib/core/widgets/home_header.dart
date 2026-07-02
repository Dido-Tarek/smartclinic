import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/notification/data/model/notifications_model.dart';
import 'package:smartclinic/features/notification/domain/repo/notifications_repo.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/injection_dependency.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
    this.avatarPath,
    this.fallbackAssetPath = AppImages.imagesIconsMan,
    this.title = 'Hi, Khatab !',
    this.subtitle = 'How do you feel today?',
    this.onNotificationTap,
  });

  final String? avatarPath;
  final String fallbackAssetPath;
  final String title;
  final String subtitle;
  final VoidCallback? onNotificationTap;

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> with WidgetsBindingObserver {
  bool _showNotificationDot = false;
  late final UserSession _userSession;
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
    WidgetsBinding.instance.addObserver(this);
    _loadUnreadCount();

    // Refresh dot immediately whenever a new foreground FCM message arrives.
    _fcmSubscription = FirebaseMessaging.onMessage.listen((_) {
      _loadUnreadCount();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fcmSubscription?.cancel();
    super.dispose();
  }

  /// Re-check unread count when the app returns to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUnreadCount();
    }
  }

  Future<void> _loadUnreadCount() async {
    final result = await getIt<NotificationsRepo>().getUnreadCount();
    if (!mounted) return;

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
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: _resolveAvatarImage(),
          backgroundColor: AppColors.scaffoldBg,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            widget.onNotificationTap?.call();
            // Re-check after returning from the notifications screen
            // so the dot disappears once the user has read notifications.
            _loadUnreadCount();
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 28,
                  color: Color(0xFF1E293B),
                ),
                if (_showNotificationDot)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        // User preference: soft lavender dot
                        color: AppColors.softLavender,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider _resolveAvatarImage() {
    final imagePath = widget.avatarPath ?? _userSession.profileImage;
    final source = imagePath?.trim();

    if (source == null || source.isEmpty) {
      return AssetImage(widget.fallbackAssetPath);
    }

    if (source.startsWith('assets/')) {
      return AssetImage(source);
    }

    final file = File(source);
    if (file.existsSync()) {
      return FileImage(file);
    }

    final remoteUrl =
        source.startsWith('http://') || source.startsWith('https://')
        ? source
        : 'http://smartclinicccc.runasp.net/${source.startsWith('/') ? source.substring(1) : source}';
    return NetworkImage(remoteUrl);
  }
}
