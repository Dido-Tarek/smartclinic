import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/otp_service.dart';
import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({required String email})
    : super(
        OtpInitial(
          generatedOtp: OtpService.generateOtp(),
          maskedEmail: _maskEmail(email),
        ),
      );

  // ── helpers ──────────────────────────────────────────────────────────────

  static String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final masked = name.length <= 3
        ? '${name[0]}***'
        : '${name.substring(0, 3)}***';
    return '$masked@${parts[1]}';
  }

  String get _currentOtp {
    final s = state;
    if (s is OtpInitial) return s.generatedOtp;
    if (s is OtpTyping) return s.generatedOtp;
    if (s is OtpVerified) return s.generatedOtp;
    if (s is OtpInvalid) return s.generatedOtp;
    if (s is OtpResent) return s.generatedOtp;
    return '';
  }

  String get _currentEmail {
    final s = state;
    if (s is OtpInitial) return s.maskedEmail;
    if (s is OtpTyping) return s.maskedEmail;
    if (s is OtpVerified) return s.maskedEmail;
    if (s is OtpInvalid) return s.maskedEmail;
    if (s is OtpResent) return s.maskedEmail;
    return '';
  }

  // ── public API ────────────────────────────────────────────────────────────

  /// Generates a fresh OTP for the current verification session.
  void generateOtp() {
    final maskedEmail = _currentEmail.isEmpty ? _currentEmail : _currentEmail;
    emit(
      OtpResent(
        generatedOtp: OtpService.generateOtp(),
        maskedEmail: maskedEmail,
      ),
    );
  }

  /// Called on every keystroke — [input] is the full current string (0–4 chars)
  void onInputChanged(String input) {
    emit(
      OtpTyping(
        currentInput: input.length > 4 ? input.substring(0, 4) : input,
        generatedOtp: _currentOtp,
        maskedEmail: _currentEmail,
      ),
    );
  }

  /// Called when Verify button is tapped
  void verify(String input) {
    if (OtpService.verifyOtp(input, _currentOtp)) {
      emit(OtpVerified(generatedOtp: _currentOtp, maskedEmail: _currentEmail));
    } else {
      emit(
        OtpInvalid(
          currentInput: input,
          generatedOtp: _currentOtp,
          maskedEmail: _currentEmail,
        ),
      );
    }
  }

  /// Resend — generates a brand new OTP
  void resend() {
    emit(
      OtpResent(
        generatedOtp: OtpService.generateOtp(),
        maskedEmail: _currentEmail,
      ),
    );
  }
}
