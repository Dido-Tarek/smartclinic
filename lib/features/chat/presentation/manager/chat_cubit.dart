import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/chat/data/repo/chat_repo.dart';
import 'package:smartclinic/features/chat/presentation/manager/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _chatRepo;
  ChatCubit(this._chatRepo) : super(const ChatState.initial());

  Future<void> emitSendMessage({
    required String receiverId,
    required String message,
  }) async {
    emit(const ChatState.loading());
    final response = await _chatRepo.sendMessage(receiverId, message);
    response.when(
      success: (data) => emit(ChatState.messageSent(data)),
      failure: (error) => emit(ChatState.error(message: error)),
    );
  }

  Future<void> emitGetChatHistory(String otherUserId) async {
    emit(const ChatState.loading());
    final response = await _chatRepo.getChatHistory(otherUserId);
    response.when(
      success: (data) => emit(ChatState.historyLoaded(data)),
      failure: (error) => emit(ChatState.error(message: error)),
    );
  }

  Future<void> emitMarkChatAsSeen(String senderId) async {
    emit(const ChatState.loading());
    final response = await _chatRepo.markAsSeen(senderId);
    response.when(
      success: (data) => emit(ChatState.markedAsSeen(data)),
      failure: (error) => emit(ChatState.error(message: error)),
    );
  }
}
