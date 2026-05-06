import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smartclinic/features/chat/data/model/chat_model.dart';

part 'chat_api_service.g.dart';

@RestApi()
abstract class ChatApiService {
  factory ChatApiService(Dio dio, {String baseUrl}) = _ChatApiService;

  @POST('/api/Chat/send')
  Future<dynamic> sendMessage(@Body() SendMessageRequest request);

  @GET('/api/Chat/history/{otherUserId}')
  Future<List<MessageModel>> getChatHistory(
    @Path("otherUserId") String otherUserId,
  );

  @PUT('/api/Chat/mark-chat-seen/{senderId}')
  Future<dynamic> markChatAsSeen(@Path("senderId") String senderId);
}
