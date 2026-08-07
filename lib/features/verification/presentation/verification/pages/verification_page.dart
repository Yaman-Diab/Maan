// -------------------------
// Verification Page
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_button.dart';
import '../../../../../core/design_system/widgets/image_source_sheet.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/media/image_picker_service.dart';
import '../../../../../core/router/app_routes.dart';
import '../cubit/verification_cubit.dart';
import '../cubit/verification_state.dart';
import '../widgets/verification_approved_view.dart';
import '../widgets/verification_form_view.dart';
import '../widgets/verification_pending_view.dart';
import '../widgets/verification_rejected_view.dart';
import '../widgets/verification_skeleton.dart';

/// شاشة توثيق الهوية.
///
/// شاشة واحدة بأربعة عروض بدل أربع شاشات — العرض بيتحدّد من حالة الطلب
/// اللي بترجع من `GET /api/verification`، مش من ملاحة المستخدم. راجع
/// `VerificationCubit`.
class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  /// الـ Cubit بيحمل القيمة كنص عبر `onChanged`، والـ controller بيضل
  /// بالـ State تبع الصفحة — نفس قاعدة «الـ Cubit بلا Flutter».
  final _nationalIdController = TextEditingController();

  @override
  void dispose() {
    _nationalIdController.dispose();
    super.dispose();
  }

  /// ورقة المصدر ثم الاختيار ثم الإرسال للـ Cubit.
  ///
  /// ⚠️ `pickDocument` لا `pickAvatar`: صور الوثيقة بتحتاج قصّ مستطيل
  /// بدقّة أعلى — راجع تحذير `CLAUDE.md` وتعليق `ImagePickerService`.
  Future<void> _pickImage(BuildContext context, DocumentSlot slot) async {
    final cubit = context.read<VerificationCubit>();

    // قبل أي `await`: القراءة من الشجرة بعد فجوة زمنية ممكن تنهار لو
    // انفصلت الشاشة — نفس نمط `ProfilePage._changeAvatar`.
    final appearance = _cropperAppearance(context);

    final action = await showImageSourceSheet(
      context,
      title: 'verification_photo_sheet_title'.tr(),
      cameraLabel: 'avatar_source_camera'.tr(),
      galleryLabel: 'avatar_source_gallery'.tr(),
    );

    if (action == null || action == ImageSourceAction.remove) return;

    final image = await sl<ImagePickerService>().pickDocument(
      source: action == ImageSourceAction.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      appearance: appearance,
    );

    if (image == null) return;

    cubit.imagePicked(slot, image);
  }

  /// «تعديل» ببطاقة البيانات الشخصية → شاشة تعديل الهوية، ثم إعادة
  /// تحميل حتى تعرض البطاقة القيم الجديدة عند الرجوع.
  ///
  /// إعادة التحميل مشروطة بـ`saved == true`: `EditIdentityPage` بترجّع
  /// `true` بس لما تقفل نفسها بعد حفظ ناجح، فالرجوع بإلغاء ما بيكلّف
  /// طلبين شبكة بلا سبب — نفس منطق `ProfilePage._editIdentity`.
  Future<void> _editProfile(
    BuildContext context,
    VerificationState state,
  ) async {
    final user = state.user;
    if (user == null) return;

    final cubit = context.read<VerificationCubit>();

    final saved = await context.push<bool>(
      AppRoutes.editIdentity,
      extra: user,
    );

    if (saved != true || !context.mounted) return;

    await cubit.load();
  }

  static CropperAppearance _cropperAppearance(BuildContext context) {
    final scheme = context.scheme;

    return CropperAppearance(
      toolbarTitle: 'verification_crop_title'.tr(),
      toolbarColor: scheme.primary,
      toolbarWidgetColor: scheme.onPrimary,
      backgroundColor: scheme.surface,
      activeControlsWidgetColor: scheme.primary,
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
  }

  void _onStateChanged(BuildContext context, VerificationState state) {
    if (state.submission != VerificationSubmission.failure) return;

    final message = state.errorMessage;
    if (message == null) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VerificationCubit>(
      create: (_) => sl<VerificationCubit>()..load(),
      child: Scaffold(
        backgroundColor: context.colors.pageBackground,
        appBar: AppBar(
          title: Text('verification_title'.tr()),
          surfaceTintColor: Colors.transparent,
        ),
        body: SafeArea(
          child: BlocConsumer<VerificationCubit, VerificationState>(
            listener: _onStateChanged,
            builder: (context, state) => _body(context, state),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, VerificationState state) {
    final cubit = context.read<VerificationCubit>();

    switch (state.view) {
      case VerificationView.loading:
        return const VerificationSkeleton();

      case VerificationView.loadFailure:
        return _LoadFailureView(
          message: state.errorMessage,
          onRetry: cubit.load,
        );

      case VerificationView.form:
        // الـ controller بيتزامن مع الحالة لما تجي من السيرفر (تصحيح رقم
        // قائم) — بس بلا ما يقاطع الكتابة الحالية.
        _syncNationalIdController(state.nationalId);

        return VerificationFormView(
          state: state,
          nationalIdController: _nationalIdController,
          onNationalIdChanged: cubit.nationalIdChanged,
          onPickImage: (slot) => _pickImage(context, slot),
          onRemoveImage: cubit.imageRemoved,
          onSubmit: cubit.submit,
          onEditProfile: () => _editProfile(context, state),
        );

      case VerificationView.pending:
        return VerificationPendingView(
          request: state.request!,
          onEditNationalId: cubit.editRequested,
        );

      case VerificationView.rejected:
        return VerificationRejectedView(
          request: state.request!,
          onResubmit: cubit.resubmitRequested,
        );

      case VerificationView.approved:
        return VerificationApprovedView(
          onGoHome: () => context.go(AppRoutes.home),
        );
    }
  }

  /// تعبئة الحقل من الحالة بلا ما تقفز مؤشّرة الكتابة.
  ///
  /// المقارنة إلزامية: `text =` بيرجّع المؤشّرة لأول الحقل، فتنفيذه على
  /// كل إعادة بناء بيخلّي الكتابة مستحيلة (كل حرف بيقفّز المؤشّرة).
  void _syncNationalIdController(String value) {
    if (_nationalIdController.text == value) return;

    _nationalIdController.text = value;
  }
}

class _LoadFailureView extends StatelessWidget {
  const _LoadFailureView({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 44.sp,
              color: context.colors.textHint,
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              message ?? 'error_unknown'.tr(),
              textAlign: TextAlign.center,
              style: context.texts.f14W400GreyColor,
            ),
            SizedBox(height: AppSpacing.md.h),
            AppButton(
              buttonWidth: 180,
              buttonText: 'retry'.tr(),
              buttonOnPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
