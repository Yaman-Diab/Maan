// -------------------------
// Skill Style
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/design_system/app_theme_context.dart';
import '../../domain/entities/certificate_rejection_reason.dart';
import '../../domain/entities/certificate_status.dart';
import '../../domain/entities/skill_type.dart';

/// أيقونة/لون كل نوع مهارة · حالة شهادة · سبب رفض — مصدر واحد بدل
/// تكرار `switch` بالبطاقة والتفاصيل والنموذج. نفس نمط
/// `ComplaintStyle` بميزة الشكاوى.
class SkillStyle {
  const SkillStyle({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.label,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final String label;

  static SkillStyle type(BuildContext context, SkillType type) {
    final colors = context.colors;
    final scheme = context.scheme;

    final (icon, label) = switch (type) {
      SkillType.technical => (
        Icons.memory_rounded,
        'skill_type_technical'.tr(),
      ),
      SkillType.craftsmanship => (
        Icons.handyman_rounded,
        'skill_type_craftsmanship'.tr(),
      ),
      SkillType.construction => (
        Icons.engineering_rounded,
        'skill_type_construction'.tr(),
      ),
      SkillType.social => (Icons.groups_rounded, 'skill_type_social'.tr()),
      SkillType.educational => (
        Icons.school_rounded,
        'skill_type_educational'.tr(),
      ),
      SkillType.medical => (
        Icons.medical_services_rounded,
        'skill_type_medical'.tr(),
      ),
      SkillType.driving => (
        Icons.local_shipping_rounded,
        'skill_type_driving'.tr(),
      ),
      SkillType.logistics => (
        Icons.inventory_2_rounded,
        'skill_type_logistics'.tr(),
      ),
      SkillType.environmental => (
        Icons.eco_rounded,
        'skill_type_environmental'.tr(),
      ),
      SkillType.other => (Icons.more_horiz_rounded, 'skill_type_other'.tr()),
    };

    final (bg, fg) = switch (type) {
      SkillType.technical ||
      SkillType.educational => (colors.brandSurface, scheme.primary),
      SkillType.craftsmanship || SkillType.construction => (
        colors.noticeBackground,
        colors.noticeForeground,
      ),
      SkillType.social ||
      SkillType.logistics => (colors.infoBackground, colors.infoForeground),
      SkillType.medical ||
      SkillType.environmental => (colors.successSurface, colors.success),
      SkillType.driving ||
      SkillType.other => (colors.fieldDisabledBackground, colors.textSecondary),
    };

    return SkillStyle(icon: icon, background: bg, foreground: fg, label: label);
  }

  /// `status == null` يعني مهارة بلا شهادة (معلَنة ذاتياً).
  static SkillStyle status(BuildContext context, CertificateStatus? status) {
    final colors = context.colors;
    final scheme = context.scheme;

    return switch (status) {
      CertificateStatus.approved => SkillStyle(
        icon: Icons.check_circle_rounded,
        background: colors.successSurface,
        foreground: colors.success,
        label: 'certificate_status_approved'.tr(),
      ),
      CertificateStatus.pending => SkillStyle(
        icon: Icons.schedule_rounded,
        background: colors.noticeBackground,
        foreground: colors.noticeForeground,
        label: 'certificate_status_pending'.tr(),
      ),
      CertificateStatus.rejected => SkillStyle(
        icon: Icons.error_rounded,
        background: scheme.errorContainer,
        foreground: scheme.error,
        label: 'certificate_status_rejected'.tr(),
      ),
      CertificateStatus.unknown || null => SkillStyle(
        icon: Icons.person_rounded,
        background: colors.fieldDisabledBackground,
        foreground: colors.textSecondary,
        label: 'certificate_status_self_declared'.tr(),
      ),
    };
  }

  static ({IconData icon, String label, String text}) rejectionReason(
    CertificateRejectionReason reason,
  ) {
    return switch (reason) {
      CertificateRejectionReason.fakeDocument => (
        icon: Icons.gpp_bad_rounded,
        label: 'certificate_reason_fake_document_label'.tr(),
        text: 'certificate_reason_fake_document_text'.tr(),
      ),
      CertificateRejectionReason.expiredDocument => (
        icon: Icons.event_busy_rounded,
        label: 'certificate_reason_expired_document_label'.tr(),
        text: 'certificate_reason_expired_document_text'.tr(),
      ),
      CertificateRejectionReason.invalidDocument => (
        icon: Icons.block_rounded,
        label: 'certificate_reason_invalid_document_label'.tr(),
        text: 'certificate_reason_invalid_document_text'.tr(),
      ),
      CertificateRejectionReason.blurryImage => (
        icon: Icons.blur_on_rounded,
        label: 'certificate_reason_blurry_image_label'.tr(),
        text: 'certificate_reason_blurry_image_text'.tr(),
      ),
      CertificateRejectionReason.nameMismatch => (
        icon: Icons.person_off_rounded,
        label: 'certificate_reason_name_mismatch_label'.tr(),
        text: 'certificate_reason_name_mismatch_text'.tr(),
      ),
      CertificateRejectionReason.issuerUnverifiable => (
        icon: Icons.domain_disabled_rounded,
        label: 'certificate_reason_issuer_unverifiable_label'.tr(),
        text: 'certificate_reason_issuer_unverifiable_text'.tr(),
      ),
      CertificateRejectionReason.missingInformation => (
        icon: Icons.help_rounded,
        label: 'certificate_reason_missing_information_label'.tr(),
        text: 'certificate_reason_missing_information_text'.tr(),
      ),
      CertificateRejectionReason.other => (
        icon: Icons.more_horiz_rounded,
        label: 'certificate_reason_other_label'.tr(),
        text: 'certificate_reason_other_text'.tr(),
      ),
    };
  }
}
