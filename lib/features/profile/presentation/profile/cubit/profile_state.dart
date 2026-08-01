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

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  bool get isLoading => status == ProfileStatus.loading;

  /// بيميّز «أول تحميل» عن «إعادة تحميل»: بأول مرة منعرض هيكل التحميل،
  /// وبإعادة التحميل منخلّي البيانات القديمة ظاهرة تحت مؤشّر السحب.
  bool get isFirstLoad => isLoading && profile == null;

  ProfileState copyWith({
    ProfileStatus? status,
    CitizenProfile? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      // ما بتُورَّث: كل حالة بتصرّح برسالتها، فما بتعلق رسالة قديمة.
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
