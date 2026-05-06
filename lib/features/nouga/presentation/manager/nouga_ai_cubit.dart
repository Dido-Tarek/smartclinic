import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/nouga/data/model/nouga_ai_request_model.dart';
import 'package:smartclinic/features/nouga/data/repo/nouga_ai_repo.dart';
import 'package:smartclinic/features/nouga/presentation/manager/nouga_ai_state.dart';

class SendMessageCubit extends Cubit<SendMessageState> {
  final MedicalChatRepo _repo;

  SendMessageCubit(this._repo) : super(const SendMessageInitial());

  /// Sends a patient message and emits the appropriate state.
  ///
  /// [patientMessage] — the text typed by the user.
  /// [conversationId] — the active conversation session ID.
  Future<void> sendMessage({
    required String patientMessage,
    required String conversationId,
  }) async {
    // Guard: don't send empty messages
    if (patientMessage.trim().isEmpty) return;

    emit(const SendMessageLoading());

    final request = SendMessageRequestModel(
      patientMessage: patientMessage.trim(),
      conversationId: conversationId,
    );

    final result = await _repo.sendMessage(request);

    result.fold(
      (errorMessage) => emit(SendMessageFailure(errorMessage)),
      (response) => emit(SendMessageSuccess(response)),
    );
  }

  /// Resets the cubit back to its initial state (e.g. on screen dispose).
  void reset() => emit(const SendMessageInitial());
}
