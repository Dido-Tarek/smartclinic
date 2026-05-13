// ── POST /api/Wallet/create-payment-intent ────────────────────────────────────
// Body is a raw number (amount in EGP)
class CreatePaymentIntentRequestModel {
  final num amount;

  const CreatePaymentIntentRequestModel({required this.amount});

  num toJson() => amount;
}

// ── POST /api/Wallet/top-up (dev/testing only) ────────────────────────────────
// Body is a raw number (amount to top up directly without Stripe)
class TopUpRequestModel {
  final num amount;

  const TopUpRequestModel({required this.amount});

  num toJson() => amount;
}
