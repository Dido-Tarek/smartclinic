import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/clinic_admin/presentation/manager/clinic_admin_cubit.dart';
import 'package:smartclinic/features/home/presentation/screens/home_screen.dart';
import 'package:smartclinic/features/home/presentation/screens/hospital_home_screen.dart';
import 'package:smartclinic/injection_dependency.dart';

enum UserRole { patient, doctor, hospital }

class HomeRoleWrapper extends StatelessWidget {
  final UserRole userRole;

  const HomeRoleWrapper({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    // توجيه المستخدم للشاشة المناسبة بناءً على دوره
    switch (userRole) {
      case UserRole.hospital:
        return BlocProvider(
          create: (_) => getIt<ClinicAdminCubit>()..getFullDashboard(5),
          child: const HospitalHomePage(clinicId: 5),
        );
      case UserRole.patient:
      case UserRole.doctor:
        return const HomeScreen();
    }
  }
}
