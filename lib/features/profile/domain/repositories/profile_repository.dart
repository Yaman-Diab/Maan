// -------------------------
// Profile Repository
// -------------------------

import '../../../../core/result/result.dart';
import '../entities/citizen_profile.dart';

abstract class ProfileRepository {
  /// بيانات المواطن الحالي — المستخدم بينحدد من التوكن لا من مُعرّف.
  Future<Result<CitizenProfile>> getProfile();
}
