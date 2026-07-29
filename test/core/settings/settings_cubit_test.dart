import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/settings/cubit/settings_cubit.dart';
import 'package:maan/core/settings/cubit/settings_state.dart';
import 'package:maan/core/storage/settings_storage_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsStorage extends Mock implements SettingsStorageService {}

void main() {
  late _MockSettingsStorage storage;

  SettingsCubit build() => SettingsCubit(storage);

  setUp(() {
    storage = _MockSettingsStorage();

    when(() => storage.readThemeMode()).thenReturn(null);
    when(() => storage.readTextScale()).thenReturn(null);
    when(() => storage.saveThemeMode(any())).thenAnswer((_) async {});
    when(() => storage.saveTextScale(any())).thenAnswer((_) async {});
  });

  group('AppTextScale', () {
    test('معاملات التكبير مرتبة تصاعدياً', () {
      expect(AppTextScale.small.factor, lessThan(AppTextScale.normal.factor));
      expect(AppTextScale.normal.factor, 1);
      expect(AppTextScale.large.factor, greaterThan(1));
      expect(
        AppTextScale.extraLarge.factor,
        greaterThan(AppTextScale.large.factor),
      );
    });

    test('اسم غير معروف بيرجع للافتراضي بدل ما ينهار', () {
      expect(AppTextScale.fromName('حجم-غير-موجود'), AppTextScale.normal);
      expect(AppTextScale.fromName(null), AppTextScale.normal);
      expect(AppTextScale.fromName('large'), AppTextScale.large);
    });

    test('وضع ثيم غير معروف بيرجع لوضع النظام', () {
      expect(AppThemeModeName.fromName('bogus'), ThemeMode.system);
      expect(AppThemeModeName.fromName(null), ThemeMode.system);
      expect(AppThemeModeName.fromName('dark'), ThemeMode.dark);
    });
  });

  group('load', () {
    blocTest<SettingsCubit, SettingsState>(
      'بلا تفضيلات محفوظة بتستخدم الافتراضيات',
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => const [
        SettingsState(
          themeMode: ThemeMode.system,
          textScale: AppTextScale.normal,
          isLoaded: true,
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'بتقرأ التفضيلات المحفوظة',
      build: () {
        when(() => storage.readThemeMode()).thenReturn('dark');
        when(() => storage.readTextScale()).thenReturn('large');
        return build();
      },
      act: (cubit) => cubit.load(),
      expect: () => const [
        SettingsState(
          themeMode: ThemeMode.dark,
          textScale: AppTextScale.large,
          isLoaded: true,
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'قيمة تالفة بالتخزين ما بتوقّع الإقلاع',
      build: () {
        when(() => storage.readThemeMode()).thenReturn('!!تالف!!');
        return build();
      },
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.themeMode, ThemeMode.system);
        expect(cubit.state.isLoaded, isTrue);
      },
    );
  });

  group('setThemeMode', () {
    blocTest<SettingsCubit, SettingsState>(
      'بتغيّر الحالة وبتحفظ',
      build: build,
      act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
      expect: () => const [SettingsState(themeMode: ThemeMode.dark)],
      verify: (_) => verify(() => storage.saveThemeMode('dark')).called(1),
    );

    blocTest<SettingsCubit, SettingsState>(
      'نفس القيمة ما بتصدر حالة ولا بتكتب على القرص',
      build: build,
      act: (cubit) => cubit.setThemeMode(ThemeMode.system),
      expect: () => const <SettingsState>[],
      verify: (_) => verifyNever(() => storage.saveThemeMode(any())),
    );
  });

  group('setTextScale', () {
    blocTest<SettingsCubit, SettingsState>(
      'بتغيّر الحالة وبتحفظ',
      build: build,
      act: (cubit) => cubit.setTextScale(AppTextScale.extraLarge),
      expect: () => const [SettingsState(textScale: AppTextScale.extraLarge)],
      verify: (_) =>
          verify(() => storage.saveTextScale('extraLarge')).called(1),
    );
  });

  group('toggleTheme', () {
    blocTest<SettingsCubit, SettingsState>(
      'من فاتح لداكن',
      build: build,
      seed: () => const SettingsState(themeMode: ThemeMode.light),
      act: (cubit) => cubit.toggleTheme(current: Brightness.light),
      verify: (cubit) => expect(cubit.state.themeMode, ThemeMode.dark),
    );

    blocTest<SettingsCubit, SettingsState>(
      'من داكن لفاتح',
      build: build,
      seed: () => const SettingsState(themeMode: ThemeMode.dark),
      act: (cubit) => cubit.toggleTheme(current: Brightness.dark),
      verify: (cubit) => expect(cubit.state.themeMode, ThemeMode.light),
    );

    blocTest<SettingsCubit, SettingsState>(
      'من وضع النظام بتعطي عكس المعروض حالياً',
      build: build,
      act: (cubit) => cubit.toggleTheme(current: Brightness.dark),
      verify: (cubit) => expect(cubit.state.themeMode, ThemeMode.light),
    );
  });
}
