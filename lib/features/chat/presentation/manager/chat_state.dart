import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartclinic/features/chat/data/model/chat_model.dart';

part 'chat_state.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState.initial() = _Initial;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.messageSent(dynamic data) = _MessageSent;
  const factory ChatState.historyLoaded(List<MessageModel> messages) =
      _HistoryLoaded;
  const factory ChatState.markedAsSeen(dynamic data) = _MarkedAsSeen;
  const factory ChatState.error({required String message}) = _Error;
}
