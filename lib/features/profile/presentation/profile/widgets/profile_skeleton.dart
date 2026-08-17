// -------------------------
// Profile Skeleton
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/session/account_status.dart';
import '../../../../auth/domain/entities/auth_user.dart';
import '../../../domain/entities/citizen_profile.dart';
import '../../../domain/entities/profile_stats.dart';
import 'profile_content.dart';

/// هيكل تحميل أول فتح للشاشة — بدل `CircularProgressIndicator` بشكل
/// البطاقات الحقيقية وهي عم تحمّل.
///
/// بيغلّف `ProfileContent` الحقيقي ببيانات وهمية بدل ما يبني نسخة UI
/// موازية — أي تعديل مستقبلي على شكل الشاشة بينعكس هون تلقائياً بلا
/// صيانة إضافية. النصوص الوهمية إنجليزية قصيرة بس: طول النص هو المهم
/// لعرض شكل العظمة، مش محتواه — والنص أصلاً مغطّى بالكامل بالعظمة فما
/// بيشوفه المستخدم. القيم غير الفاضية (رقم وطني، تاريخ ميلاد) مقصودة
/// كمان: لو تركناها `null` كانت الحقول رح تعرض «—» (حرف وحيد) فيطلع
/// عظم بعرض غريب بدل شريط بعرض واقعي.
///
/// بلا `onAddPhotoTap`/`onEditTap`/`onVerifyTap`: هيك ما في عناصر قابلة
/// للنقر أصلاً وقت التحميل (`Skeletonizer.ignorePointers` بتمنع اللمس
/// افتراضياً برضه، بس بلا حاجة نعتمد عليها).
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  /// `onCertificatesTap` إلزامي بـ`ProfileContent` (بانر ثابت لا شرطي)،
  /// فبتحتاج شي هون حتى لو `ignorePointers` مانع اللمس أصلاً.
  static void _noop() {}

  static final _dummyProfile = CitizenProfile(
    user: AuthUser(
      id: 0,
      firstName: 'Name',
      lastName: 'Surname',
      email: 'name@example.com',
      accountStatus: AccountStatus.visitor,
      nationalId: '000000000000',
      birthDate: DateTime(2000, 1, 1),
    ),
    stats: const ProfileStats(
      citizenshipIndex: 60,
      credibilityIndex: 80,
      volunteeringCount: 3,
      contributionsCount: 5,
      licensesCount: 2,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      // بادينغ مطابق تماماً لمحتوى الشاشة الحقيقي (`_ProfileBody`) —
      // حتى ما يصير قفزة بالتخطيط لحظة وصول البيانات الحقيقية.
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
      child: Skeletonizer(
        effect: ShimmerEffect(
          baseColor: colors.fieldDisabledBackground,
          highlightColor: colors.fieldBackground,
        ),
        child: ProfileContent(profile: _dummyProfile, onCertificatesTap: _noop),
      ),
    );
  }
}
