import 'package:flutter_bloc/flutter_bloc.dart';

import 'password_field_state.dart';

class PasswordFieldCubit extends Cubit<PasswordFieldState> {
  PasswordFieldCubit() : super(const PasswordFieldState());

  void toggleVisibility() {
    emit(state.copyWith(isHidden: !state.isHidden));
  }
}
