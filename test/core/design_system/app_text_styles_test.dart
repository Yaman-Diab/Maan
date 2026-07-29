import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_semantic_colors.dart';
import 'package:maan/core/design_system/app_text_styles.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

/// حارس ضد انضراب القياسات.
///
/// نقل الأنماط من ثوابت `static final` لامتداد ثيم لازم يحافظ على
/// **نفس أرقام `.sp` حرفياً**، وكمان يخلّيها تُعاد الحساب مع تغيير
/// مقاس الشاشة بدل ما تتجمّد على أول جهاز.
///
/// كل الاختبارات بتلفّ الشجرة بـ`ScreenUtilInit` بنفس `designSize`
/// تبع `main.dart` (375×812) حتى تكون `.sp` محسوبة بنفس المرجع.
const _designSize = Size(375, 812);

/// بيضبط مقاس الشاشة المنطقي قبل ما تنبنى الشجرة.
///
/// `tester.view` أوثق من `setSurfaceSize` هون لأن ScreenUtil بيقرأ من
/// `MediaQuery` اللي مصدره الـ view مباشرةً.
void _setLogicalSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Widget _app(void Function(BuildContext) capture) {
  return ScreenUtilInit(
    designSize: _designSize,
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, child) => MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) {
          capture(context);
          return const SizedBox();
        },
      ),
    ),
  );
}

Future<AppTextStyles> _pumpAndReadStyles(
  WidgetTester tester, {
  Size surfaceSize = _designSize,
}) async {
  _setLogicalSize(tester, surfaceSize);

  late AppTextStyles styles;
  await tester.pumpWidget(_app((context) => styles = context.texts));
  await tester.pumpAndSettle();

  return styles;
}

void main() {
  group('الأحجام مطابقة للنسخة السابقة عند مقاس التصميم', () {
    testWidgets('عند 375×812 بتساوي القيم الاسمية بالضبط', (tester) async {
      final styles = await _pumpAndReadStyles(tester);

      expect(styles.f32W600Black.fontSize, 32);
      expect(styles.f32W400Black.fontSize, 32);
      expect(styles.f16W400Black.fontSize, 16);
      expect(styles.f16W500Black.fontSize, 16);
      expect(styles.f16W600White.fontSize, 16);
      expect(styles.f15W600Primary.fontSize, 15);
      expect(styles.f14W600Black.fontSize, 14);
      expect(styles.f14W400HintColor.fontSize, 14);
      expect(styles.f12W400SecColor.fontSize, 12);
    });

    testWidgets('الأوزان والزخارف محفوظة', (tester) async {
      final styles = await _pumpAndReadStyles(tester);

      expect(styles.f32W600Black.fontWeight, FontWeight.w600);
      expect(styles.f16W400Black.fontWeight, FontWeight.w400);
      expect(styles.f14W600Black.fontWeight, FontWeight.w600);
      expect(
        styles.f16W500PrimaryUnderline.decoration,
        TextDecoration.underline,
      );
      expect(
        styles.f16W400SuccessColorLineThrough.decoration,
        TextDecoration.lineThrough,
      );
    });

    testWidgets('الألوان مطابقة للقيم الأصلية', (tester) async {
      final styles = await _pumpAndReadStyles(tester);

      expect(styles.f16W400Black.color, const Color(0xFF1E1E1E));
      expect(styles.f16W600White.color, const Color(0xFFFFFFFF));
      expect(styles.f16W400HintColor.color, const Color(0xFF9E9E9E));
      expect(styles.f15W600Primary.color, const Color(0xFF237366));
      expect(styles.f12W400SecColor.color, const Color(0xFFC47E09));
      expect(styles.f14W400GreyColor.color, const Color(0xFF8B91A0));
    });
  });

  group('ScreenUtil — القياسات بتستجيب للمقاس بدل ما تتجمّد', () {
    testWidgets('شاشة أعرض بتعطي أحجام أكبر', (tester) async {
      final atDesign = await _pumpAndReadStyles(tester);
      final designSize16 = atDesign.f16W400Black.fontSize!;

      // تابلت: ضِعف عرض التصميم تقريباً.
      final atTablet = await _pumpAndReadStyles(
        tester,
        surfaceSize: const Size(750, 1024),
      );

      expect(
        atTablet.f16W400Black.fontSize!,
        greaterThan(designSize16),
        reason:
            'لو تجمّدت الأنماط كما كانت بـ static final، الرقمان بيتساووا '
            'وهاد بالضبط البَغ اللي عم نصلحه',
      );
    });

    testWidgets('نسب الأحجام محفوظة عبر المقاسات', (tester) async {
      final styles = await _pumpAndReadStyles(
        tester,
        surfaceSize: const Size(750, 1024),
      );

      // 32 : 16 : 12 لازم تضل 8 : 4 : 3 مهما كان المقاس.
      final ratio = styles.f32W600Black.fontSize! / styles.f16W400Black.fontSize!;
      expect(ratio, closeTo(2, 0.01));
    });
  });

  group('التكامل مع الثيم', () {
    testWidgets('الامتداد مسجّل وTextTheme معبّأة', (tester) async {
      _setLogicalSize(tester, _designSize);

      late ThemeData theme;
      await tester.pumpWidget(_app((context) => theme = Theme.of(context)));
      await tester.pumpAndSettle();

      expect(theme.extension<AppTextStyles>(), isNotNull);
      // widgets Material الجاهزة بتاخد أحجام التطبيق مش الافتراضية.
      expect(theme.textTheme.bodyLarge?.fontSize, 16);
      expect(theme.textTheme.displaySmall?.fontSize, 32);
    });

    test('الألوان بتتبع التوكنات الدلالية لا قيم ثابتة', () {
      final dark = AppTextStyles.from(
        colors: AppSemanticColors.dark,
        scheme: const ColorScheme.dark(),
      );

      expect(dark.f16W400Black.color, AppSemanticColors.dark.textPrimary);
      expect(dark.f16W400HintColor.color, AppSemanticColors.dark.textHint);
    });
  });
}
