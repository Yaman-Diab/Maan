// -------------------------
// Profile State
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../domain/entities/citizen_profile.dart';

enum ProfileStatus { initial, loading, success, failure }

/// حالة شاشة الملف الشخصي.
final class ProfileState extends Equatable {
  final ProfileStatus status;
  final CitizenProfile? profile;
  final String? errorMessage;

  /// مسار الصورة اللي رفعها المستخدم هالجلسة.
  ///
  /// بتسبق `user.avatarUrl` بالعرض، ومسار نصّي لا بايتات عن قصد: مقارنة
  /// الحالة بتصير على نص بدل ما تقارن مصفوفة بايت كاملة كل rebuild.
  ///
  /// بتخلّي الصورة تبيّن فوراً بعد الرفع حتى لو الباك اند ما رجّع الرابط
  /// (العقد لسه غير مثبّت) — وبتنسى نفسها عند إعادة التشغيل فبيرجع
  /// السيرفر هو المرجع.
  final String? localAvatarPath;

  final bool isUploadingAvatar;

  /// خطأ الرفع منفصل عن [errorMessage]: فشل رفع الصورة ما بيخرّب الشاشة
  /// كلها، فبينعرض كـ SnackBar والملف بيضل ظاهر.
  final String? avatarErrorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.localAvatarPath,
    this.isUploadingAvatar = false,
    this.avatarErrorMessage,
  });

  bool get isLoading => status == ProfileStatus.loading;

  /// بيميّز «أول تحميل» عن «إعادة تحميل»: بأول مرة منعرض هيكل التحميل،
  /// وبإعادة التحميل منخلّي البيانات القديمة ظاهرة تحت مؤشّر السحب.
  bool get isFirstLoad => isLoading && profile == null;

  ProfileState copyWith({
    ProfileStatus? status,
    CitizenProfile? profile,
    String? errorMessage,
    String? localAvatarPath,
    bool clearLocalAvatar = false,
    bool? isUploadingAvatar,
    String? avatarErrorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      // ما بتُورَّث: كل حالة بتصرّح برسالتها، فما بتعلق رسالة قديمة.
      errorMessage: errorMessage,
      // علم صريح لأن `null` بتعني «ما بدي أغيّر» لا «امسحها» — ولازم
      // نقدر نمسحها فعلاً لما يفشل الرفع.
      localAvatarPath: clearLocalAvatar
          ? null
          : (localAvatarPath ?? this.localAvatarPath),
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      // نفس منطق `errorMessage` — سناك بار مرة وحدة لا مع كل rebuild.
      avatarErrorMessage: avatarErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    errorMessage,
    localAvatarPath,
    isUploadingAvatar,
    avatarErrorMessage,
  ];
}
