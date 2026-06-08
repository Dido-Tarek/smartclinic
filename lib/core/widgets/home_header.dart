import 'dart:io';

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

class _HomeHeaderState extends State<HomeHeader> {
  bool _showNotificationDot = false;
  late final UserSession _userSession;

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
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
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: _resolveAvatarImage(),
          backgroundColor: AppColors.scaffoldBg,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: TextStyle(
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
          onTap: widget.onNotificationTap,
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
                  const Positioned(
                    top: 10,
                    right: 12,
                    child: SizedBox(
                      width: 10,
                      height: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.softLavender,
                          shape: BoxShape.circle,
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
