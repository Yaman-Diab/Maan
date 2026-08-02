// -------------------------
// Profile Repository
// -------------------------

import 'dart:typed_data';

import '../../../../core/result/result.dart';
import 'package:maan/core/domain/birth_date.dart';
import '../entities/citizen_profile.dart';

abstract class ProfileRepository {
  /// بيانات المواطن الحالي — المستخدم بينحدد من التوكن لا من مُعرّف.
  Future<Result<CitizenProfile>> getProfile();

  /// رفع صورة شخصية.
  ///
  /// بايتات لا `File`: الـ domain بتضل نقية من `dart:io`، والصورة بعد
  /// الضغط أصلاً بتطلع بايتات بالذاكرة فما في داعي نكتبها عالقرص.
  ///
  /// بترجّع رابط الصورة الجديد **لو** رجّعه السيرفر — العقد لسه غير
  /// مثبّت، فـ`null` نتيجة صحيحة لا فشل.
  Future<Result<String?>> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  });

  /// إزالة الصورة الشخصية.
  ///
  /// ⚠️ **بلا endpoint مخصّص** — نفس `POST /api/profile/update`، بس
  /// بحقل `image` فاضي. الافتراض إن الباك اند بيفهم القيمة الفاضية
  /// كـ«امسح الصورة الحالية» لسه غير مؤكّد؛ نقطة التصحيح الوحيدة
  /// `ProfileRemoteDataSource.removeAvatar`.
  Future<Result<void>> removeAvatar();

  /// تحديث بيانات الهوية الأساسية — الاسم الأول والأخير والرقم الوطني
  /// وتاريخ الميلاد.
  ///
  /// ⚠️ نفس `POST /api/profile/update` تبع الصورة، بأسماء حقول
  /// موروثة من عقد `/api/auth/register` المؤكّد (`first_name`،
  /// `last_name`، `national_id`، `birth_date` بصيغة `YYYY/M/D`) — مش
  /// مؤكّدة بشكل مستقل لهالمسار تحديداً. راجع
  /// `ProfileRemoteDataSource.updateIdentity`.
  Future<Result<void>> updateIdentity({
    required String firstName,
    required String lastName,
    required String nationalId,
    required BirthDate birthDate,
  });
}
