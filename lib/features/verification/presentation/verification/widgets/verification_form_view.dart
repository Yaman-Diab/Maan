// -------------------------
// Verification Form View
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/app_validators.dart';
import '../../../../../core/design_system/widgets/app_card.dart';
import '../../../../../core/design_system/widgets/app_submit_button.dart';
import '../../../../../core/design_system/widgets/custom_text_form_field.dart';
import '../../../../../core/design_system/widgets/labeled_field.dart';
import '../cubit/verification_state.dart';
import 'document_upload_slot.dart';
import 'verification_notice_box.dart';
import 'verification_profile_card.dart';

/// عرض النموذج: تنبيه الشروط · الرقم الوطني · صورتا الوثيقة · زر الإرسال.
///
/// نفس الودجت بيخدم حالتين — طلب جديد، و«تصحيح رقم وطني» لطلب قائم
/// (`state.isEditingExisting`). الفرق إن الصور بتنقفل بالتصحيح لأن العقد
/// المؤكّد لـ`update` ما بيشملها.
class VerificationFormView extends StatelessWidget {
  const VerificationFormView({
    super.key,
    required this.state,
    required this.nationalIdController,
    required this.onNationalIdChanged,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onSubmit,
    required this.onEditProfile,
  });

  final VerificationState state;
  final TextEditingController nationalIdController;
  final ValueChanged<String> onNationalIdChanged;
  final ValueChanged<DocumentSlot> onPickImage;
  final ValueChanged<DocumentSlot> onRemoveImage;
  final VoidCallback onSubmit;

  /// «تعديل» ببطاقة البيانات الشخصية — بينقل لشاشة تعديل الهوية.
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final isEditing = state.isEditingExisting;
    final user = state.user;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md.w,
              AppSpacing.xs.h,
              AppSpacing.md.w,
              AppSpacing.md.h,
            ),
            children: [
              const VerificationRulesBox(),
              SizedBox(height: AppSpacing.sm.h),

              // بتختفي لو فشلت قراءة الملف الشخصي — التوثيق ما بيعتمد
              // عليها، فبطاقة بحقول فاضية أسوأ من غيابها.
              if (user != null) ...[
                VerificationProfileCard(user: user, onEdit: onEditProfile),
                SizedBox(height: AppSpacing.sm.h),
              ],

              AppCard(
                padding: EdgeInsets.all(AppSpacing.md.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CardHeader(
                      icon: Icons.badge_outlined,
                      title: 'verification_national_id_section'.tr(),
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    LabeledField(
                      label: 'verification_national_id_label'.tr(),
                      child: CustomTextFormField(
                        controller: nationalIdController,
                        // نفس مُحقِّق شاشة تعديل الهوية — الحقل هو هو،
                        // فقاعدة تحقّق ثانية بتخلق تناقضاً بين شاشتين.
                        validationMessage: AppValidators.requiredNationalId,
                        keyBoardType: TextInputType.number,
                        hintText: 'verification_national_id_hint'.tr(),
                        prefixIcon: const Icon(Icons.badge_outlined),
                        onChanged: onNationalIdChanged,
                        digitsOnly: true,
                        maxLength: AppValidators.nationalIdMaxLength,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs.h),
                    Text(
                      'verification_national_id_helper'.tr(),
                      style: context.texts.f12W400SecColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),

              AppCard(
                padding: EdgeInsets.all(AppSpacing.md.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CardHeader(
                      icon: Icons.description_outlined,
                      title: 'verification_document_section'.tr(),
                    ),
                    SizedBox(height: AppSpacing.md.h),

                    if (isEditing) ...[
                      VerificationInfoBox(
                        message: 'verification_photos_locked_note'.tr(),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                    ],

                    DocumentUploadSlot(
                      label: 'verification_doc_front'.tr(),
                      image: state.frontImage,
                      onPick: () => onPickImage(DocumentSlot.front),
                      onRemove: () => onRemoveImage(DocumentSlot.front),
                      isEnabled: !isEditing && !state.isSubmitting,
                    ),
                    SizedBox(height: AppSpacing.md.h),
                    DocumentUploadSlot(
                      label: 'verification_doc_selfie'.tr(),
                      image: state.selfieImage,
                      onPick: () => onPickImage(DocumentSlot.selfie),
                      onRemove: () => onRemoveImage(DocumentSlot.selfie),
                      isEnabled: !isEditing && !state.isSubmitting,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md.w,
            AppSpacing.xs.h,
            AppSpacing.md.w,
            AppSpacing.md.h,
          ),
          child: AppSubmitButton(
            canSubmit: state.canSubmit,
            isSubmitting: state.isSubmitting,
            label: isEditing
                ? 'verification_save_national_id'.tr()
                : 'verification_submit'.tr(),
            submittingLabel: 'verification_submitting'.tr(),
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}

/// عنوان قسم داخل بطاقة: أيقونة بمربّع ملوّن + نص. متكرر مرتين
/// بالنموذج، فبيتعرّف مرة هون بدل ما ينتسخ.
class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: colors.infoBackground,
            borderRadius: BorderRadius.circular(AppRadius.sm.r),
          ),
          child: Icon(icon, size: 18.sp, color: colors.infoForeground),
        ),
        SizedBox(width: AppSpacing.xs.w),
        Expanded(
          child: Text(
            title,
            style: context.texts.f14W600Black,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
