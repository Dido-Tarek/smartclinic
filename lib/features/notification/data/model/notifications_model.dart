import 'package:json_annotation/json_annotation.dart';

part 'notifications_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawMessage = json['message']?.toString().trim() ?? '';
    final derivedTitle = _deriveTitle(rawMessage);
    final createdAt = _deriveCreatedAt(json);

    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString().trim().isNotEmpty == true
          ? json['title'].toString().trim()
          : derivedTitle,
      message: rawMessage,
      createdAt: createdAt,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  static String _deriveTitle(String message) {
    if (message.isEmpty) {
      return 'Notification';
    }

    final separatorIndex = message.indexOf(':');
    if (separatorIndex > 0) {
      final title = message.substring(0, separatorIndex).trim();
      if (title.isNotEmpty) {
        return title;
      }
    }

    return 'Notification';
  }

  static String _deriveCreatedAt(Map<String, dynamic> json) {
    final timeAgo = json['timeAgo']?.toString().trim() ?? '';
    if (timeAgo.isNotEmpty) {
      return timeAgo;
    }

    final time = json['time']?.toString().trim() ?? '';
    if (time.isNotEmpty) {
      return time;
    }

    final createdAt = json['createdAt']?.toString().trim() ?? '';
    if (createdAt.isNotEmpty) {
      return createdAt;
    }

    return '';
  }
}

@JsonSerializable()
class UnreadCountResponse {
  final int count;

  UnreadCountResponse({required this.count});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);
}
