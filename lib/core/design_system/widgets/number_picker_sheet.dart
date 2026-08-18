import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

/// كيف خرج المستخدم من الورقة.
enum _PickerExit {
  /// ضغط «تم» — تأكيد صريح، بيقبل حتى لو ما حرّك العجلة.
  done,

  /// ضغط «إلغاء» — رفض صريح.
  cancel,

  /// خرج بلا زر: نقرة برّا الورقة، رجوع النظام، أو سحبها للأسفل.
  dismiss,
}

/// عجلة اختيار رقم (يوم/شهر/سنة) بورقة سفلية.
///
/// **الخروج بلا زر بيقبل القيمة إذا تحرّكت العجلة فعلاً، وإلا ما بيغيّر
/// شي.** قاعدة وحدة بتغطي الحالتين: لو الحقل كان فيه قيمة وما تحرّكت
/// العجلة، «لا تغيير» = نفس القيمة القديمة؛ ولو كان فاضياً، بيضل فاضياً
/// بدل ما نخترع له تاريخاً ما اختاره.
///
/// **توحيد إيماءات الخروج** — الثلاثة بتوصل لنفس النتيجة رغم إنها
/// بتمرّ بمسارات مختلفة بـFlutter:
/// * نقرة برّا الورقة ورجوع النظام → `Navigator.maybePop` →
///   بيمسكها [PopScope] وبيرجّع [_PickerExit.dismiss].
/// * سحب الورقة للأسفل → `BottomSheet.onClosing` بينادي `Navigator.pop`
///   المباشر بلا قيمة (`bottom_sheet.dart`)، فبيتجاوز [PopScope]
///   وبيوصل `null` — منعامله كـ[_PickerExit.dismiss] كمان.
///
/// بترجّع `null` يعني «ما في تغيير» — إلغاء صريح أو خروج بلا تحريك.
Future<int?> showNumberPickerSheet({
  required BuildContext context,
  required String title,
  required List<int> values,
  required int initialValue,
  String Function(int value)? labelBuilder,
}) async {
  int initialIndex = values.indexOf(initialValue);

  if (initialIndex < 0) {
    initialIndex = 0;
  }

  // بتضل `null` لحد ما تتحرّك العجلة فعلاً — وهاد بالضبط اللي بيميّز
  // «خرج بلا ما يختار» عن «اختار». لازم تكون برّا الورقة لأن سحبها
  // للأسفل بيهدم حالتها قبل ما نقدر نقرأها.
  int? movedTo;

  final exit = await showModalBottomSheet<_PickerExit>(
    context: context,
    backgroundColor: context.scheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
    ),
    builder: (context) {
      return _NumberPickerSheet(
        title: title,
        values: values,
        initialIndex: initialIndex,
        labelBuilder: labelBuilder,
        onMoved: (value) => movedTo = value,
      );
    },
  );

  return switch (exit ?? _PickerExit.dismiss) {
    _PickerExit.cancel => null,
    _PickerExit.done => movedTo ?? values[initialIndex],
    _PickerExit.dismiss => movedTo,
  };
}

class _NumberPickerSheet extends StatefulWidget {
  const _NumberPickerSheet({
    required this.title,
    required this.values,
    required this.initialIndex,
    required this.labelBuilder,
    required this.onMoved,
  });

  final String title;
  final List<int> values;
  final int initialIndex;
  final String Function(int value)? labelBuilder;

  /// بتنادى أول ما تستقرّ العجلة على عنصر غير اللي بدأت عليه.
  final ValueChanged<int> onMoved;

  @override
  State<_NumberPickerSheet> createState() => _NumberPickerSheetState();
}

class _NumberPickerSheetState extends State<_NumberPickerSheet> {
  late final _scrollController = FixedExtentScrollController(
    initialItem: widget.initialIndex,
  );

  late int _selectedIndex = widget.initialIndex;

  static const double _itemExtent = 46;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<_PickerExit?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.of(context).pop(_PickerExit.dismiss);
      },
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 340.h,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_PickerExit.cancel),
                      child: Text(
                        'cancel'.tr(),
                        style: context.texts.f14W400HintColor,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: context.texts.f16W500Black.copyWith(
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_PickerExit.done),
                      child: Text(
                        'done'.tr(),
                        style: context.texts.f15W600Primary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1.h,
                thickness: 1.h,
                color: context.colors.border,
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ListWheelScrollView.useDelegate(
                      controller: _scrollController,
                      itemExtent: _itemExtent.h,
                      diameterRatio: 1.35,
                      perspective: 0.004,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() => _selectedIndex = index);
                        widget.onMoved(widget.values[index]);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: widget.values.length,
                        builder: (context, index) {
                          final value = widget.values[index];
                          final isSelected = index == _selectedIndex;
                          final label =
                              widget.labelBuilder?.call(value) ??
                              value.toString();

                          return Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeOut,
                              style: isSelected
                                  ? context.texts.f16W500Black.copyWith(
                                      fontSize: 21.sp,
                                      fontWeight: FontWeight.w700,
                                      color: context.scheme.primary,
                                    )
                                  : context.texts.f16W500Black.copyWith(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w400,
                                      color: context.colors.textHint,
                                    ),
                              child: Text(label),
                            ),
                          );
                        },
                      ),
                    ),

                    // شريط بيؤطّر الصف الأوسط — بيثبّت للعين وين «القيمة
                    // المختارة الآن» بغضّ النظر عن سرعة السحب، بدل ما
                    // تعتمد لحالها على حجم/لون النص وهو لسه بيتحرّك.
                    IgnorePointer(
                      child: Container(
                        height: _itemExtent.h,
                        margin: EdgeInsets.symmetric(horizontal: 28.w),
                        decoration: BoxDecoration(
                          color: context.colors.brandSurface,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),

                    // تعتيم تدريجي أعلى وأسفل العجلة — بيوحي إنها تلف
                    // وبيسحب الانتباه لمنتصفها.
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              context.scheme.surface,
                              context.scheme.surface.withValues(alpha: 0),
                              context.scheme.surface.withValues(alpha: 0),
                              context.scheme.surface,
                            ],
                            stops: const [0, 0.32, 0.68, 1],
                          ),
                        ),
                      ),
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
