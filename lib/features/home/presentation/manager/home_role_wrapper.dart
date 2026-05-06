import 'package:flutter/material.dart';
import 'package:smartclinic/features/home/presentation/screens/home_screen.dart';
import 'package:smartclinic/features/home/presentation/screens/hospital_home_screen.dart';

enum UserRole { patient, doctor, hospital }

class HomeRoleWrapper extends StatelessWidget {
  final UserRole userRole;

  const HomeRoleWrapper({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    // توجيه المستخدم للشاشة المناسبة بناءً على دوره
    switch (userRole) {
      case UserRole.hospital:
        return const HospitalHomeScreen();
      case UserRole.patient:
      case UserRole.doctor:
        return const HomeScreen();
    }
  }
}
