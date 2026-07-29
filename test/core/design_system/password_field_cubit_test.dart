import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/widgets/password_text_form_field/bloc/password_field_cubit.dart';
import 'package:maan/core/design_system/widgets/password_text_form_field/bloc/password_field_state.dart';

void main() {
  test('كلمة المرور مخفية بالبداية', () {
    expect(PasswordFieldCubit().state.isHidden, isTrue);
  });

  blocTest<PasswordFieldCubit, PasswordFieldState>(
    'كل نقرة بتقلب الحالة، والقيمة محمولة بالحالة نفسها',
    build: PasswordFieldCubit.new,
    act: (cubit) => cubit
      ..toggleVisibility()
      ..toggleVisibility(),
    expect: () => const [
      PasswordFieldState(isHidden: false),
      PasswordFieldState(isHidden: true),
    ],
  );
}
