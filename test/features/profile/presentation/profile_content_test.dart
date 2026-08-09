import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/features/auth/domain/entities/auth_user.dart';
import 'package:maan/features/profile/domain/entities/citizen_profile.dart';
import 'package:maan/features/profile/domain/entities/profile_stats.dart';
import 'package:maan/features/profile/presentation/profile/widgets/account_status_chip.dart';
import 'package:maan/features/profile/presentation/profile/widgets/profile_avatar.dart';
import 'package:maan/features/profile/presentation/profile/widgets/profile_content.dart';

const _designSize = Size(375, 812);

AuthUser _user({
  AccountStatus status = AccountStatus.verified,
  String? nationalId = '123456789012',
  DateTime? birthDate,
  String? avatarUrl,
}) {
  return AuthUser(
    id: 7,
    firstName: 'Mohamed',
    lastName: 'Ahmed',
    email: 'mohamed.ahmed@gmail.com',
    accountStatus: status,
    nationalId: nationalId,
    avatarUrl: avatarUrl,
    birthDate: birthDate ?? DateTime(1998, 10, 12),
  );
}

Future<void> _pump(
  WidgetTester tester,
  CitizenProfile profile, {
  TextDirection direction = TextDirection.ltr,
  ThemeData? theme,
  String? localAvatarPath,
  bool avatarRemoved = false,
  bool isUploadingAvatar = false,
  VoidCallback? onAddPhotoTap,
  // `pumpAndSettle` بتعلّق مع الحركات اللانهائية (مؤشّر التقدّم)، فبنقدّم
  // الوقت يدوياً بهالحالات.
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _designSize;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        theme: theme ?? AppTheme.light(),
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: SingleChildScrollView(
              child: ProfileContent(
                profile: profile,
                localAvatarPath: localAvatarPath,
                avatarRemoved: avatarRemoved,
                isUploadingAvatar: isUploadingAvatar,
                onAddPhotoTap: onAddPhotoTap,
                onCertificatesTap: () {},
              ),
            ),
          ),
        ),
      ),
    ),
  );

  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  testWidgets('بترسم كل أقسام التصميم بلا استثناء', (tester) async {
    await _pump(tester, CitizenProfile(user: _user()));

    // بلا تهيئة easy_localization بترجّع `.tr()` المفتاح نفسه، فوجوده
    // بيثبت إن النص مربوط بالترجمة لا مكتوب يدوياً.
    expect(find.text('profile_identity_section'), findsOneWidget);
    expect(find.text('profile_statistics_section'), findsOneWidget);
    expect(find.text('profile_activity_section'), findsOneWidget);
    expect(find.text('citizenship_index'), findsOneWidget);
    expect(find.text('authentication_index'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('بيانات الهوية بتنعرض من الكيان', (tester) async {
    await _pump(tester, CitizenProfile(user: _user()));

    expect(find.text('Mohamed Ahmed'), findsOneWidget);
    expect(find.text('mohamed.ahmed@gmail.com'), findsOneWidget);
    expect(find.text('123456789012'), findsOneWidget);
    expect(find.text('12 / 10 / 1998'), findsOneWidget);
  });

  testWidgets('الرقم الوطني الناقص بيصير «—» لا فراغ', (tester) async {
    await _pump(tester, CitizenProfile(user: _user(nationalId: null)));

    expect(find.text('—'), findsWidgets);
  });

  group('المؤشرات', () {
    testWidgets('بلا بيانات: «—» بلا مستوى ولا رقم مخترع', (tester) async {
      await _pump(tester, CitizenProfile(user: _user()));

      // ولا واحد من مفاتيح المستويات الثلاثة لازم يظهر.
      expect(find.text('level_beginner'), findsNothing);
      expect(find.text('level_intermediate'), findsNothing);
      expect(find.text('level_advanced'), findsNothing);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('مع بيانات: النسبة والمستوى بيظهروا', (tester) async {
      await _pump(
        tester,
        CitizenProfile(
          user: _user(),
          stats: const ProfileStats(
            citizenshipIndex: 75,
            authenticationIndex: 45,
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);
      expect(find.text('level_advanced'), findsOneWidget);
      expect(find.text('level_intermediate'), findsOneWidget);
    });
  });

  group('شارة الحالة والتعديل', () {
    testWidgets('الموثّق: شارة موثّق و«غير قابل للتعديل»', (tester) async {
      await _pump(tester, CitizenProfile(user: _user()));

      expect(find.text('account_status_verified'), findsOneWidget);
      expect(find.text('profile_cannot_edit'), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    });

    testWidgets('الزائر: شارة غير موثّق وبلا علامة توثيق', (tester) async {
      await _pump(
        tester,
        CitizenProfile(user: _user(status: AccountStatus.visitor)),
      );

      expect(find.text('account_status_not_verified'), findsOneWidget);
      expect(find.text('profile_cannot_edit'), findsNothing);
      expect(find.byIcon(Icons.verified_rounded), findsNothing);
    });

    testWidgets('المحظور بيلاقي شارته الخاصة لا «غير موثّق»', (tester) async {
      await _pump(
        tester,
        CitizenProfile(user: _user(status: AccountStatus.blocked)),
      );

      expect(find.text('account_status_blocked'), findsOneWidget);
      expect(find.text('account_status_not_verified'), findsNothing);
    });

    testWidgets('الحالة المجهولة ما بتتأكّد بشارة', (tester) async {
      await _pump(
        tester,
        CitizenProfile(user: _user(status: AccountStatus.unknown)),
      );

      final chip = tester.widget<AccountStatusChip>(
        find.byType(AccountStatusChip),
      );

      expect(chip.status, AccountStatus.unknown);
      expect(find.text('account_status_verified'), findsNothing);
      expect(find.text('account_status_not_verified'), findsNothing);
    });
  });

  group('الصورة', () {
    testWidgets('بلا صورة بتنعرض أحرف الاسم', (tester) async {
      await _pump(tester, CitizenProfile(user: _user()));

      expect(find.byType(ProfileAvatar), findsOneWidget);
      expect(find.text('MA'), findsOneWidget);
      // ولا شي بيحمّل صورة: لا شبكة ولا ملف.
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('زر «+» ما بينعرض بلا معالج — ما منعرض زر بلا وظيفة', (
      tester,
    ) async {
      await _pump(tester, CitizenProfile(user: _user()));

      expect(find.byIcon(Icons.add_rounded), findsNothing);
    });

    testWidgets('زر «+» بينعرض وبيستجيب للضغط', (tester) async {
      var taps = 0;

      await _pump(
        tester,
        CitizenProfile(user: _user()),
        onAddPhotoTap: () => taps++,
      );

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('وقت الرفع بيختفي «+» وبيبيّن مؤشّر تقدّم', (tester) async {
      await _pump(
        tester,
        CitizenProfile(user: _user()),
        isUploadingAvatar: true,
        onAddPhotoTap: () {},
        settle: false,
      );

      // ضغطة ثانية والرفع شغّال بتبلبل الحالة، فالزر بينشال.
      expect(find.byIcon(Icons.add_rounded), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('الملف المحلي بيسبق أحرف الاسم', (tester) async {
      await _pump(
        tester,
        CitizenProfile(user: _user()),
        localAvatarPath: '/does/not/exist.jpg',
      );

      // المسار المحلي أحدث من رابط السيرفر ومن الأحرف، فبينعرض هو.
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<FileImage>());

      // مسار غلط ما بيرمي: `errorBuilder` بيرجّع الأحرف بدل أيقونة
      // صورة مكسورة. (فشل القراءة نفسه IO حقيقي وما بيكتمل بزمن
      // الاختبار المزيّف، فمنكتفي بإثبات إنه ما في انهيار.)
      expect(tester.takeException(), isNull);
    });

    testWidgets('رابط السيرفر بينعرض لما ما يكون في ملف محلي', (tester) async {
      await _pump(
        tester,
        CitizenProfile(
          user: _user(avatarUrl: 'https://cdn.test/photo.jpg'),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<NetworkImage>());
    });

    testWidgets('avatarRemoved بتلغي رابط السيرفر — الأحرف بتنعرض بدله', (
      tester,
    ) async {
      await _pump(
        tester,
        CitizenProfile(
          user: _user(avatarUrl: 'https://cdn.test/photo.jpg'),
        ),
        avatarRemoved: true,
      );

      expect(find.byType(Image), findsNothing);
      expect(find.text('MA'), findsOneWidget);
    });
  });

  testWidgets('بتشتغل بالعربي (RTL) بلا تجاوز تخطيط', (tester) async {
    await _pump(
      tester,
      CitizenProfile(
        user: _user(),
        stats: const ProfileStats(citizenshipIndex: 75),
      ),
      direction: TextDirection.rtl,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('بتشتغل بالوضع الداكن', (tester) async {
    await _pump(
      tester,
      CitizenProfile(user: _user()),
      theme: AppTheme.dark(),
    );

    expect(tester.takeException(), isNull);
  });
}
