import 'package:flutter_bloc/flutter_bloc.dart';
import 'privacy_checkbox_state.dart';

class PrivacyCheckboxCubit extends Cubit<PrivacyCheckboxState> {
  PrivacyCheckboxCubit() : super(PrivacyCheckboxState.initial());

  void toggleCheckbox(bool? value) {
    emit(state.copyWith(isChecked: value ?? false));
  }
}
