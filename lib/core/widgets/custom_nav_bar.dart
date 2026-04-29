import 'package:flutter/material.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onChatbotPressed;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onChatbotPressed,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // إحنا هنا بنصمم الـ Bar فقط، والـ Scaffold هو اللي هيتحكم في الـ Location
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 70,
        child: Row(
          children: [
            // الجزء الأيسر
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    Icons.store_mall_directory_rounded,
                    localizations.translate('home_icon_title'),
                    0,
                  ),
                  _buildNavItem(
                    Icons.chat_bubble_outline_rounded,
                    localizations.translate('inbox_icon_title'),
                    1,
                  ),
                ],
              ),
            ),

            // فراغ الـ FloatingActionButton
            const SizedBox(width: 80),

            // الجزء الأيمن
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    Icons.assignment_turned_in_outlined,
                    localizations.translate('booking_icon_title'),
                    2,
                  ),
                  _buildNavItem(
                    Icons.person_outline_rounded,
                    localizations.translate('profile_icon_title'),
                    3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget مساعد لبناء الأيقونات
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.skyBlue : AppColors.textSecondary,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.skyBlue : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ميثود استاتيك عشان ترجع الـ FloatingActionButton بنفس الستايل في كل الصفحات
  static Widget buildChatbotButton({required VoidCallback onPressed}) {
    return Container(
      height: 70,
      width: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.deepNavy, // اللون الداكن المحيط بالبوت
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: onPressed,
        child: Image.asset(AppImages.imagesIconsNougaAI), // تأكد من المسار
      ),
    );
  }
}
