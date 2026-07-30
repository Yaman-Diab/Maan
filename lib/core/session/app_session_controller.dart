
// -------------------------
// App Session Controller
// -------------------------

import 'package:flutter/foundation.dart';

import '../storage/secure_storage_service.dart';

class AppSessionController extends ChangeNotifier {
  final SecureStorageService storage;

  AppSessionController({required this.storage});

  bool _isInitialized = false;
  bool _isLoggedIn = false;
  bool _isGuest = false;

  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;

  // -------------------------
  // Bootstrap
  // -------------------------

  /// [minimumDuration] حدّ أدنى **لا تأخير إضافي**: لو خلص الإقلاع بـ80ms
  /// بننتظر الباقي، ولو أخذ ثلاث ثوانٍ ما بنضيف عليه ولا ملّي ثانية.
  ///
  /// السبب إن `isInitialized` هو اللي بيرفع شاشة البداية عبر
  /// `AppRedirect`، وحركة دخولها بتاخد وقتاً — بلا هالحدّ بتختفي الشاشة
  /// قبل ما تكتمل الحركة. القيمة بتجي من نقطة التركيب لا مكتوبة هون،
  /// فالتحكم بالتوقيت بيضل عند الواجهة.
  Future<void> bootstrap({
    Duration minimumDuration = Duration.zero,
  }) async {
    final startedAt = DateTime.now();

    _isLoggedIn = await storage.isLoggedIn();
    _isGuest = await storage.isGuest();

    if (!_isLoggedIn && !_isGuest) {
      await _setGuestState();
    }

    final remaining = minimumDuration - DateTime.now().difference(startedAt);

    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    _isInitialized = true;
    notifyListeners();
  }

  // -------------------------
  // Auth State
  // -------------------------

  Future<void> loginCompleted() async {
    _isLoggedIn = true;
    _isGuest = false;

    await storage.setGuest(false);

    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    await _setGuestState();
    notifyListeners();
  }

  Future<void> logout() async {
    await _clearSessionAndBecomeGuest();
    notifyListeners();
  }

  Future<void> handleUnauthorized() async {
    await _clearSessionAndBecomeGuest();
    notifyListeners();
  }

  // -------------------------
  // Private Helpers
  // -------------------------

  Future<void> _clearSessionAndBecomeGuest() async {
    await storage.clearSession(keepVisitorId: true, keepGuestFlag: false);

    await _setGuestState();
  }

  Future<void> _setGuestState() async {
    await storage.setGuest(true);

    _isLoggedIn = false;
    _isGuest = true;
  }
}
