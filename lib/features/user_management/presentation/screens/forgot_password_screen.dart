import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_cubit.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? sourceRoute;
  const ForgotPasswordScreen({super.key, this.sourceRoute});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<UserManagementCubit>().forgotPassword(
      _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const CustomAppBar(
        title: 'Forgot Your Password?',
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
          } else if (state is ForgotPasswordSuccess) {
            Navigator.pushNamed(
              context,
              AppRoutes.verification,
              arguments: {
                'email': _emailController.text.trim(),
                'isResetPassword': true,
                'debugToken': state.token,
                'sourceRoute': widget.sourceRoute,
              },
            );
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
                    'Enter your email or your phone number, we will send you confirmation code',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  AppTextFormField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
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
                            'Reset Password',
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
