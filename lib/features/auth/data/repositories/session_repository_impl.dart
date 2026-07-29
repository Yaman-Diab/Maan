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
    await _storage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );

    if (session.hasUser) {
      await _storage.saveUser(session.user!);
    }
  }

  @override
  Future<void> clearSession() => _storage.clearSession();
}
