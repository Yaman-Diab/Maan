// -------------------------
// Citizen Profile
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/auth_user.dart';
import 'profile_stats.dart';

/// ما بتعرضه شاشة الملف الشخصي: هوية المواطن + مؤشراته.
///
/// **ليش [AuthUser] من ميزة `auth` بدل كيان جديد؟** لأنه نفس الكائن
/// حرفياً — `POST /api/auth/login` و`GET /api/profile` بيرجّعوا نفس
/// مجموعة الحقول، وهاد موثّق بتعليق `AuthUserModel` من يوم ما انبنى.
/// كيان ثاني بنفس الحقول معناه نسختين لازم يضلوا متطابقتين يدوياً.
///
/// الاستيراد بين ميزتين مقبول هون لأنه **كيان domain** لا شي من الشبكة
/// ولا من الواجهة. لو ظهر مستهلك ثالث (شكاوى، تطوع)، وقتها بينتقل
/// لـ`core/session/` تماماً متل ما انتقلت `AccountStatus` وللسبب نفسه.
final class CitizenProfile extends Equatable {
  final AuthUser user;
  final ProfileStats stats;

  const CitizenProfile({required this.user, this.stats = ProfileStats.empty});

  @override
  List<Object?> get props => [user, stats];
}
