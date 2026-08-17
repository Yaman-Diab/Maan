// -------------------------
// Location Service
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// إحداثيات جغرافية خام — بلا معرفة بأي ميزة بتستهلكها.
final class LocationResult {
  final double latitude;
  final double longitude;

  const LocationResult({required this.latitude, required this.longitude});
}

enum LocationFailureReason { serviceDisabled, permissionDenied }

class LocationServiceException implements Exception {
  final LocationFailureReason reason;

  const LocationServiceException(this.reason);
}

/// موقع الجهاز الحالي — عام عن قصد بـ`core/` بدل داخل ميزة الشكاوى:
/// أول مستهلك بس لسه، بس نفس منطق `ImagePickerService` (أي ميزة
/// ثانية بدها موقع — شكوى طارئة، طابور... — بتضيف ميثود هون).
class LocationService {
  const LocationService();

  /// بترمي [LocationServiceException] لو خدمة الموقع مطفية أو الإذن
  /// مرفوض — الشاشة يلي بتستدعيها هي المسؤولة عن ترجمة السبب لرسالة.
  Future<LocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const LocationServiceException(
        LocationFailureReason.serviceDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        LocationFailureReason.permissionDenied,
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// اسم مكان مقروء من إحداثيات (reverse geocoding) — بيرجّع `null` بدل
  /// ما يرمي: اسم المكان **تحسين عرض لا بيانات أساسية**، فالإحداثيات
  /// بتضل معروضة لو فشل التحويل (شبكة مقطوعة، منطقة غير مفهرسة، أو
  /// المنصّة ما دعمت الخدمة).
  ///
  /// بياخد [locale] حتى يرجع الاسم بلغة التطبيق لا لغة الجهاز — شاشة
  /// عربية بتعرض «دمشق» لا «Damascus».
  ///
  /// ⚠️ **`geocoding: ^5.0.0` غيّر الواجهة**: الدالة العامة
  /// `placemarkFromCoordinates(...)` صارت ميثود على صنف `Geocoding`،
  /// و`localeIdentifier` النصّي صار `Locale`. كمان **باراميتر `locale`
  /// بالـ constructor مكسور بهالنسخة** (بينحفظ بلا ما ينمرّر للمنصّة)،
  /// فمنمرّره بالميثود مباشرة — هاد المسار الشغّال الوحيد.
  Future<String?> describeCoordinates({
    required double latitude,
    required double longitude,
    Locale? locale,
  }) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
        locale: locale,
      );

      if (placemarks.isEmpty) return null;

      return _format(placemarks.first);
    } catch (_) {
      // فشل الخدمة مش خطأ يستاهل يوقّع الشاشة — راجع تعليق الميثود.
      return null;
    }
  }

  /// من الأدق للأعم، وبنمسك أول جزأين موجودين — «شارع، حي» أو
  /// «حي، مدينة». الحقول اللي بترجع فاضية بتختلف كتير حسب المنطقة،
  /// فبناء النص من الموجود أمتن من قالب ثابت بيطلع فيه فواصل يتيمة.
  ///
  /// الفاصلة نفسها مترجَمة (`،` بالعربي · `,` بالإنجليزي) — علامة ترقيم
  /// بتختلف بين اللغتين متل أي نص ظاهر.
  static String? _format(Placemark placemark) {
    final parts = <String>[
      for (final part in [
        placemark.street,
        placemark.subLocality,
        placemark.locality,
        placemark.administrativeArea,
        placemark.country,
      ])
        if (part != null && part.trim().isNotEmpty) part.trim(),
    ];

    if (parts.isEmpty) return null;

    return parts.take(2).join('${'place_name_separator'.tr()} ');
  }
}
