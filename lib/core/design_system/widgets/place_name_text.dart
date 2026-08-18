// -------------------------
// Place Name Text
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../di/service_locator.dart';
import '../../location/location_service.dart';

/// اسم المكان من إحداثيات — بيحلّه بالخلفية وبيعرض الإحداثيات كنص
/// احتياطي لحد ما يوصل (أو للأبد لو فشل التحويل).
///
/// بـ`core/` لا داخل ميزة الشكاوى: أي شاشة عندها إحداثيات (الشكاوى
/// اليوم، المشاريع/الأخبار لما تنبني) بدها نفس السلوك حرفياً — نفس منطق
/// `LocationService` نفسها.
///
/// ⚠️ **التحويل بيصير بالودجت لا بالـ Cubit عن قصد**: اسم المكان تحسين
/// عرض بحت، ما بيدخل بأي قرار أو إرسال، والـ`Complaint` كيان domain ما
/// لازم يحمل حقلاً مصدره خدمة نظام لا الباك اند. كمان القائمة ممكن
/// تعرض عشرات الشكاوى — تحويلها كلها بالـCubit قبل أول إطار بيأخّر
/// الشاشة كلها، بينما هون كل بطاقة بتحلّ اسمها لحالها بلا ما توقف غيرها.
class PlaceNameText extends StatefulWidget {
  const PlaceNameText({
    super.key,
    required this.latitude,
    required this.longitude,
    this.style,
    this.maxLines = 1,
  });

  final double latitude;
  final double longitude;
  final TextStyle? style;
  final int maxLines;

  @override
  State<PlaceNameText> createState() => _PlaceNameTextState();
}

class _PlaceNameTextState extends State<PlaceNameText> {
  String? _placeName;

  /// آخر لغة صار التحويل فيها — مش `initState`: `context.locale` بيعتمد
  /// على `EasyLocalization.of(context)` (InheritedWidget)، وقراءته قبل
  /// ما يخلص `initState` بترمي استثناء حقيقي (جرّبناه على جهاز حقيقي).
  /// `didChangeDependencies` هو المكان الصحيح، وبيتنادى تلقائياً أول
  /// مرة بعد `initState` كمان فبيغطّي التحميل الأولي.
  Locale? _resolvedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = context.locale;

    if (_resolvedLocale != locale) {
      _resolvedLocale = locale;
      _resolve();
    }
  }

  @override
  void didUpdateWidget(PlaceNameText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final name = await sl<LocationService>().describeCoordinates(
      latitude: widget.latitude,
      longitude: widget.longitude,
      // اللغة من التطبيق لا من الجهاز — شاشة عربية بتعرض «دمشق» لا
      // «Damascus» حتى لو نظام الجهاز إنجليزي.
      locale: context.locale,
    );

    if (!mounted) return;

    setState(() => _placeName = name);
  }

  /// الإحداثيات كنص احتياطي — أفضل من فراغ، ونفس اللي كانت الشاشة
  /// بتعرضه قبل ما ينضاف التحويل.
  String get _fallback =>
      '${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}';

  @override
  Widget build(BuildContext context) {
    return Text(
      _placeName ?? _fallback,
      maxLines: widget.maxLines,
      overflow: TextOverflow.ellipsis,
      style: widget.style,
    );
  }
}
