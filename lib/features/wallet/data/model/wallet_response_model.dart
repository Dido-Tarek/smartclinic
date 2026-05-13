// ── POST /api/Wallet/create-payment-intent response ───────────────────────────
class CreatePaymentIntentResponseModel {
  final String? clientSecret;
  final String? paymentIntentId;

  const CreatePaymentIntentResponseModel({
    this.clientSecret,
    this.paymentIntentId,
  });

  factory CreatePaymentIntentResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => CreatePaymentIntentResponseModel(
    clientSecret: json['clientSecret'] as String?,
    paymentIntentId: json['paymentIntentId'] as String?,
  );
}

// ── POST /api/Wallet/top-up response ─────────────────────────────────────────
class TopUpResponseModel {
  final num? newBalance;
  final String? message;

  const TopUpResponseModel({this.newBalance, this.message});

  factory TopUpResponseModel.fromJson(Map<String, dynamic> json) =>
      TopUpResponseModel(
        newBalance: json['newBalance'] as num?,
        message: json['message'] as String?,
      );
}

// ── GET /api/Wallet/balance response ─────────────────────────────────────────
class WalletBalanceResponseModel {
  final num? balance;
  final String? currency;

  const WalletBalanceResponseModel({this.balance, this.currency});

  factory WalletBalanceResponseModel.fromJson(Map<String, dynamic> json) =>
      WalletBalanceResponseModel(
        balance: json['balance'] as num?,
        currency: json['currency'] as String?,
      );
}

// ── GET /api/Wallet/history — single transaction ──────────────────────────────
class WalletTransactionModel {
  final String? id;
  final String? type; // e.g. 'top-up', 'payment', 'refund'
  final num? amount;
  final String? description;
  final String? createdAt;
  final String? status;

  const WalletTransactionModel({
    this.id,
    this.type,
    this.amount,
    this.description,
    this.createdAt,
    this.status,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionModel(
        id: json['id'] as String?,
        type: json['type'] as String?,
        amount: json['amount'] as num?,
        description: json['description'] as String?,
        createdAt: json['createdAt'] as String?,
        status: json['status'] as String?,
      );
}

// ── GET /api/Wallet/history response ─────────────────────────────────────────
class WalletHistoryResponseModel {
  final List<WalletTransactionModel> transactions;

  const WalletHistoryResponseModel({required this.transactions});

  factory WalletHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      WalletHistoryResponseModel(
        transactions:
            (json['transactions'] as List<dynamic>? ??
                    json['data'] as List<dynamic>? ??
                    [])
                .map(
                  (e) => WalletTransactionModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList(),
      );

  /// Fallback when API returns a raw JSON array at root level.
  factory WalletHistoryResponseModel.fromList(List<dynamic> list) =>
      WalletHistoryResponseModel(
        transactions: list
            .map(
              (e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
}
