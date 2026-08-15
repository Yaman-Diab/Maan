// -------------------------
// Submit Complaint Page
// -------------------------

import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_card.dart';
import '../../../../../core/design_system/widgets/app_submit_button.dart';
import '../../../../../core/design_system/widgets/custom_text_form_field.dart';
import '../../../../../core/design_system/widgets/labeled_field.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/media/image_picker_service.dart';
import '../../../domain/entities/complaint_category.dart';
import '../../../domain/entities/complaint_type.dart';
import '../../shared/complaint_style.dart';
import '../cubit/submit_complaint_cubit.dart';
import '../cubit/submit_complaint_state.dart';
import '../widgets/complaint_media_grid.dart';
import '../widgets/complaint_media_source_sheet.dart';

/// تقديم شكوى جديدة. `Navigator.pop(true)` بعد نجاح الإرسال — نفس نمط
/// `EditIdentityPage`، فالقائمة تعرف تحدّث نفسها بلا استعلام إضافي.
class SubmitComplaintPage extends StatelessWidget {
  const SubmitComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubmitComplaintCubit>(
      create: (_) => sl<SubmitComplaintCubit>(),
      child: const _SubmitComplaintView(),
    );
  }
}

class _SubmitComplaintView extends StatefulWidget {
  const _SubmitComplaintView();

  @override
  State<_SubmitComplaintView> createState() => _SubmitComplaintViewState();
}

class _SubmitComplaintViewState extends State<_SubmitComplaintView> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(BuildContext context) async {
    final source = await showComplaintMediaSourceSheet(context);
    if (source == null || !context.mounted) return;

    final picker = sl<ImagePickerService>();
    final cubit = context.read<SubmitComplaintCubit>();

    final item = switch (source) {
      ComplaintMediaSource.camera =>
        await picker.pickComplaintPhoto(source: ImageSource.camera),
      ComplaintMediaSource.gallery =>
        await picker.pickComplaintPhoto(source: ImageSource.gallery),
      ComplaintMediaSource.video =>
        await picker.pickComplaintVideo(source: ImageSource.camera),
    };

    if (item != null) cubit.addMedia(item);
  }

  void _onStateChanged(BuildContext context, SubmitComplaintState state) {
    if (state.locationErrorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.locationErrorMessage!)));
    }

    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
    }

    if (state.submitted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              state.isEmergency
                  ? 'complaint_emergency_submitted_message'.tr()
                  : 'complaint_submitted_message'.tr(),
            ),
          ),
        );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.pageBackground,
      appBar: AppBar(
        backgroundColor: context.colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'complaint_new_title'.tr(),
          style: context.texts.f16W500Black.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<SubmitComplaintCubit, SubmitComplaintState>(
          listener: _onStateChanged,
          builder: (context, state) {
            final cubit = context.read<SubmitComplaintCubit>();

            if (_titleController.text != state.title) {
              _titleController.value = _titleController.value.copyWith(text: state.title);
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TypeCard(state: state, onChanged: cubit.typeChanged),
                        SizedBox(height: AppSpacing.sm.h),
                        _CategoryCard(state: state, onChanged: cubit.categoryChanged),
                        SizedBox(height: AppSpacing.sm.h),
                        _TitleDescCard(
                          state: state,
                          titleController: _titleController,
                          descController: _descController,
                          onTitleChanged: cubit.titleChanged,
                          onDescChanged: cubit.descriptionChanged,
                        ),
                        SizedBox(height: AppSpacing.sm.h),
                        _LocationCard(
                          state: state,
                          onUseLocation: cubit.useCurrentLocation,
                        ),
                        SizedBox(height: AppSpacing.sm.h),
                        _MediaCard(
                          state: state,
                          onAdd: () => _pickMedia(context),
                          onRemove: cubit.removeMediaAt,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  child: AppSubmitButton(
                    canSubmit: state.canSubmit,
                    isSubmitting: state.isSubmitting,
                    label: 'complaint_submit'.tr(),
                    submittingLabel: 'complaint_submitting'.tr(),
                    onPressed: cubit.submit,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: context.colors.infoBackground,
            borderRadius: BorderRadius.circular(AppRadius.sm.r),
          ),
          child: Icon(icon, size: 18.sp, color: context.colors.infoForeground),
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

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.state, required this.onChanged});

  final SubmitComplaintState state;
  final ValueChanged<ComplaintType> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(icon: Icons.tune_rounded, title: 'complaint_type_label'.tr()),
          SizedBox(height: AppSpacing.sm.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: context.colors.trackBackground,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                for (final type in ComplaintType.values)
                  Expanded(
                    child: InkWell(
                      onTap: () => onChanged(type),
                      borderRadius: BorderRadius.circular(8.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: EdgeInsets.symmetric(vertical: 9.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: state.type == type ? scheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              ComplaintStyle.type(context, type).icon,
                              size: 16.sp,
                              color: state.type == type
                                  ? scheme.onPrimary
                                  : context.colors.textSecondary,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              switch (type) {
                                ComplaintType.individual => 'complaint_type_individual'.tr(),
                                ComplaintType.collective => 'complaint_type_collective'.tr(),
                                ComplaintType.emergency => 'complaint_type_emergency'.tr(),
                              },
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: state.type == type
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: state.type == type
                                    ? scheme.onPrimary
                                    : context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (state.isEmergency) ...[
            SizedBox(height: AppSpacing.sm.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.md.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_rounded, size: 18.sp, color: scheme.error),
                  SizedBox(width: AppSpacing.xs.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'complaint_emergency_notice_title'.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: scheme.error,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'complaint_emergency_notice_body'.tr(),
                          style: TextStyle(fontSize: 12.sp, height: 1.6, color: scheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.state, required this.onChanged});

  final SubmitComplaintState state;
  final ValueChanged<ComplaintCategory> onChanged;

  static String _label(ComplaintCategory category) {
    return switch (category) {
      ComplaintCategory.roads => 'cat_roads'.tr(),
      ComplaintCategory.waste => 'cat_waste'.tr(),
      ComplaintCategory.lighting => 'cat_lighting'.tr(),
      ComplaintCategory.water => 'cat_water'.tr(),
      ComplaintCategory.publicServices => 'cat_public'.tr(),
      ComplaintCategory.other => 'cat_other'.tr(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;

    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(icon: Icons.category_rounded, title: 'complaint_category_label'.tr()),
          SizedBox(height: AppSpacing.sm.h),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 1.1,
            children: [
              for (final category in ComplaintCategory.values)
                _CategoryTile(
                  label: _label(category),
                  style: ComplaintStyle.category(context, category),
                  selected: state.category == category,
                  onTap: () => onChanged(category),
                  selectedColor: scheme.primary,
                  selectedSurface: colors.brandSurface,
                  border: colors.border,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.style,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
    required this.selectedSurface,
    required this.border,
  });

  final String label;
  final ComplaintStyle style;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color selectedSurface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? selectedColor : border, width: selected ? 1.5 : 1),
          color: selected ? selectedSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(color: style.background, borderRadius: BorderRadius.circular(10.r)),
              child: Icon(style.icon, size: 21.sp, color: style.foreground),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: selected ? selectedColor : context.colors.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleDescCard extends StatelessWidget {
  const _TitleDescCard({
    required this.state,
    required this.titleController,
    required this.descController,
    required this.onTitleChanged,
    required this.onDescChanged,
  });

  final SubmitComplaintState state;
  final TextEditingController titleController;
  final TextEditingController descController;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: 'complaint_title_label'.tr(),
            child: CustomTextFormField(
              controller: titleController,
              validationMessage: (_) => null,
              keyBoardType: TextInputType.text,
              hintText: 'complaint_title_hint'.tr(),
              onChanged: onTitleChanged,
              maxLength: 200,
              textInputAction: TextInputAction.next,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('complaint_desc_label'.tr(), style: context.texts.f14W600Black),
              SizedBox(width: 5.w),
              Text(
                state.isEmergency ? 'complaint_optional_mark'.tr() : 'required_mark'.tr(),
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: state.isEmergency ? context.colors.textHint : scheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          CustomTextFormField(
            controller: descController,
            validationMessage: (_) => null,
            keyBoardType: TextInputType.multiline,
            hintText: 'complaint_desc_hint'.tr(),
            onChanged: onDescChanged,
            maxLines: 4,
            minLines: 4,
            textInputAction: TextInputAction.newline,
          ),
          SizedBox(height: 6.h),
          Text(
            state.isEmergency
                ? 'complaint_desc_helper_optional'.tr()
                : 'complaint_desc_helper_required'.tr(),
            style: context.texts.f12W400SecColor,
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.state, required this.onUseLocation});

  final SubmitComplaintState state;
  final VoidCallback onUseLocation;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;

    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _CardHeader(
                  icon: Icons.location_on_rounded,
                  title: 'complaint_location_label'.tr(),
                ),
              ),
              Text(
                'required_mark'.tr(),
                style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w500, color: scheme.error),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          if (state.hasLocation)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: colors.brandSurface,
                border: Border.all(color: scheme.primary),
                borderRadius: BorderRadius.circular(AppRadius.md.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.my_location_rounded, size: 22.sp, color: scheme.primary),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Directionality(
                          textDirection: ui.TextDirection.ltr,
                          child: Text(
                            '${state.latitude!.toStringAsFixed(5)}, ${state.longitude!.toStringAsFixed(5)}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'complaint_location_accuracy'.tr(),
                          style: TextStyle(fontSize: 11.5.sp, color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: state.isLocating ? null : onUseLocation,
                    child: Text('complaint_location_retake'.tr()),
                  ),
                ],
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: state.isLocating ? null : onUseLocation,
              icon: state.isLocating
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary),
                    )
                  : Icon(Icons.my_location_rounded, size: 20.sp),
              label: Text('complaint_location_cta'.tr()),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
                side: BorderSide(color: scheme.primary, width: 1.5),
                foregroundColor: scheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md.r),
                ),
              ),
            ),
          SizedBox(height: 8.h),
          Text('complaint_location_helper'.tr(), style: context.texts.f12W400SecColor),
        ],
      ),
    );
  }
}

class _MediaCard extends StatelessWidget {
  const _MediaCard({required this.state, required this.onAdd, required this.onRemove});

  final SubmitComplaintState state;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _CardHeader(icon: Icons.perm_media_rounded, title: 'complaint_media_label'.tr()),
              ),
              Text(
                '${state.media.length} / ${SubmitComplaintState.maxMediaCount}',
                style: TextStyle(fontSize: 11.5.sp, color: context.colors.textHint),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          if (state.media.isEmpty)
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(AppRadius.md.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.border),
                  borderRadius: BorderRadius.circular(AppRadius.md.r),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 28.sp, color: context.scheme.primary),
                    SizedBox(height: 4.h),
                    Text(
                      'complaint_media_cta'.tr(),
                      style: TextStyle(fontSize: 12.sp, color: context.scheme.tertiary),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'complaint_media_hint'.tr(),
                      style: TextStyle(fontSize: 10.sp, color: context.colors.textHint),
                    ),
                  ],
                ),
              ),
            )
          else
            ComplaintMediaGrid(
              media: state.media,
              canAddMore: state.media.length < SubmitComplaintState.maxMediaCount,
              onAdd: onAdd,
              onRemove: onRemove,
            ),
        ],
      ),
    );
  }
}
