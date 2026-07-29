import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/error/failure_mapper.dart';
import 'package:maan/core/network/api_error_codes.dart';
import 'package:maan/core/network/api_exception.dart';

ApiException _exception({
  int? statusCode,
  String? errorCode,
  dynamic data,
  String userMessage = 'رسالة',
}) {
  return ApiException(
    message: 'raw',
    userMessage: userMessage,
    statusCode: statusCode,
    errorCode: errorCode,
    data: data,
  );
}

void main() {
  group('FailureMapper — تصنيف حسب كود الخطأ', () {
    test('أكواد الـ OTP بتتحوّل لـ OtpFailure', () {
      const codes = [
        ApiErrorCodes.otpInvalid,
        ApiErrorCodes.otpExpired,
        ApiErrorCodes.otpMaxAttempts,
        ApiErrorCodes.otpRateLimited,
        ApiErrorCodes.otpDeliveryFailed,
      ];

      for (final code in codes) {
        final failure = FailureMapper.fromApiException(
          _exception(statusCode: 400, errorCode: code),
        );

        expect(failure, isA<OtpFailure>(), reason: code);
        expect(failure.code, code);
      }
    });

    test('أكواد المصادقة بتتحوّل لـ AuthFailure', () {
      const codes = [
        ApiErrorCodes.invalidCredentials,
        ApiErrorCodes.inactiveAccount,
        ApiErrorCodes.invalidToken,
        ApiErrorCodes.tokenNotValid,
        ApiErrorCodes.userNotFound,
      ];

      for (final code in codes) {
        expect(
          FailureMapper.fromApiException(_exception(errorCode: code)),
          isA<AuthFailure>(),
          reason: code,
        );
      }
    });

    test('كود الخطأ أولوية أعلى من رمز الحالة', () {
      // 500 لحاله بيعطي ServerFailure، بس كود الـ OTP بيغلب.
      final failure = FailureMapper.fromApiException(
        _exception(statusCode: 500, errorCode: ApiErrorCodes.otpExpired),
      );

      expect(failure, isA<OtpFailure>());
    });
  });

  group('FailureMapper — تصنيف حسب رمز الحالة', () {
    test('بلا رمز حالة يعني الطلب ما وصل السيرفر', () {
      expect(
        FailureMapper.fromApiException(_exception()),
        isA<NetworkFailure>(),
      );
    });

    test('401 و 403 و 302 بتتحوّل لـ AuthFailure', () {
      for (final status in [401, 403, 302]) {
        expect(
          FailureMapper.fromApiException(_exception(statusCode: status)),
          isA<AuthFailure>(),
          reason: '$status',
        );
      }
    });

    test('429 بتتحوّل لـ RateLimitFailure', () {
      expect(
        FailureMapper.fromApiException(_exception(statusCode: 429)),
        isA<RateLimitFailure>(),
      );
    });

    test('5xx بتتحوّل لـ ServerFailure', () {
      for (final status in [500, 503]) {
        expect(
          FailureMapper.fromApiException(_exception(statusCode: status)),
          isA<ServerFailure>(),
          reason: '$status',
        );
      }
    });

    test('404 ما إلها تصنيف خاص فبتوقع على UnknownFailure', () {
      expect(
        FailureMapper.fromApiException(_exception(statusCode: 404)),
        isA<UnknownFailure>(),
      );
    });
  });

  group('FailureMapper — أخطاء الحقول', () {
    test('400 بتقرأ أخطاء الحقول من errors', () {
      final failure = FailureMapper.fromApiException(
        _exception(
          statusCode: 400,
          data: {
            'errors': {
              'email': ['هذا البريد مستخدم'],
              'password': ['كلمة المرور قصيرة', 'بدون رموز'],
            },
          },
        ),
      );

      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).fieldErrors, {
        'email': ['هذا البريد مستخدم'],
        'password': ['كلمة المرور قصيرة', 'بدون رموز'],
      });
    });

    test('400 بدون errors بترجع ValidationFailure بلا تفاصيل حقول', () {
      final failure = FailureMapper.fromApiException(
        _exception(statusCode: 400, data: {'message': 'خطأ'}),
      );

      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).fieldErrors, isNull);
    });
  });

  group('FailureMapper.fromError', () {
    test('بتحافظ على رسالة ApiException الجاهزة للعرض', () {
      final failure = FailureMapper.fromError(
        _exception(statusCode: 401, userMessage: 'بيانات الدخول غير صحيحة'),
      );

      expect(failure.message, 'بيانات الدخول غير صحيحة');
    });

    test('FormatException بتتحوّل لخطأ قراءة استجابة', () {
      final failure = FailureMapper.fromError(
        const FormatException('bad shape'),
      );

      expect(failure, isA<UnknownFailure>());
      expect(failure.message, 'تعذر قراءة استجابة الخادم');
    });

    test('أي استثناء آخر بيصير UnknownFailure', () {
      expect(
        FailureMapper.fromError(Exception('boom')),
        isA<UnknownFailure>(),
      );
    });
  });
}
