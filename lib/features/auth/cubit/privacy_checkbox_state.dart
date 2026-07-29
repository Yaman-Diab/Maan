import 'package:equatable/equatable.dart';

class PrivacyCheckboxState extends Equatable {
  final bool isChecked;

  const PrivacyCheckboxState({required this.isChecked});

  factory PrivacyCheckboxState.initial() => const PrivacyCheckboxState(isChecked: false);

  PrivacyCheckboxState copyWith({bool? isChecked}) {
    return PrivacyCheckboxState(
      isChecked: isChecked ?? this.isChecked,
    );
  }

  @override
  List<Object?> get props => [isChecked];
}
