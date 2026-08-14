import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/network/api_auth_policy.dart';
import 'package:maan/core/network/api_endpoints.dart';

void main() {
  group('نقاط عامة بلا توكن', () {
    test('تسجيل الدخول والتسجيل وأخواتها', () {
      expect(ApiAuthPolicy.isPublicEndpoint(ApiEndpoints.login), isTrue);
      expect(ApiAuthPolicy.isPublicEndpoint(ApiEndpoints.register), isTrue);
      expect(ApiAuthPolicy.isPublicEndpoint(ApiEndpoints.checkCode), isTrue);
      expect(
        ApiAuthPolicy.isPublicEndpoint(ApiEndpoints.forgetPassword),
        isTrue,
      );
      expect(
        ApiAuthPolicy.isPublicEndpoint(ApiEndpoints.resetPassword),
        isTrue,
      );
    });

    test('نقطة الملف الشخصي مش عامة', () {
      expect(ApiAuthPolicy.isPublicEndpoint(ApiEndpoints.profile), isFalse);
    });
  });

  group('تجديد التوكن', () {
    test('مش «عامة» — محتاج هيدر Authorization ليترفق', () {
      // ⚠️ لو رجعت `true` هون، `AuthInterceptor.onRequest` ما بيرفق
      // الهيدر، والباك اند الحقيقي بيرجع "Token not provided" —
      // بالضبط الباگ يلي كانت هالقاعدة بتسبّبه قبل التصحيح.
      expect(ApiAuthPolicy.isPublicEndpoint(ApiEndpoints.refresh), isFalse);
    });

    test('بس بينحسب endpoint تجديد للحماية من حلقة إعادة المحاولة', () {
      expect(ApiAuthPolicy.isRefreshEndpoint(ApiEndpoints.refresh), isTrue);
      expect(ApiAuthPolicy.isRefreshEndpoint(ApiEndpoints.login), isFalse);
    });
  });
}
