// -------------------------
// Settings State
// -------------------------

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// خيارات حجم الخط المعروضة للمستخدم.
///
/// enum بدل `double` حرّ: القيم محدودة ومختبَرة، وشاشة الإعدادات بتعرضها
/// كخيارات جاهزة بلا شريط تمرير بيسمح بقيم بتكسر التخطيط.
enum AppTextScale {
  small(0.9),
  normal(1),
  large(1.15),
  extraLarge(1.3);

  const AppTextScale(this.factor);

  final double factor;

  static AppTextScale fromName(String? name) {
    return AppTextScale.values.firstWhere(
      (scale) => scale.name == name,
      orElse: () => AppTextScale.normal,
    );
  }
}

extension AppThemeModeName on ThemeMode {
  static ThemeMode fromName(String? name) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }
}

final class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final AppTextScale textScale;

  /// `false` لحد ما تُقرأ التفضيلات المحفوظة — الواجهة بتقدر تأجّل
  /// الرسم لتفادي ومضة الثيم الفاتح قبل تطبيق الداكن.
  final bool isLoaded;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.textScale = AppTextScale.normal,
    this.isLoaded = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    AppTextScale? textScale,
    bool? isLoaded,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      textScale: textScale ?? this.textScale,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [themeMode, textScale, isLoaded];
}
