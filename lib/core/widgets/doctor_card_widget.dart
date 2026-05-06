import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';

class DoctorCardWidget extends StatefulWidget {
  final String doctorName;
  final String specialization;
  final double rating;
  final String imagePath;
  final VoidCallback onTap;
  final Function(bool) onFavoriteChanged;
  final bool isInitialFavorite;

  const DoctorCardWidget({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.rating,
    required this.imagePath,
    required this.onTap,
    required this.onFavoriteChanged,
    this.isInitialFavorite = false, // افتراضياً غير مفضلة
  });

  @override
  State<DoctorCardWidget> createState() => _DoctorCardWidgetState();
}

class _DoctorCardWidgetState extends State<DoctorCardWidget> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isInitialFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170, // عرض ثابت للكارت زي الصورة تقريباً
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: widget.onTap, // تنفيذ ميثود التنقل عند الضغط
        borderRadius: BorderRadius.circular(16), // مهم عشان الـ Splash effect
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // صورة الدكتور المقصوصة بشكل مخصص
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
                border: Border.all(
                  color: AppColors.deepNavy.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
                child: Image.asset(
                  widget.imagePath,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),

            // بيانات الدكتور (التقييم والاسم في Row)
            Row(
              children: [
                // أيقونة النجمة والتقييم
                Icon(
                  Icons.star_rounded,
                  color: AppColors.yellowRating, // لون التقييم
                  size: 20,
                ),
                SizedBox(width: 6),
                Text(
                  widget.rating.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.darkSlate,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                // اسم الدكتور (مقسم عشان يأخذ باقي المساحة)
                Expanded(
                  child: Text(
                    widget.doctorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // بيانات التخصص وزرار المفضلة في Row
            Row(
              children: [
                // أيقونة القلب التفاعلية
                InkWell(
                  onTap: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                    widget.onFavoriteChanged(isFavorite);
                  },
                  child: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite
                        ? AppColors.error
                        : AppColors.darkSlate, // استخدمت Error للقلب الأحمر
                  ),
                ),
                SizedBox(width: 8),
                // التخصص
                Expanded(
                  child: Text(
                    widget.specialization,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
