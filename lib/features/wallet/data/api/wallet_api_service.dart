import 'package:dio/dio.dart';
import 'package:smartclinic/features/wallet/data/model/wallet_request_model.dart';
import 'package:smartclinic/features/wallet/data/model/wallet_response_model.dart';

class WalletApiService {
  final Dio _dio;

  WalletApiService(this._dio);

  static const String _createPaymentIntentEndpoint =
      '/api/Wallet/create-payment-intent';
  static const String _topUpEndpoint = '/api/Wallet/top-up';
  static const String _historyEndpoint = '/api/Wallet/history';
  static const String _balanceEndpoint = '/api/Wallet/balance';
  static const String _stripeWebhookEndpoint = '/api/StripeWebhook';

  // ── POST /api/Wallet/create-payment-intent ───────────────────────────────
  // Sends amount as a raw number body — used for real Stripe payments.
  Future<CreatePaymentIntentResponseModel> createPaymentIntent(
    CreatePaymentIntentRequestModel request,
  ) async {
    final response = await _dio.post(
      _createPaymentIntentEndpoint,
      data: request.toJson(),
    );
    return CreatePaymentIntentResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── POST /api/Wallet/top-up ───────────────────────────────────────────────
  // DEV / TESTING ONLY — tops up wallet directly without going through Stripe.
  Future<TopUpResponseModel> topUp(TopUpRequestModel request) async {
    final response = await _dio.post(_topUpEndpoint, data: request.toJson());
    return TopUpResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── GET /api/Wallet/balance ───────────────────────────────────────────────
  Future<WalletBalanceResponseModel> getBalance() async {
    final response = await _dio.get(_balanceEndpoint);
    return WalletBalanceResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── GET /api/Wallet/history ───────────────────────────────────────────────
  Future<WalletHistoryResponseModel> getHistory() async {
    final response = await _dio.get(_historyEndpoint);

    // Handle both wrapped { transactions: [...] } and raw [...] responses
    if (response.data is List) {
      return WalletHistoryResponseModel.fromList(
        response.data as List<dynamic>,
      );
    }
    return WalletHistoryResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── POST /api/StripeWebhook ───────────────────────────────────────────────
  // Called by Stripe server — normally not called from the app directly.
  // Exposed here for completeness / internal testing.
  Future<void> stripeWebhook() async {
    await _dio.post(_stripeWebhookEndpoint);
  }
}
