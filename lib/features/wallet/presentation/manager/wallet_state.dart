import 'package:equatable/equatable.dart';
import 'package:smartclinic/features/wallet/data/model/wallet_response_model.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

// ── Shared ────────────────────────────────────────────────────────────────────

class WalletInitial extends WalletState {
  const WalletInitial();
}

// ── Create payment intent ─────────────────────────────────────────────────────

class CreatePaymentIntentLoading extends WalletState {
  const CreatePaymentIntentLoading();
}

class CreatePaymentIntentSuccess extends WalletState {
  final CreatePaymentIntentResponseModel response;

  const CreatePaymentIntentSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class CreatePaymentIntentFailure extends WalletState {
  final String errorMessage;

  const CreatePaymentIntentFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── Top-up (dev/testing) ──────────────────────────────────────────────────────

class TopUpLoading extends WalletState {
  const TopUpLoading();
}

class TopUpSuccess extends WalletState {
  final TopUpResponseModel response;

  const TopUpSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class TopUpFailure extends WalletState {
  final String errorMessage;

  const TopUpFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── Get balance ───────────────────────────────────────────────────────────────

class GetBalanceLoading extends WalletState {
  const GetBalanceLoading();
}

class GetBalanceSuccess extends WalletState {
  final WalletBalanceResponseModel response;

  const GetBalanceSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class GetBalanceFailure extends WalletState {
  final String errorMessage;

  const GetBalanceFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── Get history ───────────────────────────────────────────────────────────────

class GetHistoryLoading extends WalletState {
  const GetHistoryLoading();
}

class GetHistorySuccess extends WalletState {
  final WalletHistoryResponseModel response;

  const GetHistorySuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class GetHistoryFailure extends WalletState {
  final String errorMessage;

  const GetHistoryFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── Get clinic balance ──────────────────────────────────────────────────────

class GetClinicBalanceLoading extends WalletState {
  const GetClinicBalanceLoading();
}

class GetClinicBalanceSuccess extends WalletState {
  final WalletBalanceResponseModel response;

  const GetClinicBalanceSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class GetClinicBalanceFailure extends WalletState {
  final String errorMessage;

  const GetClinicBalanceFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
