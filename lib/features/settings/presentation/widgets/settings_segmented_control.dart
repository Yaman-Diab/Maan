// -------------------------
// Settings Segmented Control
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_theme_context.dart';

final class SettingsSegmentedOption<T> {
  final T value;
  final String label;

  const SettingsSegmentedOption({required this.value, required this.label});
}

/// عنصر تحكّم مقسّم — لشاشة الإعدادات بس (الثيم، اللغة).
///
/// [trackBackground] هو نفس توكن مسار شريط التقدّم الفاضي
/// (`AppSemanticColors.trackBackground`) — إعادة استخدام مقصودة، لأن
/// القيمتين متطابقتان بالتصميم بالثيمين الفاتح والداكن.
class SettingsSegmentedControl<T> extends StatelessWidget {
  const SettingsSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<SettingsSegmentedOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colors.trackBackground,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            _Segment(
              label: option.label,
              isSelected: option.value == selected,
              selectedColor: scheme.primary,
              onSelectedColor: scheme.onPrimary,
              unselectedColor: colors.textSecondary,
              onTap: () => onChanged(option.value),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onSelectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color onSelectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: context.texts.f12W400SecColor.copyWith(
            fontSize: 12.5.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? onSelectedColor : unselectedColor,
          ),
        ),
      ),
    );
  }
}
