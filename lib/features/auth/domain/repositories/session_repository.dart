// -------------------------
// Session Repository (Contract)
// -------------------------

import '../entities/auth_session.dart';

/// حفظ الجلسة ومسحها، بمعزل عن آلية التخزين.
///
/// التنفيذ بيلفّ `SecureStorageService`، فالـ use cases بتقدر تنسّق
/// حفظ الجلسة بدون ما تعرف شي عن التخزين الآمن.
abstract class SessionRepository {
  Future<void> persistSession(AuthSession session);

  Future<void> clearSession();
}
