import 'package:flutter/material.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/helper/bottom_nav_route_helper.dart';
import 'package:smartclinic/core/helper/user_roles.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final UserRole userRole;
  final VoidCallback onChatbotPressed;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.userRole,
    required this.onChatbotPressed,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SizedBox(
      height: 104,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomAppBar(
              color: Colors.white,
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
                          Expanded(
                            child: _buildNavItem(
                              context,
                              Icons.store_mall_directory_rounded,
                              localizations.translate('home_icon_title'),
                              0,
                            ),
                          ),
                          Expanded(
                            child: _buildNavItem(
                              context,
                              Icons.chat_bubble_outline_rounded,
                              localizations.translate('inbox_icon_title'),
                              1,
                            ),
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
                          Expanded(
                            child: _buildNavItem(
                              context,
                              Icons.assignment_turned_in_outlined,
                              localizations.translate('booking_icon_title'),
                              2,
                            ),
                          ),
                          Expanded(
                            child: _buildNavItem(
                              context,
                              Icons.person_outline_rounded,
                              localizations.translate('profile_icon_title'),
                              3,
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
          Positioned(
            top: 0,
            child: buildChatbotButton(onPressed: onChatbotPressed),
          ),
        ],
      ),
    );
  }

  // Widget مساعد لبناء الأيقونات
  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => BottomNavRouteHelper.handleSelection(
        context,
        index,
        userRole: userRole,
        currentIndex: selectedIndex,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.skyBlue : AppColors.textSecondary,
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? AppColors.skyBlue : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
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
        child: Image.asset(
          AppImages.imagesIconsAssistant,
          width: 45,
          height: 45,
        ), // تأكد من المسار
      ),
    );
  }
}
