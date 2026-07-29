// -------------------------
// Result
// -------------------------

import '../error/failure.dart';

/// النتيجة اللي بترجّعها الـ repositories والـ use cases.
///
/// بديل عن رمي الاستثناءات عبر الطبقات: الـ data layer بتمسك الاستثناء
/// وبتحوّله لـ [Failure]، والـ presentation بتتعامل مع الحالتين صراحةً.
///
/// لأنها `sealed` بيقدر الـ switch يغطي كل الحالات بدون `default`:
///
/// ```dart
/// switch (result) {
///   case Ok(:final value): ...
///   case Err(:final failure): ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;

  bool get isErr => this is Err<T>;

  /// القيمة عند النجاح، و`null` عند الفشل.
  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  /// سبب الفشل، و`null` عند النجاح.
  Failure? get failureOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final failure) => failure,
  };
}

final class Ok<T> extends Result<T> {
  final T value;

  const Ok(this.value);
}

final class Err<T> extends Result<T> {
  final Failure failure;

  const Err(this.failure);
}
