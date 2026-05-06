class SendMessageRequestModel {
  final String patientMessage;
  final String conversationId;

  const SendMessageRequestModel({
    required this.patientMessage,
    required this.conversationId,
  });

  Map<String, dynamic> toJson() => {
    'patientMessage': patientMessage,
    'conversationId': conversationId,
  };
}
