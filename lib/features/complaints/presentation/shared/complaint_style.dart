// -------------------------
// Complaint Style
// -------------------------

import 'package:flutter/material.dart';

import '../../../../core/design_system/app_theme_context.dart';
import '../../domain/entities/complaint_category.dart';
import '../../domain/entities/complaint_status.dart';
import '../../domain/entities/complaint_type.dart';

/// أيقونة/لون كل قيمة نوع · تصنيف · حالة — مصدر واحد بدل تكرار
/// `switch` باللائحة والتفاصيل ونموذج التقديم.
class ComplaintStyle {
  const ComplaintStyle({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  static ComplaintStyle type(BuildContext context, ComplaintType type) {
    final colors = context.colors;
    final scheme = context.scheme;

    return switch (type) {
      ComplaintType.individual => ComplaintStyle(
        icon: Icons.person_rounded,
        background: colors.fieldDisabledBackground,
        foreground: colors.textSecondary,
      ),
      ComplaintType.collective => ComplaintStyle(
        icon: Icons.groups_rounded,
        background: colors.infoBackground,
        foreground: colors.infoForeground,
      ),
      ComplaintType.emergency => ComplaintStyle(
        icon: Icons.warning_rounded,
        background: scheme.errorContainer,
        foreground: scheme.error,
      ),
    };
  }

  static ComplaintStyle status(BuildContext context, ComplaintStatus status) {
    final colors = context.colors;

    return switch (status) {
      ComplaintStatus.underReview => ComplaintStyle(
        icon: Icons.schedule_rounded,
        background: colors.noticeBackground,
        foreground: colors.noticeForeground,
      ),
      ComplaintStatus.inProgress => ComplaintStyle(
        icon: Icons.autorenew_rounded,
        background: colors.infoBackground,
        foreground: colors.infoForeground,
      ),
      ComplaintStatus.closed => ComplaintStyle(
        icon: Icons.check_circle_rounded,
        background: colors.successSurface,
        foreground: colors.success,
      ),
      ComplaintStatus.unknown => ComplaintStyle(
        icon: Icons.help_outline_rounded,
        background: colors.fieldDisabledBackground,
        foreground: colors.textSecondary,
      ),
    };
  }

  static ComplaintStyle category(
    BuildContext context,
    ComplaintCategory category,
  ) {
    final colors = context.colors;
    final scheme = context.scheme;

    return switch (category) {
      ComplaintCategory.roads => ComplaintStyle(
        icon: Icons.edit_road_rounded,
        background: colors.noticeBackground,
        foreground: scheme.tertiary,
      ),
      ComplaintCategory.waste => ComplaintStyle(
        icon: Icons.delete_rounded,
        background: colors.successSurface,
        foreground: colors.success,
      ),
      ComplaintCategory.lighting => ComplaintStyle(
        icon: Icons.lightbulb_rounded,
        background: colors.noticeBackground,
        foreground: colors.noticeForeground,
      ),
      ComplaintCategory.water => ComplaintStyle(
        icon: Icons.water_drop_rounded,
        background: colors.infoBackground,
        foreground: colors.infoForeground,
      ),
      ComplaintCategory.publicServices => ComplaintStyle(
        icon: Icons.apartment_rounded,
        background: colors.brandSurface,
        foreground: scheme.primary,
      ),
      ComplaintCategory.other => ComplaintStyle(
        icon: Icons.more_horiz_rounded,
        background: colors.fieldDisabledBackground,
        foreground: colors.textSecondary,
      ),
    };
  }
}
