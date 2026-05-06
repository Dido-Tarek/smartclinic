import 'dart:convert';

import 'package:smartclinic/core/helper/shared_preds_helper.dart';

class NougaConversationStore {
  static const String _storageKey = 'nouga_conversations_v1';

  Future<List<NougaConversation>> loadConversations() async {
    final raw = SharedPrefsHelper.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <NougaConversation>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <NougaConversation>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => NougaConversation.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <NougaConversation>[];
    }
  }

  Future<void> saveConversations(List<NougaConversation> conversations) async {
    final payload = jsonEncode(
      conversations.map((conversation) => conversation.toJson()).toList(),
    );
    await SharedPrefsHelper.setData(_storageKey, payload);
  }
}

class NougaConversation {
  final String id;
  final String title;
  final int updatedAtMillis;
  final List<NougaChatRecord> messages;

  const NougaConversation({
    required this.id,
    required this.title,
    required this.updatedAtMillis,
    required this.messages,
  });

  NougaConversation copyWith({
    String? id,
    String? title,
    int? updatedAtMillis,
    List<NougaChatRecord>? messages,
  }) {
    return NougaConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'updatedAtMillis': updatedAtMillis,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  factory NougaConversation.fromJson(Map<String, dynamic> json) {
    final messagesRaw = json['messages'];
    final parsedMessages = messagesRaw is List
        ? messagesRaw
              .whereType<Map>()
              .map(
                (item) => NougaChatRecord.fromJson(
                  item.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList()
        : <NougaChatRecord>[];

    return NougaConversation(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'New Conversation').toString(),
      updatedAtMillis: (json['updatedAtMillis'] is int)
          ? json['updatedAtMillis'] as int
          : DateTime.now().millisecondsSinceEpoch,
      messages: parsedMessages,
    );
  }
}

class NougaChatRecord {
  final String text;
  final bool isUser;
  final String time;

  const NougaChatRecord({
    required this.text,
    required this.isUser,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'text': text, 'isUser': isUser, 'time': time};
  }

  factory NougaChatRecord.fromJson(Map<String, dynamic> json) {
    return NougaChatRecord(
      text: (json['text'] ?? '').toString(),
      isUser: json['isUser'] == true,
      time: (json['time'] ?? '').toString(),
    );
  }
}
