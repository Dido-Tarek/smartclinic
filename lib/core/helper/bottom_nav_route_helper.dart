import 'package:flutter/material.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/routes/app_routes.dart';

class BottomNavRouteHelper {
  const BottomNavRouteHelper._();

  static Future<void> handleSelection(
    BuildContext context,
    int index, {
    required UserRole userRole,
    required int currentIndex,
  }) async {
    if (index == currentIndex) {
      return;
    }

    switch (index) {
      case 0:
        await Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
        return;
      case 1:
        await Navigator.pushNamed(context, AppRoutes.inbox);
        return;
      case 2:
        await Navigator.pushNamed(
          context,
          AppRoutes.appointments,
          arguments: const {'initialIndex': 0},
        );
        return;
      case 3:
        await Navigator.pushNamed(context, _resolveProfileRoute(userRole));
        return;
      default:
        return;
    }
  }

  static String _resolveProfileRoute(UserRole userRole) {
    // Always open the centralized User Management page.
    // That page adapts its content based on the current logged-in user's role.
    return AppRoutes.userManagement;
  }
}
