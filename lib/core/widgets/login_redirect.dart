import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/localization/app_localization.dart';

class LoginRedirectSection extends StatelessWidget {
  final bool canLogin;
  final VoidCallback? onLoginPressed;

  const LoginRedirectSection({
    super.key,
    this.canLogin = true, // القيمة الافتراضية متاح
    this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    final loginStyle = TextStyle(
      color: canLogin ? AppColors.textPrimary : AppColors.textSecondary,
      fontSize: width * 0.04,
      fontWeight: FontWeight.bold,
      decoration: canLogin ? TextDecoration.underline : TextDecoration.none,
      decorationColor: AppColors.textPrimary,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          localizations.translate("auth_already_have_account"),
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: width * 0.04,
          ),
        ),
        SizedBox(width: width * 0.02),
        GestureDetector(
          onTap: canLogin ? onLoginPressed : null,
          child: Text(localizations.translate("auth_login"), style: loginStyle),
        ),
      ],
    );
  }
}
