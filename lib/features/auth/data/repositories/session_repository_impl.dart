// -------------------------
// Session Repository Impl
// -------------------------

import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SecureStorageService _storage;

  const SessionRepositoryImpl(this._storage);

  @override
  Future<void> persistSession(AuthSession session) async {
    // ما في refresh token عند هالـ backend (توكن JWT واحد)، فما بنكتب
    // قيمة وهمية على `REFRESH_TOKEN` — راجع تعليق `AuthSession`.
    await _storage.saveAccessToken(session.accessToken);
  }

  @override
  Future<void> clearSession() => _storage.clearSession();
}
