import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/features/chat/data/api/chat_api_service.dart';
import 'package:smartclinic/features/chat/data/model/chat_model.dart';

class ChatRepo {
  final ChatApiService _apiService;
  ChatRepo(this._apiService);

  Future<ApiResult<dynamic>> sendMessage(
    String receiverId,
    String message,
  ) async {
    try {
      final response = await _apiService.sendMessage(
        SendMessageRequest(receiverId: receiverId, message: message),
      );
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  Future<ApiResult<List<MessageModel>>> getChatHistory(
    String otherUserId,
  ) async {
    try {
      final response = await _apiService.getChatHistory(otherUserId);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  Future<ApiResult<dynamic>> markAsSeen(String senderId) async {
    try {
      final response = await _apiService.markChatAsSeen(senderId);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
