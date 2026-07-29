// -------------------------
// App Spacing, Radius, and Shadows
// -------------------------

import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 24;
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 3),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 8),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x24000000), offset: Offset(0, 4), blurRadius: 16),
  ];
}
