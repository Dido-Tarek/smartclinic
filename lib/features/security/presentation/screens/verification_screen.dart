import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/features/security/presentation/manager/otp_cubit.dart';
import 'package:smartclinic/features/security/presentation/manager/otp_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — provides OtpCubit with the email from the previous screen
// ─────────────────────────────────────────────────────────────────────────────
class VerificationPage extends StatelessWidget {
  final String email;
  const VerificationPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpCubit(email: email),
      child: const _VerificationScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class _VerificationScreen extends StatefulWidget {
  const _VerificationScreen();

  @override
  State<_VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<_VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _otpRequested = false;

  String get _fullInput => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    // Rebuild on focus change so box border updates reactively
    for (final f in _focusNodes) {
      f.addListener(() => setState(() {}));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _otpRequested) {
        return;
      }
      _otpRequested = true;
      final cubit = context.read<OtpCubit>();
      cubit.generateOtp();
      _syncBoxesWithCode(_generatedCodeFromState(cubit.state));
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 4 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final next = (digits.length - 1).clamp(0, 3);
      _focusNodes[next].requestFocus();
    } else if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    context.read<OtpCubit>().onInputChanged(_fullInput);
    setState(() {});
  }

  void _onKeyDown(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey.keyLabel == 'Backspace' &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _clearBoxes() {
    for (final c in _controllers) c.clear();
    setState(() {});
    _focusNodes[0].requestFocus();
  }

  void _syncBoxesWithCode(String code) {
    final digits = code.replaceAll(RegExp(r'\D'), '');
    for (var index = 0; index < _controllers.length; index++) {
      final value = index < digits.length ? digits[index] : '';
      _controllers[index].text = value;
    }
    setState(() {});
  }

  String _generatedCodeFromState(OtpState state) {
    if (state is OtpInitial) return state.generatedOtp;
    if (state is OtpTyping) return state.generatedOtp;
    if (state is OtpVerified) return state.generatedOtp;
    if (state is OtpInvalid) return state.generatedOtp;
    if (state is OtpResent) return state.generatedOtp;
    return '';
  }

  void _onVerify() => context.read<OtpCubit>().verify(_fullInput);

  void _onResend() {
    _clearBoxes();
    context.read<OtpCubit>().resend();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('A new code has been sent to your email.'),
        backgroundColor: AppColors.skyBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpCubit, OtpState>(
      listener: (context, state) {
        final maskedEmail = _maskedEmailFromState(state);
        final generatedCode = _generatedCodeFromState(state);

        if (generatedCode.isNotEmpty && state is! OtpInvalid) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _syncBoxesWithCode(generatedCode);
            }
          });
        }

        if (state is OtpVerified) {
          Future.delayed(const Duration(milliseconds: 700), () {
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (r) => false,
              );
            }
          });
        }
        if (state is OtpResent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification code generated for $maskedEmail'),
              backgroundColor: AppColors.skyBlue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        if (state is OtpInvalid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Incorrect code. Please try again.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          _clearBoxes();
        }
      },
      builder: (context, state) {
        final isVerified = state is OtpVerified;
        final isInvalid = state is OtpInvalid;

        String maskedEmail = '';
        if (state is OtpInitial) maskedEmail = state.maskedEmail;
        if (state is OtpTyping) maskedEmail = state.maskedEmail;
        if (state is OtpVerified) maskedEmail = state.maskedEmail;
        if (state is OtpInvalid) maskedEmail = state.maskedEmail;
        if (state is OtpResent) maskedEmail = state.maskedEmail;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldBg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.deepNavy),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // ── Title ──────────────────────────────────────────────
                  Text(
                    'Enter Verification Code',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepNavy,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Subtitle ───────────────────────────────────────────
                  Text(
                    'Enter code that we have sent to your\nmail $maskedEmail',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── 4 OTP boxes ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      return _OtpBox(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        isVerified: isVerified,
                        isError: isInvalid,
                        onChanged: (v) => _onDigitChanged(i, v),
                        onKey: (e) => _onKeyDown(i, e),
                      );
                    }),
                  ),

                  const SizedBox(height: 48),

                  // ── Verify button ──────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isVerified ? null : _onVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepNavy,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(
                          0xFF4CAF50,
                        ), // green when verified
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isVerified ? 'Verified ✓' : 'Verify',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Resend ─────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _onResend,
                        child: Text(
                          'Resend',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _maskedEmailFromState(OtpState state) {
    if (state is OtpInitial) return state.maskedEmail;
    if (state is OtpTyping) return state.maskedEmail;
    if (state is OtpVerified) return state.maskedEmail;
    if (state is OtpInvalid) return state.maskedEmail;
    if (state is OtpResent) return state.maskedEmail;
    return '';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single OTP digit box
// ─────────────────────────────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isVerified;
  final bool isError;
  final ValueChanged<String> onChanged;
  final ValueChanged<RawKeyEvent> onKey;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isVerified,
    required this.isError,
    required this.onChanged,
    required this.onKey,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFocus = focusNode.hasFocus;
    final bool hasValue = controller.text.isNotEmpty;

    final Color borderColor;
    final Color fillColor;
    final Color textColor;

    if (isVerified && hasValue) {
      borderColor = const Color(0xFF4CAF50);
      fillColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
    } else if (isError) {
      borderColor = Colors.redAccent;
      fillColor = const Color(0xFFFFF0F0);
      textColor = Colors.redAccent;
    } else if (hasFocus) {
      borderColor = AppColors.skyBlue;
      fillColor = Colors.white;
      textColor = AppColors.deepNavy;
    } else if (hasValue) {
      borderColor = AppColors.deepNavy.withValues(alpha: 0.35);
      fillColor = Colors.white;
      textColor = AppColors.deepNavy;
    } else {
      borderColor = const Color(0xFFE2E8F0);
      fillColor = Colors.white;
      textColor = AppColors.deepNavy;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: 64,
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.8),
        boxShadow: (isVerified && hasValue)
            ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : hasFocus
            ? [
                BoxShadow(
                  color: AppColors.skyBlue.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: onKey,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
