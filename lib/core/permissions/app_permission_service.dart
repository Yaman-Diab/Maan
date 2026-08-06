// -------------------------
// App Permission Service
// -------------------------

import 'package:permission_handler/permission_handler.dart';

/// المكان الوحيد اللي بيعرف `permission_handler` بالتطبيق.
///
/// ⚠️ **بلا فحص حالة الإذن (`Permission.x.status`) عمداً** — عرض شارة
/// «مسموح/غير مسموح» حقيقية كان بيكذب على المستخدم بالوضع الحالي:
///
/// * **الكاميرا/المعرض**: `image_picker` بيفتح تطبيق الكاميرا/المعرض
///   عبر intent (Android) لا عبر إذن وقت التشغيل مباشر، فـ
///   `Permission.camera.status` بيرجّع «مرفوض» حتى لو التصوير شغّال
///   100% فعلياً — لأن التطبيق أصلاً ما بيطلب هالإذن بنفسه.
/// * **الموقع**: ما في ولا ميزة بالتطبيق بتستخدمه لسه (`AppRedirect`
///   وثائق الميزة لسه فاضية)، فحالته دائماً «مرفوض» بلا معنى حقيقي.
///
/// فالوظيفة الوحيدة هون فتح إعدادات النظام — صحيحة ومفيدة بغضّ النظر
/// عن الحالة، وما بتحتاج إعلان إذن بـ`AndroidManifest`/`Info.plist`.
/// يوم توصل ميزة حقيقية بتحتاج فحص حالة (مثلاً كاميرا مباشرة بدل
/// intent، أو شكوى بموقع)، إضافة `checkStatus` هون بمكان واحد.
class AppPermissionService {
  const AppPermissionService();

  Future<void> openSystemSettings() {
    return openAppSettings();
  }
}
