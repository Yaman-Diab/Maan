import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/features/auth/domain/entities/auth_user.dart';
import 'package:maan/features/profile/domain/usecases/update_identity_usecase.dart';
import 'package:maan/features/profile/presentation/edit_identity/cubit/edit_identity_cubit.dart';
import 'package:maan/features/profile/presentation/edit_identity/cubit/edit_identity_state.dart';
import 'package:maan/features/profile/presentation/edit_identity/widgets/edit_identity_form.dart';
import 'package:mocktail/mocktail.dart';

class _MockUpdateIdentityUseCase extends Mock
    implements UpdateIdentityUseCase {}

const _designSize = Size(375, 812);

AuthUser _user({AccountStatus status = AccountStatus.visitor}) {
  return AuthUser(
    id: 1,
    firstName: 'Yaman',
    lastName: 'Diab',
    email: 'a@b.com',
    accountStatus: status,
    nationalId: '123456789012',
    birthDate: DateTime(2003, 2, 1),
  );
}

Future<void> _pump(WidgetTester tester, EditIdentityCubit cubit) async {
  final controllers = EditIdentityFieldControllers(
    firstName: cubit.state.firstName,
    lastName: cubit.state.lastName,
    day: cubit.state.day,
    month: cubit.state.month,
    year: cubit.state.year,
  );

  addTearDown(controllers.dispose);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<EditIdentityCubit>.value(
          value: cubit,
          child: BlocBuilder<EditIdentityCubit, EditIdentityState>(
            builder: (context, state) => EditIdentityForm(
              formKey: GlobalKey<FormState>(),
              state: state,
              controllers: controllers,
              onSave: () {},
              onCancel: () {},
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  late _MockUpdateIdentityUseCase useCase;

  setUp(() {
    useCase = _MockUpdateIdentityUseCase();
  });

  group('حالة قابلة للتعديل', () {
    testWidgets('الحقول مفعّلة وزر الحفظ ظاهر', (tester) async {
      final cubit = EditIdentityCubit(useCase, user: _user());
      addTearDown(cubit.close);

      await _pump(tester, cubit);

      final firstNameField = tester.widget<CustomTextFormField>(
        find.byType(CustomTextFormField).first,
      );
      expect(firstNameField.enabled, isTrue);

      expect(find.text('save_changes'), findsOneWidget);
      expect(find.text('edit_identity_editable_notice'), findsOneWidget);
      expect(find.text('edit_identity_locked_notice'), findsNothing);
    });

    testWidgets('كتابة بالحقل بتحدّث حالة الـ Cubit', (tester) async {
      final cubit = EditIdentityCubit(useCase, user: _user());
      addTearDown(cubit.close);

      await _pump(tester, cubit);

      await tester.enterText(find.byType(TextFormField).first, 'Ahmad');

      expect(cubit.state.firstName, 'Ahmad');
    });
  });

  group('حالة مقفولة (حساب موثّق)', () {
    testWidgets('الحقول معطّلة وزر الحفظ مخفي، وبيّن تحذير بدل الملاحظة', (
      tester,
    ) async {
      final cubit = EditIdentityCubit(
        useCase,
        user: _user(status: AccountStatus.verified),
      );
      addTearDown(cubit.close);

      await _pump(tester, cubit);

      final firstNameField = tester.widget<CustomTextFormField>(
        find.byType(CustomTextFormField).first,
      );
      expect(firstNameField.enabled, isFalse);

      expect(find.text('save_changes'), findsNothing);
      expect(find.text('edit_identity_locked_notice'), findsOneWidget);
      expect(find.text('edit_identity_editable_notice'), findsNothing);
    });

    testWidgets('الإلغاء بيضل ظاهراً حتى بالحالة المقفولة', (tester) async {
      final cubit = EditIdentityCubit(
        useCase,
        user: _user(status: AccountStatus.verified),
      );
      addTearDown(cubit.close);

      await _pump(tester, cubit);

      expect(find.text('cancel'), findsOneWidget);
    });
  });

  testWidgets('ما في حقل رقم وطني بهالشاشة — شاشة التوثيق مالكته', (
    tester,
  ) async {
    final cubit = EditIdentityCubit(useCase, user: _user());
    addTearDown(cubit.close);

    await _pump(tester, cubit);

    // فحص الترجمة بيقارن المفتاح لا النص — راجع `CLAUDE.md`.
    expect(find.text('national_id'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomTextFormField &&
            widget.keyBoardType == TextInputType.number,
      ),
      findsNothing,
      reason: 'انتقل لـ VerificationFormView',
    );
  });
}
