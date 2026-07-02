import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/features/auth/data/models/login_request_model.dart';
import 'package:smartclinic/features/auth/domain/auth_repo.dart';
import 'package:smartclinic/features/auth/presentation/manager/login_cubit.dart';
import 'package:smartclinic/features/auth/presentation/manager/login_state.dart';
import 'package:smartclinic/features/registeration/presentation/screens/facility/license_verification.dart';
import 'package:smartclinic/injection_dependency.dart';
import 'package:smartclinic/core/services/push_notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserSession _userSession = getIt<UserSession>();

  LicenseReviewStatus _reviewStatus = LicenseReviewStatus.pending;
  bool _isReviewStatusLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviewStatusIfNeeded();
    });
  }

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
              final fullName = _extractFullName(data);
              final email = _emailController.text.trim();

              // Clear any clinic IDs from a previous session before saving new ones
              await userSession.clearClinicIds();

              if (token != null && token.trim().isNotEmpty) {
                await userSession.saveToken(token.trim());
              }
              if (userId != null && userId.trim().isNotEmpty) {
                await userSession.saveUserId(userId.trim());
              }
              await userSession.saveRole(role);
              // Record login time so the 3-hour session timer starts now.
              await userSession.saveLoginTimestamp();

              // Re-sync the FCM token to the backend now that the user is
              // authenticated — the token obtained at app startup was not
              // sent because the user was not logged in yet.
              await PushNotificationService.syncTokenAfterLogin();

              if (fullName != null && fullName.trim().isNotEmpty) {
                await userSession.saveFullName(fullName.trim());
              }
              if (email.isNotEmpty) {
                await userSession.saveEmail(email);
              }

              if (!context.mounted) {
                return;
              }
              Navigator.pushReplacementNamed(
                context,
                userSession.resolvePostLoginRoute(
                  role: role,
                  userId: userId ?? userSession.userId ?? '',
                ),
              );
            },
            error: (message) {
              CherryToast.error(
                title: const Text('Error'),
                description: Text(message),
              ).show(context);
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
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.forgotPassword,
                                  arguments: {'sourceRoute': AppRoutes.login},
                                );
                              },
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
                          if (_shouldShowReviewStatus) ...[
                            const SizedBox(height: 12),
                            _buildReviewStatusBadge(localizations),
                          ],
                          // const SizedBox(height: 10),
                          // _GoogleButton(
                          //   text: localizations.translate(
                          //     'login_google_sign_in',
                          //   ),
                          //   onPressed: () => _showComingSoon(context),
                          // ),
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

  bool get _shouldShowReviewStatus {
    final role = getRoleEnum(_userSession.roleString);
    return role.isDoctor || role.isHospital;
  }

  Future<void> _loadReviewStatusIfNeeded() async {
    if (!_shouldShowReviewStatus) {
      return;
    }

    final userId = _userSession.userId?.trim() ?? '';
    if (userId.isEmpty) {
      return;
    }

    setState(() {
      _isReviewStatusLoading = true;
    });

    final response = await getIt<AuthRepo>().getPendingDoctors();
    if (!mounted) {
      return;
    }

    if (response is Success<List<dynamic>>) {
      final matchedStatus = _resolveReviewStatus(userId, response.data);
      if (matchedStatus != null) {
        setState(() {
          _reviewStatus = matchedStatus;
        });
      }
    }

    setState(() {
      _isReviewStatusLoading = false;
    });
  }

  LicenseReviewStatus? _resolveReviewStatus(
    String userId,
    List<dynamic> doctors,
  ) {
    for (final doctor in doctors) {
      if (doctor is! Map) {
        continue;
      }

      final normalized = doctor.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final candidateId =
          normalized['userId'] ?? normalized['doctorId'] ?? normalized['id'];
      if (candidateId?.toString().trim() != userId) {
        continue;
      }

      return _mapStatus(
        normalized['status'] ??
            normalized['approvalStatus'] ??
            normalized['reviewStatus'],
      );
    }

    return LicenseReviewStatus.pending;
  }

  LicenseReviewStatus? _mapStatus(dynamic statusValue) {
    final status = statusValue?.toString().trim().toLowerCase();
    if (status == null || status.isEmpty) {
      return null;
    }

    if (status.contains('approve') ||
        status.contains('done') ||
        status.contains('complete')) {
      return LicenseReviewStatus.done;
    }

    if (status.contains('reject') ||
        status.contains('decline') ||
        status.contains('deny')) {
      return LicenseReviewStatus.rejected;
    }

    return LicenseReviewStatus.pending;
  }

  Widget _buildReviewStatusBadge(AppLocalizations localizations) {
    final statusColor = switch (_reviewStatus) {
      LicenseReviewStatus.done => AppColors.success,
      LicenseReviewStatus.pending => AppColors.warning,
      LicenseReviewStatus.rejected => AppColors.error,
    };

    final statusLabel = switch (_reviewStatus) {
      LicenseReviewStatus.done => localizations.translate(
        'license_status_done',
      ),
      LicenseReviewStatus.pending => localizations.translate(
        'license_status_pending',
      ),
      LicenseReviewStatus.rejected => localizations.translate(
        'license_status_rejected',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isReviewStatusLoading
                  ? localizations.translate('loading')
                  : 'Status: $statusLabel',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
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

  String? _extractFullName(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is Map) {
      final direct =
          data['fullName'] ??
          data['fullname'] ??
          data['name'] ??
          data['userName'] ??
          data['username'];
      if (direct != null && direct.toString().trim().isNotEmpty) {
        return direct.toString().trim();
      }

      for (final value in data.values) {
        final nested = _extractFullName(value);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    if (data is List) {
      for (final value in data) {
        final nested = _extractFullName(value);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return null;
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
