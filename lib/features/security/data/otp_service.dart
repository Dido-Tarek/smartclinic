import 'dart:math';

/// Generates and validates a 4-digit OTP locally (no backend involved).
class OtpService {
  static final Random _random = Random.secure();

  /// Returns a new random 4-digit OTP string e.g. "5644".
  /// Every call produces a different code.
  static String generateOtp() {
    final code = 1000 + _random.nextInt(9000); // guaranteed 4 digits: 1000–9999
    return code.toString();
  }

  /// Returns true if [input] exactly matches [expectedOtp].
  static bool verifyOtp(String input, String expectedOtp) =>
      input.trim() == expectedOtp.trim();
}
