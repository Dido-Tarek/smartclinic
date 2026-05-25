import 'package:equatable/equatable.dart';

enum OtpBoxState { empty, filled, verified, error }

abstract class OtpState extends Equatable {
  const OtpState();
  @override
  List<Object?> get props => [];
}

/// Initial state — OTP generated and waiting for input
class OtpInitial extends OtpState {
  final String generatedOtp;
  final String maskedEmail;

  const OtpInitial({required this.generatedOtp, required this.maskedEmail});

  @override
  List<Object?> get props => [generatedOtp, maskedEmail];
}

/// User is typing — carries current 4-char input
class OtpTyping extends OtpState {
  final String currentInput; // 0–4 chars
  final String generatedOtp;
  final String maskedEmail;

  const OtpTyping({
    required this.currentInput,
    required this.generatedOtp,
    required this.maskedEmail,
  });

  @override
  List<Object?> get props => [currentInput, generatedOtp, maskedEmail];
}

/// Verify pressed and OTP matches → boxes turn green
class OtpVerified extends OtpState {
  final String generatedOtp;
  final String maskedEmail;

  const OtpVerified({required this.generatedOtp, required this.maskedEmail});

  @override
  List<Object?> get props => [generatedOtp, maskedEmail];
}

/// Verify pressed but OTP does not match
class OtpInvalid extends OtpState {
  final String currentInput;
  final String generatedOtp;
  final String maskedEmail;

  const OtpInvalid({
    required this.currentInput,
    required this.generatedOtp,
    required this.maskedEmail,
  });

  @override
  List<Object?> get props => [currentInput, generatedOtp, maskedEmail];
}

/// OTP was resent — new code generated
class OtpResent extends OtpState {
  final String generatedOtp;
  final String maskedEmail;

  const OtpResent({required this.generatedOtp, required this.maskedEmail});

  @override
  List<Object?> get props => [generatedOtp, maskedEmail];
}
