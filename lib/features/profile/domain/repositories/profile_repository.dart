// -------------------------
// Profile Repository
// -------------------------

import 'dart:typed_data';

import '../../../../core/result/result.dart';
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
}
