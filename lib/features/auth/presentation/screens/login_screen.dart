import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/features/auth/data/models/login_request_model.dart';
import 'package:smartclinic/features/auth/presentation/manager/login_cubit.dart';
import 'package:smartclinic/features/auth/presentation/manager/login_state.dart';
import 'package:smartclinic/injection_dependency.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<LoginCubit>(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          state.whenOrNull(
            success: (data) async {
              final userSession = getIt<UserSession>();
              final userId = _extractUserId(data);
              final token = _extractToken(data);
              final selectedRole = userSession.roleString ?? 'Patient';
              final role = _extractRole(data) ?? selectedRole;

              if (token != null && userId != null) {
                await userSession.saveUserSession(
                  token: token,
                  userId: userId,
                  role: role,
                );
              } else {
                if (userId != null) {
                  await userSession.saveUserId(userId);
                }
                await userSession.saveRole(role);
              }

              if (!context.mounted) {
                return;
              }
              Navigator.pushReplacementNamed(context, _resolveHomeRoute(role));
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.error,
                ),
              );
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Scaffold(
            backgroundColor: const Color(0xFFF2F4F7),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    width: 360,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6F9),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: const Color(0xFF6B7A8A),
                        width: 1,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              localizations.translate('login_welcome_back'),
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF161B22),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              localizations.translate(
                                'login_subtitle_manage_account',
                              ),
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            localizations.translate('Email_title'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppTextFormField(
                            controller: _emailController,
                            hintText: localizations.translate(
                              'login_enter_email',
                            ),
                            type: TextFormFieldType.text,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty || !email.contains('@')) {
                                return localizations.translate(
                                  'login_invalid_email',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          Text(
                            localizations.translate('Password_title'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppTextFormField(
                            controller: _passwordController,
                            hintText: localizations.translate(
                              'login_enter_password',
                            ),
                            type: TextFormFieldType.password,
                            validator: (value) {
                              if ((value ?? '').length < 8) {
                                return localizations.translate(
                                  'login_password_min_length',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showComingSoon(context),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1A2D42),
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                localizations.translate(
                                  'login_forgot_password',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _ActionButton(
                            text: isLoading
                                ? localizations.translate('loading')
                                : localizations.translate('auth_login'),
                            onPressed: isLoading
                                ? null
                                : () => _onLoginPressed(context),
                          ),
                          const SizedBox(height: 10),
                          _GoogleButton(
                            text: localizations.translate(
                              'login_google_sign_in',
                            ),
                            onPressed: () => _showComingSoon(context),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  localizations.translate('login_no_account'),
                                  style: const TextStyle(
                                    color: Color(0xFF3A4653),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.accountSelection,
                                    );
                                  },
                                  child: Text(
                                    localizations.translate('login_sign_up'),
                                    style: const TextStyle(
                                      color: Color(0xFF1A2D42),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onLoginPressed(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<LoginCubit>().emitLogin(
      LoginRequestModel(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.translate('login_coming_soon'))),
    );
  }

  String? _extractUserId(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is Map) {
      final direct =
          data['userId'] ??
          data['user_id'] ??
          data['patientId'] ??
          data['patient_id'] ??
          data['id'];
      if (direct != null && direct.toString().trim().isNotEmpty) {
        return direct.toString().trim();
      }

      for (final value in data.values) {
        final nested = _extractUserId(value);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    if (data is List) {
      for (final value in data) {
        final nested = _extractUserId(value);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return null;
  }

  String? _extractToken(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is Map) {
      final direct =
          data['token'] ??
          data['accessToken'] ??
          data['access_token'] ??
          data['jwt'] ??
          data['jwtToken'];
      if (direct != null && direct.toString().trim().isNotEmpty) {
        return direct.toString().trim();
      }

      for (final value in data.values) {
        final nested = _extractToken(value);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    if (data is List) {
      for (final value in data) {
        final nested = _extractToken(value);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return null;
  }

  String? _extractRole(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is Map) {
      final direct =
          data['role'] ??
          data['userRole'] ??
          data['user_role'] ??
          data['accountType'];
      if (direct != null && direct.toString().trim().isNotEmpty) {
        return direct.toString().trim();
      }

      for (final value in data.values) {
        final nested = _extractRole(value);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    if (data is List) {
      for (final value in data) {
        final nested = _extractRole(value);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return null;
  }

  String _resolveHomeRoute(String role) {
    final roleEnum = getRoleEnum(role);
    if (roleEnum.isDoctor) {
      return AppRoutes.doctorhome;
    }
    if (roleEnum.isHospital) {
      return AppRoutes.hospitalhome;
    }
    return AppRoutes.patienthome;
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A2D42),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed, required this.text});

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A2D42),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: Text(
                'G',
                style: TextStyle(
                  color: Color(0xFFDB4437),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
