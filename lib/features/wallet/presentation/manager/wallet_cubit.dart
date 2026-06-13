import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/wallet/data/repo/wallet_repo.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepo _repo;

  WalletCubit(this._repo) : super(const WalletInitial());

  // ── POST /api/Wallet/create-payment-intent ───────────────────────────────
  // Use this for real Stripe payments — pass the returned clientSecret
  // to flutter_stripe's PaymentSheet.
  Future<void> createPaymentIntent(num amount) async {
    emit(const CreatePaymentIntentLoading());

    final result = await _repo.createPaymentIntent(amount);

    result.fold(
      (error) => emit(CreatePaymentIntentFailure(error)),
      (response) => emit(CreatePaymentIntentSuccess(response)),
    );
  }

  // ── POST /api/Wallet/top-up ───────────────────────────────────────────────
  // DEV / TESTING ONLY — bypasses Stripe and credits wallet directly.
  // Use this while developing to simulate a funded wallet.
  Future<void> topUp(num amount) async {
    emit(const TopUpLoading());

    final result = await _repo.topUp(amount);

    result.fold((error) => emit(TopUpFailure(error)), (response) {
      emit(TopUpSuccess(response));
      // Auto-refresh balance after a successful top-up
      getBalance();
    });
  }

  // ── GET /api/Wallet/balance ───────────────────────────────────────────────
  Future<void> getBalance() async {
    emit(const GetBalanceLoading());

    final result = await _repo.getBalance();

    result.fold(
      (error) => emit(GetBalanceFailure(error)),
      (response) => emit(GetBalanceSuccess(response)),
    );
  }

  // ── GET /api/Wallet/history ───────────────────────────────────────────────
  Future<void> getHistory() async {
    emit(const GetHistoryLoading());

    final result = await _repo.getHistory();

    result.fold(
      (error) => emit(GetHistoryFailure(error)),
      (response) => emit(GetHistorySuccess(response)),
    );
  }

  // ── GET /api/Wallet/clinic-balance/{clinicId} ────────────────────────────
  Future<void> getClinicBalance(int clinicId) async {
    emit(const GetClinicBalanceLoading());

    final result = await _repo.getClinicBalance(clinicId);

    result.fold(
      (error) => emit(GetClinicBalanceFailure(error)),
      (response) => emit(GetClinicBalanceSuccess(response)),
    );
  }

  /// Loads balance and history together — use on wallet screen init.
  Future<void> initWallet() async {
    await getBalance();
    await getHistory();
  }

  void reset() => emit(const WalletInitial());
}
