import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double buttonWidth = width ?? screenWidth * 0.85;
    final double buttonHeight = height ?? screenHeight * 0.07;

    return Center(
      child: PhysicalModel(
        color: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color ?? AppColors.deepNavy,
              foregroundColor: AppColors.scaffoldBg,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
