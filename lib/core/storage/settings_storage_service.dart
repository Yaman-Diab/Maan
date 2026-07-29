// -------------------------
// Settings Storage Service
// -------------------------

import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorageKeys {
  SettingsStorageKeys._();

  static const String themeMode = 'SETTINGS_THEME_MODE';
  static const String textScale = 'SETTINGS_TEXT_SCALE';
}

/// تفضيلات الواجهة غير الحساسة.
///
/// منفصلة عن `SecureStorageService` عمداً: هاي بتتقرأ عند كل إقلاع قبل
/// أول إطار، والتشفير بيضيف تأخير بلا فايدة أمنية.
///
/// كل الميثودات بتبلع الأخطاء وبترجّع `null` — فشل قراءة تفضيل ما لازم
/// يمنع التطبيق من الإقلاع.
class SettingsStorageService {
  final SharedPreferences _preferences;

  const SettingsStorageService(this._preferences);

  static Future<SettingsStorageService> create() async {
    return SettingsStorageService(await SharedPreferences.getInstance());
  }

  String? readThemeMode() => _read(SettingsStorageKeys.themeMode);

  Future<void> saveThemeMode(String value) {
    return _write(SettingsStorageKeys.themeMode, value);
  }

  String? readTextScale() => _read(SettingsStorageKeys.textScale);

  Future<void> saveTextScale(String value) {
    return _write(SettingsStorageKeys.textScale, value);
  }

  String? _read(String key) {
    try {
      return _preferences.getString(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _preferences.setString(key, value);
    } catch (_) {
      // تفضيل ما انحفظ مش سبب لإسقاط العملية على المستخدم.
    }
  }
}
