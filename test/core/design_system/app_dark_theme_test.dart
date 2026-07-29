import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_semantic_colors.dart';
import 'package:maan/core/design_system/app_text_styles.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

const _designSize = Size(375, 812);

/// نسبة التباين حسب WCAG. المطلوب 4.5:1 للنص العادي و3:1 للعناصر الكبيرة.
double _contrastRatio(Color a, Color b) {
  double luminance(Color c) => c.computeLuminance();

  final l1 = luminance(a);
  final l2 = luminance(b);

  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

Future<ThemeData> _pumpDarkTheme(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _designSize;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  late ThemeData theme;

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: Builder(
          builder: (context) {
            theme = Theme.of(context);
            return const SizedBox();
          },
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
  return theme;
}

void main() {
  group('الثيم الداكن مبني بالكامل', () {
    testWidgets('الامتدادات مسجّلة والسطوع داكن', (tester) async {
      final theme = await _pumpDarkTheme(tester);

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.extension<AppSemanticColors>(), AppSemanticColors.dark);
      expect(theme.extension<AppTextStyles>(), isNotNull);
    });

    testWidgets('الخلفية داكنة والنص فاتح', (tester) async {
      final theme = await _pumpDarkTheme(tester);

      expect(theme.scaffoldBackgroundColor.computeLuminance(), lessThan(0.2));
      expect(theme.colorScheme.onSurface.computeLuminance(), greaterThan(0.5));
    });

    testWidgets('أنماط النصوص أخذت ألوان الوضع الداكن تلقائياً', (
      tester,
    ) async {
      final theme = await _pumpDarkTheme(tester);
      final texts = theme.extension<AppTextStyles>()!;

      // نفس موقع الاستدعاء `f16W400Black` بيعطي لون فاتح بالوضع الداكن —
      // وهاد بالضبط الهدف من التسمية الدلالية.
      expect(texts.f16W400Black.color, AppSemanticColors.dark.textPrimary);
      expect(texts.f16W400Black.color!.computeLuminance(), greaterThan(0.5));
    });

    testWidgets('الأحجام ما تأثرت بتغيير الثيم', (tester) async {
      final theme = await _pumpDarkTheme(tester);
      final texts = theme.extension<AppTextStyles>()!;

      expect(texts.f16W400Black.fontSize, 16);
      expect(texts.f32W600Black.fontSize, 32);
    });
  });

  group('التباين — WCAG', () {
    testWidgets('النص الأساسي على الخلفية يحقق 4.5:1', (tester) async {
      final theme = await _pumpDarkTheme(tester);
      final colors = theme.extension<AppSemanticColors>()!;

      expect(
        _contrastRatio(colors.textPrimary, theme.colorScheme.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('لون الهوية على الخلفية الداكنة يحقق 3:1', (tester) async {
      final theme = await _pumpDarkTheme(tester);

      // teal600 الأصلي بيرسب هون، ولهيك بنستخدم teal400 بالوضع الداكن.
      expect(
        _contrastRatio(theme.colorScheme.primary, theme.colorScheme.surface),
        greaterThanOrEqualTo(3),
      );
    });

    testWidgets('لون الخطأ مقروء على الخلفية الداكنة', (tester) async {
      final theme = await _pumpDarkTheme(tester);

      expect(
        _contrastRatio(theme.colorScheme.error, theme.colorScheme.surface),
        greaterThanOrEqualTo(3),
      );
    });

    testWidgets('صناديق التنبيه والمعلومات مقروءة', (tester) async {
      final theme = await _pumpDarkTheme(tester);
      final colors = theme.extension<AppSemanticColors>()!;

      expect(
        _contrastRatio(colors.noticeForeground, colors.noticeBackground),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(colors.infoForeground, colors.infoBackground),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('الثيم الفاتح لسه محقق التباين', () {
    testWidgets('النص الأساسي على الأبيض', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _designSize;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      late AppSemanticColors colors;
      late ColorScheme scheme;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: _designSize,
          builder: (context, child) => MaterialApp(
            theme: AppTheme.light(),
            home: Builder(
              builder: (context) {
                colors = context.colors;
                scheme = context.scheme;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        _contrastRatio(colors.textPrimary, scheme.surface),
        greaterThanOrEqualTo(4.5),
      );
    });
  });
}
