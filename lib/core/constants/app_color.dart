import 'package:flutter/material.dart';

class AppColors {
  // Primary Branding
  static const Color deepNavy = Color(0xFF1A2D42); // Headers, Primary Buttons
  static const Color skyBlue = Color(
    0xFF88B7E4,
  ); // Action items, Selection highlights
  static const Color accentBlue = Color(0xFFD1E3F5); // Soft backgrounds
  static const Color softLavender = Color(0xFFFF6B6B); // Notifications, CTAs

  // Splash
  static const Color splashGradientStart = Color(0xFF233047);
  static const Color splashGradientEnd = Color(0xFF172336);
  static const Color splashCardGradientStart = Color(0xFF6CA8FF);
  static const Color splashCardGradientEnd = Color(0xFF9A85FF);
  static const Color splashTextSubtle = Color(0xFFBAC6E2);
  static const Color splashTrack = Color(0xFF49608F);

  // Backgrounds
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);

  // Glassmorphism (For your Floating Language Card)
  static Color glassBg = Colors.white.withAlpha((0.15 * 255).round());
  static Color glassBorder = const Color(
    0xFF88B7E4,
  ).withAlpha((0.3 * 255).round());
  static Color navyOverlay = const Color(
    0xFF1A2D42,
  ).withAlpha((0.85 * 255).round());

  // Text
  static const Color textPrimary = Color(0xFF1A2D42);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Colors.white70;

  //
  static const Color yellowRating = Color(0xFFFFB300); // للنجوم والتقييم
  static const Color darkSlate = Color(0xFF1E293B); // للنصوص العريضة
  static const Color blueAction = Color(
    0xFF247CFF,
  ); // للأزرار والـ Active States
  static const Color grayText = Color(0xFF64748B); // للنصوص الفرعية
  static const Color lightGrayBg = Color(0xFFF1F5F9); // خلفيات الأيقونات
}
