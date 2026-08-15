// -------------------------
// Location Service
// -------------------------

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
      throw const LocationServiceException(LocationFailureReason.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(LocationFailureReason.permissionDenied);
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return LocationResult(latitude: position.latitude, longitude: position.longitude);
  }
}
