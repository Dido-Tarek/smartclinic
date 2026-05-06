import 'package:dio/dio.dart';
import 'package:smartclinic/features/nouga/data/model/nouga_ai_request_model.dart';
import 'package:smartclinic/features/nouga/data/model/nouga_ai_response_model.dart';

class MedicalChatApiService {
  final Dio _dio;

  MedicalChatApiService(this._dio);

  static const String _sendMessageEndpoint = '/api/medical-chat/send';

  Future<SendMessageResponseModel> sendMessage(
    SendMessageRequestModel request,
  ) async {
    final response = await _dio.post(
      _sendMessageEndpoint,
      data: request.toJson(),
    );
    return SendMessageResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
