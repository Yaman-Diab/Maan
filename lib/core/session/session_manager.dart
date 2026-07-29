// -------------------------
// Session Manager
// -------------------------

class SessionManager {
  final Future<void> Function()? onUnauthorized;

  bool _isHandlingUnauthorized = false;

  SessionManager({this.onUnauthorized});

  Future<void> handleUnauthorized() async {
    if (_isHandlingUnauthorized) return;

    _isHandlingUnauthorized = true;

    try {
      await onUnauthorized?.call();
    } finally {
      _isHandlingUnauthorized = false;
    }
  }
}
