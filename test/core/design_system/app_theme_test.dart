import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_semantic_colors.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

/// حارس ضد الارتداد البصري.
///
/// نقل الألوان من ثوابت `AppColors` لتوكنات دلالية لازم ما يغيّر ولا
/// بكسل. الاختبارات هون بتثبّت القيم الأصلية بالضبط، فأي تغيير غير
/// مقصود بيوقع الاختبار بدل ما ينكشف بالعين بعد أسابيع.
void main() {
  final light = AppTheme.light();

  group('ColorScheme الفاتحة بتطابق الألوان الأصلية', () {
    test('ألوان الهوية', () {
      expect(light.colorScheme.primary, const Color(0xFF237366));
      expect(light.colorScheme.secondary, const Color(0xFFC47E09));
      expect(light.colorScheme.tertiary, const Color(0xFFF2994A));
    });

    test('ألوان الحالة والأسطح', () {
      expect(light.colorScheme.error, const Color(0xFFCC0000));
      expect(light.colorScheme.surface, const Color(0xFFFFFFFF));
      expect(light.colorScheme.onSurface, const Color(0xFF1E1E1E));
      expect(light.colorScheme.onPrimary, const Color(0xFFFFFFFF));
      expect(light.colorScheme.outline, const Color(0xFFD6D6D6));
      expect(light.colorScheme.outlineVariant, const Color(0xFFDADCE1));
    });

    test('الثيم فاتح وMaterial 3 مفعّل', () {
      expect(light.brightness, Brightness.light);
      expect(light.useMaterial3, isTrue);
      expect(light.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
    });
  });

  group('التوكنات الدلالية بتطابق القيم الأصلية', () {
    final colors = light.extension<AppSemanticColors>()!;

    test('الامتداد مسجّل بالثيم', () {
      expect(colors, isNotNull);
    });

    test('النصوص والحدود', () {
      expect(colors.textPrimary, const Color(0xFF1E1E1E));
      expect(colors.textSecondary, const Color(0xFF8B91A0));
      expect(colors.textHint, const Color(0xFF9E9E9E));
      expect(colors.border, const Color(0xFFD6D6D6));
      expect(colors.divider, const Color(0xFFDADCE1));
    });

    test('الأسطح — القيم اللي كانت مكتوبة يدوياً بالـ widgets', () {
      expect(colors.pageBackground, const Color(0xFFF5F6FA));
      expect(colors.fieldDisabledBackground, const Color(0xFFEFEFEF));
      expect(colors.noticeBackground, const Color(0xFFFEF5E7));
      expect(colors.noticeForeground, const Color(0xFFC47E09));
      expect(colors.infoBackground, const Color(0xFFE7F0FF));
      expect(colors.infoForeground, const Color(0xFF173763));
    });

    test('لون النجاح', () {
      expect(colors.success, const Color(0xFF1B9E4B));
    });
  });

  group('AppThemeContext', () {
    testWidgets('context.colors و context.scheme بيقرأوا من الثيم', (
      tester,
    ) async {
      late AppSemanticColors readColors;
      late ColorScheme readScheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: light,
          home: Builder(
            builder: (context) {
              readColors = context.colors;
              readScheme = context.scheme;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(readColors.noticeBackground, const Color(0xFFFEF5E7));
      expect(readScheme.primary, const Color(0xFF237366));
    });

    testWidgets('بترجّع الفاتح كقيمة احتياطية لو الامتداد غير مسجّل', (
      tester,
    ) async {
      late AppSemanticColors readColors;

      await tester.pumpWidget(
        MaterialApp(
          // ثيم بلا الامتداد — الحالة اللي بتصير بـ widget tests بسيطة.
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              readColors = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(readColors, AppSemanticColors.light);
    });
  });

  group('lerp', () {
    test('بيعطي الطرفين عند 0 و 1', () {
      const a = AppSemanticColors.light;
      const b = AppSemanticColors.dark;

      expect(a.lerp(b, 0).textPrimary, a.textPrimary);
      expect(a.lerp(b, 1).textPrimary, b.textPrimary);
    });

    test('بيرجّع نفسه لو النوع غير متطابق', () {
      const a = AppSemanticColors.light;
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
