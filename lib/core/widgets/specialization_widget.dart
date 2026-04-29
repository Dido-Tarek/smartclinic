import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpecializationWidget extends StatelessWidget {
  final String specializationName;
  final String? iconPath;
  final IconData? iconData;

  const SpecializationWidget({
    super.key,
    required this.specializationName,
    this.iconPath,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF8EBAE3), // اللون الأزرق الفاتح من الصورة
        borderRadius: BorderRadius.circular(50.r), // حواف دائرية بالكامل
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // الدائرة البيضاء التي تحتوي على الأيقونة
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: iconPath != null
                ? Image.asset(iconPath!, width: 24.w, height: 24.h)
                : Icon(
                    iconData ?? Icons.psychology_outlined,
                    color: const Color(0xFF247CFF),
                    size: 24.sp,
                  ),
          ),
          SizedBox(width: 12.w),
          // اسم التخصص
          Text(
            specializationName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.w), // مساحة بسيطة في النهاية
        ],
      ),
    );
  }
}
