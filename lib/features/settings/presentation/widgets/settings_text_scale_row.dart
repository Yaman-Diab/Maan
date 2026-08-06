// -------------------------
// Settings Text Scale Row
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_theme_context.dart';
import '../../../../core/settings/cubit/settings_state.dart';

/// أربع خانات A- / A / A+ / A++ — كل واحدة بحجم خطها الفعلي، فالفرق
/// محسوس قبل ما تُختار.
class SettingsTextScaleRow extends StatelessWidget {
  const SettingsTextScaleRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AppTextScale selected;
  final ValueChanged<AppTextScale> onChanged;

  /// ⚠️ استثناء واعٍ من «كل نص عبر .tr()» — هاي رموز طباعية («عيّنة
  /// حجم الخط») لا كلمات بلغة، ونفس الاصطلاح بإعدادات iOS/Android
  /// حتى بالواجهة العربية. حارس الترجمة (`localization_test.dart`)
  /// بيفحص العربي المكتوب يدوياً بس، فما بيوقّع عليها.
  static const _labels = {
    AppTextScale.small: 'A-',
    AppTextScale.normal: 'A',
    AppTextScale.large: 'A+',
    AppTextScale.extraLarge: 'A++',
  };

  static const _fontSizes = {
    AppTextScale.small: 11.0,
    AppTextScale.normal: 13.5,
    AppTextScale.large: 16.0,
    AppTextScale.extraLarge: 18.5,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final scale in AppTextScale.values) ...[
          if (scale != AppTextScale.values.first) SizedBox(width: 8.w),
          _Chip(
            label: _labels[scale]!,
            fontSize: _fontSizes[scale]!,
            isSelected: scale == selected,
            onTap: () => onChanged(scale),
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.fontSize,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final double fontSize;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 44.w,
        height: 44.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? scheme.primary : colors.border,
            width: 1.5.w,
          ),
          color: isSelected ? colors.brandSurface : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? scheme.primary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
