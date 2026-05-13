import 'package:dartz/dartz.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/features/wallet/data/model/wallet_request_model.dart';
import 'package:smartclinic/features/wallet/data/model/wallet_response_model.dart';
import '../api/wallet_api_service.dart';

abstract class WalletRepo {
  Future<Either<String, CreatePaymentIntentResponseModel>> createPaymentIntent(
    num amount,
  );

  /// DEV / TESTING ONLY — tops up wallet directly without Stripe.
  Future<Either<String, TopUpResponseModel>> topUp(num amount);

  Future<Either<String, WalletBalanceResponseModel>> getBalance();

  Future<Either<String, WalletHistoryResponseModel>> getHistory();
}

class WalletRepoImpl implements WalletRepo {
  final WalletApiService _apiService;

  WalletRepoImpl(this._apiService);

  @override
  Future<Either<String, CreatePaymentIntentResponseModel>> createPaymentIntent(
    num amount,
  ) async {
    try {
      final result = await _apiService.createPaymentIntent(
        CreatePaymentIntentRequestModel(amount: amount),
      );
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, TopUpResponseModel>> topUp(num amount) async {
    try {
      final result = await _apiService.topUp(TopUpRequestModel(amount: amount));
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, WalletBalanceResponseModel>> getBalance() async {
    try {
      final result = await _apiService.getBalance();
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, WalletHistoryResponseModel>> getHistory() async {
    try {
      final result = await _apiService.getHistory();
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
