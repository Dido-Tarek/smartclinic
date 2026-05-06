import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/widgets/home_header.dart';

class HospitalHomeScreen extends StatelessWidget {
  const HospitalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              const HomeHeader(),
              SizedBox(height: 32.h),
              // هنا نضع إحصائيات المستشفى أو زرار "Add Clinic" اللي عملناه
              Text(
                "Hospital Management Dashboard",
                style: TextStyle(fontSize: 20.sp, color: AppColors.deepNavy),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
