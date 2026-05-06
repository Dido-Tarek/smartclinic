class SendMessageResponseModel {
  final String? reply;
  final String? conversationId;
  final String? message;

  const SendMessageResponseModel({
    this.reply,
    this.conversationId,
    this.message,
  });

  factory SendMessageResponseModel.fromJson(Map<String, dynamic> json) {
    return SendMessageResponseModel(
      reply: (json['reply'] ?? json['botReply'] ?? json['message']) as String?,
      conversationId: json['conversationId'] as String?,
      message: (json['message'] ?? json['botReply'] ?? json['reply']) as String?,
    );
  }
}
