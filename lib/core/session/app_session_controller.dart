
// -------------------------
// App Session Controller
// -------------------------

import 'package:flutter/foundation.dart';

import '../storage/secure_storage_service.dart';
import 'account_status.dart';

class AppSessionController extends ChangeNotifier {
  final SecureStorageService storage;

  AppSessionController({required this.storage});

  bool _isInitialized = false;
  bool _isLoggedIn = false;
  bool _isGuest = false;
  AccountStatus _accountStatus = AccountStatus.unknown;

  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;

  /// حالة الحساب على السيرفر — بتحدد شو المستخدم مسموح يعمل.
  ///
  /// المتحكّم ما بيعرف **من وين** بتجي: ممكن من استجابة الدخول أو من
  /// `/api/profile`. اللي بيجيبها بينادي [accountStatusChanged]، فالربط
  /// بيضل سطراً واحداً مهما تغيّر عقد الباك اند.
  AccountStatus get accountStatus => _accountStatus;

  /// اختصار للحراسة — `AppRedirect` وواجهات الميزات بتستخدمه.
  bool get canUseMunicipalityServices =>
      _isLoggedIn && _accountStatus.canUseMunicipalityServices;

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

    // النسخة المخبّأة حتى يطلع أول إطار بالصلاحية الصحيحة بدل ما ينتظر
    // الشبكة. السيرفر بيصحّحها لاحقاً عبر accountStatusChanged.
    _accountStatus = AccountStatus.fromApi(await storage.getAccountStatus());

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

  /// [accountStatus] اختياري لأن عقد استجابة الدخول لسه غير مثبّت: لو ما
  /// رجّعت حالة الحساب، بتضل [AccountStatus.unknown] لحد ما تُجلب من
  /// `/api/profile` وتوصل عبر [accountStatusChanged].
  Future<void> loginCompleted({AccountStatus? accountStatus}) async {
    _isLoggedIn = true;
    _isGuest = false;

    await storage.setGuest(false);

    if (accountStatus != null) {
      await _persistAccountStatus(accountStatus);
    }

    notifyListeners();
  }

  /// تحديث حالة الحساب من السيرفر.
  ///
  /// نقطة الدخول الوحيدة لأي مصدر — استجابة الدخول، أو `/api/profile`،
  /// أو مزامنة بعد اعتماد التوثيق.
  Future<void> accountStatusChanged(AccountStatus status) async {
    if (_accountStatus == status) return;

    await _persistAccountStatus(status);

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

    // الزائر بلا حساب، فأي صلاحية سابقة لازم تسقط.
    _accountStatus = AccountStatus.unknown;
  }

  Future<void> _persistAccountStatus(AccountStatus status) async {
    _accountStatus = status;

    await storage.saveAccountStatus(status.wireValue);
  }
}
