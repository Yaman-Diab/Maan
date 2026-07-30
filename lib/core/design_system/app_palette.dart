// -------------------------
// App Palette
// -------------------------

import 'package:flutter/material.dart';

/// القيم الخام للألوان — الطبقة الوحيدة اللي فيها أرقام hex.
///
/// **ما تستخدمها بالـ widgets مباشرة.** استخدم `context.colors` بدلها،
/// لأن القيمة الخام ثابتة بينما التوكن الدلالي بيتبدّل مع الثيم.
///
/// هون بنسمّي الألوان بشكلها (`teal600`, `white`) لأنها فعلاً ألوان؛
/// التسمية حسب المعنى (`textPrimary`, `border`) بتصير بـ`AppSemanticColors`.
abstract final class AppPalette {
  // -------------------------
  // Brand
  // -------------------------

  static const Color teal600 = Color(0xFF237366);
  static const Color amber700 = Color(0xFFC47E09);
  static const Color orange500 = Color(0xFFF2994A);

  // -------------------------
  // Status
  // -------------------------

  static const Color green600 = Color(0xFF1B9E4B);
  static const Color red600 = Color(0xFFCC0000);

  // -------------------------
  // Neutrals
  // -------------------------

  static const Color white = Color(0xFFFFFFFF);
  static const Color ink900 = Color(0xFF1E1E1E);
  static const Color slate500 = Color(0xFF8B91A0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey300 = Color(0xFFDADCE1);
  static const Color grey200 = Color(0xFFD6D6D6);
  static const Color grey100 = Color(0xFFEFEFEF);
  static const Color canvas = Color(0xFFF5F6FA);

  // -------------------------
  // Splash Gradient
  // -------------------------

  static const Color mist100 = Color(0xFFE9F1EF);
  static const Color mist50 = Color(0xFFF1F4F3);

  // -------------------------
  // Tinted Surfaces
  // -------------------------

  static const Color amber50 = Color(0xFFFEF5E7);
  static const Color blue50 = Color(0xFFE7F0FF);
  static const Color navy800 = Color(0xFF173763);

  // -------------------------
  // Dark Neutrals
  // -------------------------
  //
  // موجودة من الآن ليكون بناء الثيم الداكن بالمرحلة 3 مجرّد تعبئة قيم.

  /// نسخ مفتوحة من ألوان الهوية — الغامقة تباينها ضعيف فوق خلفية داكنة.
  static const Color teal400 = Color(0xFF4DA396);
  static const Color amber400 = Color(0xFFE0A93B);
  static const Color red400 = Color(0xFFF06A6A);

  static const Color darkSurface = Color(0xFF15171C);
  static const Color darkSurfaceElevated = Color(0xFF1E2128);
  static const Color darkCanvas = Color(0xFF0F1116);
  static const Color darkBorder = Color(0xFF2C313A);
  static const Color darkTextPrimary = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFF9AA0AC);
}
