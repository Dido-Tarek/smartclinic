import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String timestamp;
  final bool isSeen;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.isSeen,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}

@JsonSerializable()
class SendMessageRequest {
  final String receiverId;
  final String message;

  SendMessageRequest({required this.receiverId, required this.message});

  Map<String, dynamic> toJson() => _$SendMessageRequestToJson(this);
}
