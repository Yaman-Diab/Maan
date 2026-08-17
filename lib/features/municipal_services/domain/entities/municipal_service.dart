// -------------------------
// Municipal Service
// -------------------------

import 'package:equatable/equatable.dart';

/// خدمة بلدية — للعرض فقط، بلا أي تفاعل مع نظام الطابور الفعلي
/// (`Queue/Citizen` بالكوليكشن خارج نطاق تطبيق المواطن كلياً).
///
/// الوقت المقدّر لدور المواطن **مش حقلاً براجع من الباك اند** — بيتحسب
/// محلياً من [estimatedTimeMinutes] و[peopleWaiting]، راجع
/// [estimatedWaitMinutes].
final class MunicipalService extends Equatable {
  final int id;
  final String name;
  final int estimatedTimeMinutes;
  final int peopleWaiting;
  final bool isActive;

  const MunicipalService({
    required this.id,
    required this.name,
    required this.estimatedTimeMinutes,
    this.peopleWaiting = 0,
    this.isActive = false,
  });

  /// `true` لو ما في أي حد بالانتظار — المواطن يقدر يروح فوراً.
  bool get hasNoWait => peopleWaiting == 0;

  /// الوقت المقدّر بالدقائق قبل ما يوصل دور المواطن.
  int get estimatedWaitMinutes => estimatedTimeMinutes * peopleWaiting;

  @override
  List<Object?> get props => [
    id,
    name,
    estimatedTimeMinutes,
    peopleWaiting,
    isActive,
  ];
}
