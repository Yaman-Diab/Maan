// -------------------------
// Profile Icon Chip
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أيقونة داخل مربّع ملوّن — بتتكرر ببطاقات المؤشرات وبطاقات النشاط.
class ProfileIconChip extends StatelessWidget {
  const ProfileIconChip({
    super.key,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.boxSize,
    required this.iconSize,
    required this.radius,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
  final double boxSize;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boxSize.w,
      height: boxSize.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: Icon(icon, size: iconSize.sp, color: foreground),
    );
  }
}
