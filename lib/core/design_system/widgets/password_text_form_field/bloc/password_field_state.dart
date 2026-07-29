import 'package:equatable/equatable.dart';

/// حالة إظهار/إخفاء كلمة المرور.
///
/// الحالة بتحمل البيانات بنفسها بدل ما تكون مجرد إشارة "صار تغيير"
/// والقيمة الحقيقية بحقل عام على الـ Cubit.
final class PasswordFieldState extends Equatable {
  final bool isHidden;

  const PasswordFieldState({this.isHidden = true});

  PasswordFieldState copyWith({bool? isHidden}) {
    return PasswordFieldState(isHidden: isHidden ?? this.isHidden);
  }

  @override
  List<Object?> get props => [isHidden];
}
