import 'package:equatable/equatable.dart';
import 'package:smartclinic/features/nouga/data/model/nouga_ai_response_model.dart';

abstract class SendMessageState extends Equatable {
  const SendMessageState();

  @override
  List<Object?> get props => [];
}

/// Initial idle state — no action taken yet
class SendMessageInitial extends SendMessageState {
  const SendMessageInitial();
}

/// Waiting for the API response
class SendMessageLoading extends SendMessageState {
  const SendMessageLoading();
}

/// API returned a successful response
class SendMessageSuccess extends SendMessageState {
  final SendMessageResponseModel response;

  const SendMessageSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

/// API call failed — errorMessage comes directly from ApiErrorHandler
class SendMessageFailure extends SendMessageState {
  final String errorMessage;

  const SendMessageFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
