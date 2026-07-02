import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/features/user_management/data/model/reset_password_request_model.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_cubit.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_state.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  final String token;
  final String? sourceRoute;

  const CreateNewPasswordScreen({
    super.key,
    required this.email,
    required this.token,
    this.sourceRoute,
  });

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final request = ResetPasswordRequest(
      email: widget.email,
      token: widget.token,
      newPassword: _passwordController.text,
    );
    context.read<UserManagementCubit>().resetPassword(request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const CustomAppBar(
        title: 'Create New Password',
        showBackButton: true,
        showNotification: false,
      ),
      body: BlocConsumer<UserManagementCubit, UserManagementState>(
        listener: (context, state) {
          if (state is UserManagementLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is UserManagementError) {
            CherryToast.error(
              title: const Text('Error'),
              description: Text(state.message),
            ).show(context);
          } else if (state is UserManagementSuccess) {
            CherryToast.success(
              title: const Text('Success'),
              description: const Text('Password reset successfully'),
            ).show(context);

            Future.delayed(const Duration(milliseconds: 1500), () {
              if (context.mounted && widget.sourceRoute != null) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  widget.sourceRoute!,
                  (route) => false,
                );
              } else if (context.mounted) {
                Navigator.pop(context);
              }
            });
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Create your new password to login',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  AppTextFormField(
                    controller: _passwordController,
                    hintText: 'Password',
                    type: TextFormFieldType.password,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextFormField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    type: TextFormFieldType.password,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.skyBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Create Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
