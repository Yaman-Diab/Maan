import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_semantic_colors.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

/// حارس ضد الارتداد البصري.
///
/// نقل الألوان من ثوابت `AppColors` لتوكنات دلالية لازم ما يغيّر ولا
/// بكسل. الاختبارات هون بتثبّت القيم الأصلية بالضبط، فأي تغيير غير
/// مقصود بيوقع الاختبار بدل ما ينكشف بالعين بعد أسابيع.
///
/// ملاحظة: `AppTheme.light()` بتستخدم `.sp`، فلازم تنبنى جوّا
/// `ScreenUtilInit` — نفس القيد الموجود بـ`main.dart`.
const _designSize = Size(375, 812);

Future<ThemeData> _pumpAndReadTheme(WidgetTester tester) async {
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
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light(),
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
  group('ColorScheme الفاتحة بتطابق الألوان الأصلية', () {
    testWidgets('ألوان الهوية', (tester) async {
      final theme = await _pumpAndReadTheme(tester);

      expect(theme.colorScheme.primary, const Color(0xFF237366));
      expect(theme.colorScheme.secondary, const Color(0xFFC47E09));
      expect(theme.colorScheme.tertiary, const Color(0xFFF2994A));
    });

    testWidgets('ألوان الحالة والأسطح', (tester) async {
      final theme = await _pumpAndReadTheme(tester);

      expect(theme.colorScheme.error, const Color(0xFFCC0000));
      expect(theme.colorScheme.surface, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.onSurface, const Color(0xFF1E1E1E));
      expect(theme.colorScheme.onPrimary, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.outline, const Color(0xFFD6D6D6));
      expect(theme.colorScheme.outlineVariant, const Color(0xFFDADCE1));
    });

    testWidgets('الثيم فاتح وMaterial 3 مفعّل', (tester) async {
      final theme = await _pumpAndReadTheme(tester);

      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
    });

    testWidgets('الامتداد اللوني مسجّل بالثيم', (tester) async {
      final theme = await _pumpAndReadTheme(tester);

      expect(theme.extension<AppSemanticColors>(), isNotNull);
    });
  });

  group('التوكنات الدلالية بتطابق القيم الأصلية', () {
    // ثوابت نقية — ما بتحتاج ScreenUtil.
    const colors = AppSemanticColors.light;

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

    test('توكنات الملف الشخصي', () {
      // شفافة عن قصد: نفس التوكن بينستخدم فوق البطاقة البيضا وفوق
      // خلفية الصفحة، ولون مدموج مسبقاً بيبيّن غلط فوق وحدة منهم.
      expect(colors.brandSurface, const Color(0x1A237366));
      expect(colors.successSurface, const Color(0x1A1B9E4B));
      expect(colors.trackBackground, const Color(0xFFEFEFEF));

      expect(colors.brandSurface.a, lessThan(1));
      expect(colors.successSurface.a, lessThan(1));
    });

    test('التوكنات الجديدة إلها نسخة داكنة مختلفة', () {
      const dark = AppSemanticColors.dark;

      // مسار شريط التقدّم لازم يفتّح/يغمق مع الثيم، وإلا بيختفي.
      expect(dark.trackBackground, isNot(colors.trackBackground));
      // لون الهوية بينفتح بالداكن، فتلوينه لازم يتبعه.
      expect(dark.brandSurface, isNot(colors.brandSurface));
    });
  });

  group('AppThemeContext', () {
    testWidgets('context.colors و context.scheme بيقرأوا من الثيم', (
      tester,
    ) async {
      late AppSemanticColors readColors;
      late ColorScheme readScheme;

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _designSize;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: _designSize,
          builder: (context, child) => MaterialApp(
            theme: AppTheme.light(),
            home: Builder(
              builder: (context) {
                readColors = context.colors;
                readScheme = context.scheme;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

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
