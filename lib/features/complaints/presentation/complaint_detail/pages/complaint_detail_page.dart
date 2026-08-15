// -------------------------
// Complaint Detail Page
// -------------------------

import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_card.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../domain/entities/complaint.dart';
import '../../../domain/entities/complaint_status.dart';
import '../../../domain/usecases/unvote_complaint_usecase.dart';
import '../../../domain/usecases/vote_complaint_usecase.dart';
import '../../shared/complaint_style.dart';
import '../widgets/complaint_report_sheet.dart';

/// تفاصيل شكوى — الكيان بيوصل جاهزاً عبر `extra` بدل استعلام جديد،
/// القائمة أصلاً عندها البيانات (نفس منطق `editIdentity`). التصويت
/// هون محلي (بلا مزامنة مباشرة مع `ComplaintsCubit`) — القائمة بتعيد
/// التحميل لما ترجع، فبتاخد الرقم الصحيح من السيرفر بدل تعقيد مشاركة
/// حالة بين شاشتين.
class ComplaintDetailPage extends StatefulWidget {
  const ComplaintDetailPage({super.key, required this.complaint, required this.canVote});

  final Complaint complaint;
  final bool canVote;

  @override
  State<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  late Complaint _complaint = widget.complaint;
  bool _voting = false;

  Future<void> _toggleVote() async {
    if (_voting) return;

    if (!widget.canVote) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('complaint_vote_locked'.tr())));
      return;
    }

    setState(() => _voting = true);

    final wasVoted = _complaint.hasVoted;
    final result = wasVoted
        ? await sl<UnvoteComplaintUseCase>()(_complaint.id)
        : await sl<VoteComplaintUseCase>()(_complaint.id);

    if (!mounted) return;

    setState(() {
      _voting = false;
      if (result.isOk) {
        _complaint = _complaint.copyWith(
          hasVoted: !wasVoted,
          votes: _complaint.votes + (wasVoted ? -1 : 1),
        );
      }
    });
  }

  Future<void> _openReport() async {
    final sent = await showComplaintReportSheet(context, complaintId: _complaint.id);

    if (sent && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('report_submitted_message'.tr())));
    }
  }

  static String _statusLabel(ComplaintStatus status) {
    return switch (status) {
      ComplaintStatus.underReview => 'complaint_status_under_review'.tr(),
      ComplaintStatus.inProgress => 'complaint_status_in_progress'.tr(),
      ComplaintStatus.closed => 'complaint_status_closed'.tr(),
      ComplaintStatus.unknown => 'complaint_status_under_review'.tr(),
    };
  }

  static String _typeLabel(Complaint complaint) {
    return switch (complaint.type) {
      final t when t.wireValue == 'individual' => 'complaint_type_individual'.tr(),
      final t when t.wireValue == 'collective' => 'complaint_type_collective'.tr(),
      _ => 'complaint_type_emergency'.tr(),
    };
  }

  static String _categoryLabel(Complaint complaint) {
    final category = complaint.category;
    if (category == null) return 'cat_other'.tr();

    return switch (category.id) {
      1 => 'cat_roads'.tr(),
      2 => 'cat_waste'.tr(),
      3 => 'cat_lighting'.tr(),
      4 => 'cat_water'.tr(),
      5 => 'cat_public'.tr(),
      _ => 'cat_other'.tr(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;
    final typeStyle = ComplaintStyle.type(context, _complaint.type);
    final statusStyle = ComplaintStyle.status(context, _complaint.status);
    final categoryStyle = _complaint.category == null
        ? null
        : ComplaintStyle.category(context, _complaint.category!);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'complaint_details_title'.tr(),
          style: context.texts.f16W500Black.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _complaint.hasMedia
                      ? colors.fieldDisabledBackground
                      : (categoryStyle?.background ?? colors.fieldDisabledBackground),
                  border: Border(bottom: BorderSide(color: colors.divider)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _complaint.hasMedia
                          ? Icons.image_rounded
                          : (categoryStyle?.icon ?? Icons.campaign_rounded),
                      size: _complaint.hasMedia ? 34.sp : 56.sp,
                      color: _complaint.hasMedia
                          ? colors.textHint
                          : (categoryStyle?.foreground ?? colors.textSecondary),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      _complaint.hasMedia
                          ? 'photo_placeholder'.tr()
                          : 'no_media_placeholder'.tr(),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11.sp,
                        color: colors.textHint,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _complaint.title,
                      style: context.texts.f16W500Black.copyWith(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: [
                        _Chip(
                          icon: typeStyle.icon,
                          label: _typeLabel(_complaint),
                          background: typeStyle.background,
                          foreground: typeStyle.foreground,
                        ),
                        _Chip(
                          icon: statusStyle.icon,
                          label: _statusLabel(_complaint.status),
                          background: statusStyle.background,
                          foreground: statusStyle.foreground,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    AppCard(
                      padding: EdgeInsets.all(AppSpacing.md.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('complaint_info_section'.tr(), style: context.texts.f14W600Black),
                          SizedBox(height: AppSpacing.sm.h),
                          Container(height: 1, color: colors.divider),
                          SizedBox(height: AppSpacing.sm.h),
                          _InfoRow(label: 'complaint_row_category'.tr(), value: _categoryLabel(_complaint)),
                          if (_complaint.latitude != null && _complaint.longitude != null)
                            _InfoRow(
                              label: 'complaint_row_location'.tr(),
                              value:
                                  '${_complaint.latitude!.toStringAsFixed(4)}, ${_complaint.longitude!.toStringAsFixed(4)}',
                              mono: true,
                            ),
                          if (_complaint.createdAt != null)
                            _InfoRow(
                              label: 'complaint_row_submitted_at'.tr(),
                              value: _complaint.createdAt!.toLocal().toString().split(' ').first,
                              mono: true,
                            ),
                          _InfoRow(label: 'complaint_row_id'.tr(), value: '#${_complaint.id}', mono: true),
                        ],
                      ),
                    ),
                    if (_complaint.description != null && _complaint.description!.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.sm.h),
                      AppCard(
                        padding: EdgeInsets.all(AppSpacing.md.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('complaint_desc_section'.tr(), style: context.texts.f14W600Black),
                            SizedBox(height: 8.h),
                            Text(
                              _complaint.description!,
                              style: context.texts.f14W400HintColor.copyWith(
                                color: colors.textPrimary,
                                height: 1.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: AppSpacing.sm.h),
                    Row(
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: widget.canVote ? 1 : 0.45,
                            child: InkWell(
                              onTap: _toggleVote,
                              borderRadius: BorderRadius.circular(AppRadius.md.r),
                              child: Container(
                                height: 48.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _complaint.hasVoted ? scheme.primary : Colors.transparent,
                                  border: Border.all(color: scheme.primary, width: 1.5),
                                  borderRadius: BorderRadius.circular(AppRadius.md.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 20.sp,
                                      color: _complaint.hasVoted ? scheme.onPrimary : scheme.primary,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '${_complaint.votes}',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _complaint.hasVoted ? scheme.onPrimary : scheme.primary,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'complaint_vote_label'.tr(),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: (_complaint.hasVoted ? scheme.onPrimary : scheme.primary)
                                            .withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        SizedBox(
                          height: 48.h,
                          child: OutlinedButton.icon(
                            onPressed: _openReport,
                            icon: Icon(Icons.flag_outlined, size: 19.sp),
                            label: Text('complaint_report_action'.tr()),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.textSecondary,
                              side: BorderSide(color: colors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(24.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: foreground),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w600, color: foreground),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: context.texts.f12W400SecColor),
          ),
          Flexible(
            child: Directionality(
              textDirection: mono ? ui.TextDirection.ltr : Directionality.of(context),
              child: Text(
                value,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: mono
                    ? TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                      )
                    : context.texts.f14W600Black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
