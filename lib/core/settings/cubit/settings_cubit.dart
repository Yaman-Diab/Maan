// -------------------------
// Settings Cubit
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../storage/settings_storage_service.dart';
import 'settings_state.dart';

/// تفضيلات العرض على مستوى التطبيق.
///
/// singleton مش factory — على عكس cubits الشاشات: هاي حالة عامة بتعيش
/// طول عمر التطبيق ولازم تكون نفس النسخة لكل من يقرأها.
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsStorageService _storage;

  SettingsCubit(this._storage) : super(const SettingsState());

  /// بتتنادى قبل `runApp` حتى يطلع أول إطار بالثيم الصح مباشرةً.
  void load() {
    emit(
      SettingsState(
        themeMode: AppThemeModeName.fromName(_storage.readThemeMode()),
        textScale: AppTextScale.fromName(_storage.readTextScale()),
        isLoaded: true,
      ),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.themeMode == mode) return;

    emit(state.copyWith(themeMode: mode));
    await _storage.saveThemeMode(mode.name);
  }

  Future<void> setTextScale(AppTextScale scale) async {
    if (state.textScale == scale) return;

    emit(state.copyWith(textScale: scale));
    await _storage.saveTextScale(scale.name);
  }

  /// تبديل سريع بين الفاتح والداكن.
  ///
  /// من وضع النظام بينتقل للعكس المرئي حالياً، لأن "بدّل" من وضع تلقائي
  /// المتوقّع منها تعطي نتيجة مرئية فورية.
  Future<void> toggleTheme({required Brightness current}) {
    final next = switch (state.themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system =>
        current == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
    };

    return setThemeMode(next);
  }
}
