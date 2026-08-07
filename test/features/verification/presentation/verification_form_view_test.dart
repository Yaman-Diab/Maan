import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/features/auth/domain/entities/auth_user.dart';
import 'package:maan/features/verification/domain/entities/verification_request.dart';
import 'package:maan/features/verification/domain/entities/verification_request_status.dart';
import 'package:maan/features/verification/presentation/verification/cubit/verification_state.dart';
import 'package:maan/features/verification/presentation/verification/widgets/verification_form_view.dart';

const _designSize = Size(375, 812);

const _user = AuthUser(
  id: 1,
  firstName: 'Omar',
  lastName: 'Abo Hawa',
  email: 'omar@example.com',
  accountStatus: AccountStatus.visitor,
);

VerificationRequest _pendingRequest() => VerificationRequest(
  id: 7,
  userId: 1,
  nationalId: '12345678901',
  status: VerificationRequestStatus.pending,
  images: const [],
  createdAt: DateTime(2026, 8, 2),
  updatedAt: DateTime(2026, 8, 2),
);

Future<void> _pump(WidgetTester tester, VerificationState state) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _designSize;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final controller = TextEditingController(text: state.nationalId);
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: VerificationFormView(
            state: state,
            nationalIdController: controller,
            onNationalIdChanged: (_) {},
            onPickImage: (_) {},
            onRemoveImage: (_) {},
            onSubmit: () {},
            onEditProfile: () {},
          ),
        ),
      ),
    ),
  );

  await tester.pump();
}

void main() {
  testWidgets('الرقم الوطني — رقمي بس ومحدود بالطول', (tester) async {
    // انتقل من `edit_identity_form_test` لما صارت شاشة التوثيق مالكة
    // الحقل الوحيدة.
    await _pump(tester, const VerificationState(view: VerificationView.form));

    final field = tester.widget<CustomTextFormField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomTextFormField &&
            widget.keyBoardType == TextInputType.number,
      ),
    );

    expect(field.digitsOnly, isTrue);
    expect(field.maxLength, 12);
  });

  testWidgets('بطاقة البيانات الشخصية بتظهر لما يوصل المستخدم', (
    tester,
  ) async {
    await _pump(
      tester,
      const VerificationState(view: VerificationView.form, user: _user),
    );

    expect(find.text('verification_profile_section'), findsOneWidget);
    expect(find.text('Omar'), findsOneWidget);
    expect(find.text('Abo Hawa'), findsOneWidget);
  });

  testWidgets('بتختفي كلياً لو ما وصل المستخدم بدل حقول فاضية', (
    tester,
  ) async {
    await _pump(tester, const VerificationState(view: VerificationView.form));

    expect(find.text('verification_profile_section'), findsNothing);
  });

  testWidgets('«تعديل» بينادي onEditProfile', (tester) async {
    var tapped = false;

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _designSize;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _designSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: VerificationFormView(
              state: const VerificationState(
                view: VerificationView.form,
                user: _user,
              ),
              nationalIdController: controller,
              onNationalIdChanged: (_) {},
              onPickImage: (_) {},
              onRemoveImage: (_) {},
              onSubmit: () {},
              onEditProfile: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('edit'));

    expect(tapped, isTrue);
  });

  testWidgets('بوضع تصحيح طلب قائم الصور بتنقفل', (tester) async {
    await _pump(
      tester,
      VerificationState(
        view: VerificationView.form,
        request: _pendingRequest(),
        nationalId: '12345678901',
      ),
    );

    // الملاحظة بتشرح إنه الصور ما بتتغيّر بعد الإرسال.
    expect(find.text('verification_photos_locked_note'), findsOneWidget);
  });
}
