import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/localization/app_localization.dart';

class SearchEngineBar extends StatelessWidget {
  final String? hintText;
  final VoidCallback? onTap;

  const SearchEngineBar({super.key, this.hintText, this.onTap});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to search screen
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
      },
      child: AbsorbPointer(
        // Prevent keyboard from showing — it's a navigation tap target only
        child: TextFormField(
          readOnly: true,
          style: TextStyle(
            color: AppColors.deepNavy.withValues(alpha: 0.5),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: localizations.translate('search_hint'),
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),

            // ── Left: stethoscope icon ──────────────────────────────
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 18, right: 10),
              child: Image.asset(AppImages.iconssthethoscope),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),

            // ── Right: search icon ──────────────────────────────────
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Icon(
                Icons.search_rounded,
                color: AppColors.skyBlue,
                size: 24,
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),

            filled: true,
            fillColor: AppColors.cardBg,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),

            // ── Borders — matches AppTextFormField style ────────────
            border: _buildBorder(),
            enabledBorder: _buildBorder(color: AppColors.deepNavy),
            focusedBorder: _buildBorder(color: AppColors.skyBlue, width: 1.5),
            errorBorder: _buildBorder(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder({Color? color, double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(50), // pill shape
      borderSide: color != null
          ? BorderSide(color: color, width: width)
          : BorderSide.none,
    );
  }
}
