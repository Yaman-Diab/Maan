import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// حارس دائم لجودة الترجمة.
///
/// المشروع بيستخدم مفاتيح نصية مباشرة (`'sign_in'.tr()`) بلا ثوابت ولا
/// codegen — راجع التعليق بـ`AppValidators`. الحماية من الأخطاء المطبعية
/// والمفاتيح الناقصة بتيجي من هون: الاختبار بيمسح `lib/` كاملاً وبيقارن
/// المفاتيح المستخدمة بمحتوى ملفَّي الترجمة.
///
/// أي مفتاح جديد بينضاف بالكود بلا ترجمة بيوقّع البناء فوراً، بدل ما
/// يظهر للمستخدم كنص خام مثل `verification_help_step1`.
void main() {
  late Map<String, dynamic> en;
  late Map<String, dynamic> ar;
  late Set<String> usedKeys;
  late Map<String, List<String>> keyLocations;

  setUpAll(() {
    en = _readJson('assets/translations/en.json');
    ar = _readJson('assets/translations/ar.json');

    final scan = _scanUsedKeys();
    usedKeys = scan.keys.toSet();
    keyLocations = scan;
  });

  group('تماثل ملفات الترجمة', () {
    test('الملفان فيهما نفس المفاتيح تماماً', () {
      final missingInAr = en.keys.toSet().difference(ar.keys.toSet());
      final missingInEn = ar.keys.toSet().difference(en.keys.toSet());

      expect(
        missingInAr,
        isEmpty,
        reason: 'مفاتيح موجودة بالإنجليزي وناقصة بالعربي: $missingInAr',
      );
      expect(
        missingInEn,
        isEmpty,
        reason: 'مفاتيح موجودة بالعربي وناقصة بالإنجليزي: $missingInEn',
      );
    });

    test('ما في قيمة فاضية بغير قصد', () {
      // terms_agreement_suffix فاضية بالإنجليزي عن قصد: الجملة بتنتهي
      // عند "Privacy Policy"، بينما بالعربي بتكمل بـ«الخاصتين بـمعًا».
      const intentionallyEmpty = {'terms_agreement_suffix'};

      for (final entry in en.entries) {
        if (intentionallyEmpty.contains(entry.key)) continue;
        expect(
          (entry.value as String).trim(),
          isNotEmpty,
          reason: 'قيمة إنجليزية فاضية: ${entry.key}',
        );
      }

      for (final entry in ar.entries) {
        if (intentionallyEmpty.contains(entry.key)) continue;
        expect(
          (entry.value as String).trim(),
          isNotEmpty,
          reason: 'قيمة عربية فاضية: ${entry.key}',
        );
      }
    });

    test('ما في مفتاح مكرر داخل نفس الملف', () {
      // jsonDecode بيبلع المكرر بصمت، فبنعدّ الظهور بالنص الخام.
      for (final path in [
        'assets/translations/en.json',
        'assets/translations/ar.json',
      ]) {
        final raw = File(path).readAsStringSync();
        final found = RegExp(r'^\s*"([^"]+)"\s*:', multiLine: true)
            .allMatches(raw)
            .map((m) => m.group(1)!)
            .toList();

        final duplicates = <String>{};
        final seen = <String>{};
        for (final key in found) {
          if (!seen.add(key)) duplicates.add(key);
        }

        expect(duplicates, isEmpty, reason: 'مفاتيح مكررة بـ$path: $duplicates');
      }
    });
  });

  group('المفاتيح المستخدمة بالكود', () {
    test('كل مفتاح مستخدم موجود بالملفين', () {
      final missing = <String, List<String>>{};

      for (final key in usedKeys) {
        if (!en.containsKey(key) || !ar.containsKey(key)) {
          missing[key] = keyLocations[key]!;
        }
      }

      expect(
        missing,
        isEmpty,
        reason:
            'مفاتيح مستخدمة بالكود وما إلها ترجمة:\n'
            '${missing.entries.map((e) => '  ${e.key} → ${e.value.join(", ")}').join("\n")}',
      );
    });

    test('ما في مفاتيح معرّفة وغير مستخدمة', () {
      final unused = en.keys.where((key) => !usedKeys.contains(key)).toList()
        ..sort();

      expect(
        unused,
        isEmpty,
        reason: 'مفاتيح موجودة بالترجمة وما حدا بيستخدمها: $unused',
      );
    });
  });

  group('اتساق المصطلحات بالعربي', () {
    test('مصطلح واحد لكل إجراء متكرر', () {
      // خلط «التسجيل» و«إنشاء حساب» و«اشتراك» لنفس الزر بيربك المستخدم.
      expect(ar['sign_in'], 'تسجيل الدخول');
      expect(ar['sign_up'], 'إنشاء حساب');
      expect(ar['cancel'], 'إلغاء');
      expect(ar['confirm'], 'تأكيد');
    });

    test('حالات التحميل بصيغة «جارٍ ...»', () {
      const loadingKeys = [
        'loading',
        'sending',
        'signing_in',
        'creating_account',
        'updating',
        'verifying',
      ];

      for (final key in loadingKeys) {
        expect(
          ar[key] as String,
          startsWith('جارٍ'),
          reason: '$key لازم يتبع صيغة «جارٍ ...» مثل باقي حالات التحميل',
        );
      }
    });

    test('علامة الاستفهام العربية ؟ لا اللاتينية ?', () {
      for (final entry in ar.entries) {
        expect(
          entry.value as String,
          isNot(contains('?')),
          reason: '${entry.key} بيستخدم ? بدل ؟ العربية',
        );
      }
    });

    test('الوسائط المسمّاة متطابقة بين اللغتين', () {
      final placeholder = RegExp(r'\{(\w+)\}');

      for (final key in en.keys) {
        final enArgs =
            placeholder.allMatches(en[key] as String).map((m) => m.group(1)!).toSet();
        final arArgs =
            placeholder.allMatches(ar[key] as String).map((m) => m.group(1)!).toSet();

        expect(
          arArgs,
          enArgs,
          reason: 'وسائط غير متطابقة بـ$key — en:$enArgs ar:$arArgs',
        );
      }
    });
  });

  group('ما في نصوص ثابتة بالكود', () {
    test('ما في نص عربي مكتوب يدوياً داخل lib/', () {
      final arabic = RegExp(r'''['"][^'"]*[؀-ۿ][^'"]*['"]''');
      final offenders = <String>[];

      for (final file in _dartFiles()) {
        final lines = file.readAsLinesSync();

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];

          // التعليقات بالعربي مسموحة ومقصودة بهذا المشروع.
          final trimmed = line.trimLeft();
          if (trimmed.startsWith('//') || trimmed.startsWith('///')) continue;

          if (arabic.hasMatch(line)) {
            offenders.add('${file.path}:${i + 1} → ${line.trim()}');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'نصوص عربية ثابتة لازم تنتقل للترجمة:\n${offenders.join("\n")}',
      );
    });
  });
}

// -------------------------
// Helpers
// -------------------------

Map<String, dynamic> _readJson(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}

Iterable<File> _dartFiles() {
  return Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
}

/// بيرجّع كل مفتاح مستخدم مع أماكن استخدامه، حتى تكون رسالة الفشل
/// قابلة للتنفيذ مباشرةً بدل مجرد اسم مفتاح.
Map<String, List<String>> _scanUsedKeys() {
  final pattern = RegExp(r'''['"]([a-z0-9_]+)['"]\s*\.tr\(''');
  final result = <String, List<String>>{};

  for (final file in _dartFiles()) {
    final lines = file.readAsLinesSync();

    for (var i = 0; i < lines.length; i++) {
      for (final match in pattern.allMatches(lines[i])) {
        final key = match.group(1)!;
        result.putIfAbsent(key, () => []).add('${file.path}:${i + 1}');
      }
    }
  }

  return result;
}
