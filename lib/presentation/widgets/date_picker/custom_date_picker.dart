import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';
import 'package:tallee/data/dto/date_picker_range.dart';
import 'package:tallee/presentation/widgets/date_picker/date_picker_components.dart';

/// A custom date picker supporting single date and date range selection.
class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({
    super.key,
    this.selectionMode = DatePickerSelectionMode.single,
    this.initialSelectedDate,
    this.initialSelectedRange,
    this.minDate,
    this.maxDate,
    this.onDateSelected,
    this.onRangeSelected,
    this.onCancel,
  });

  final DatePickerSelectionMode selectionMode;
  final DateTime? initialSelectedDate;
  final DatePickerRange? initialSelectedRange;
  final DateTime? minDate;
  final DateTime? maxDate;

  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DatePickerRange>? onRangeSelected;
  final VoidCallback? onCancel;

  /// Shows a single-date or date-range picker dialog.
  static Future<T?> show<T>({
    required BuildContext context,
    DatePickerSelectionMode selectionMode = DatePickerSelectionMode.single,
    DateTime? initialDate,
    DatePickerRange? initialRange,
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    assert(
      (selectionMode == DatePickerSelectionMode.single && T == DateTime) ||
          (selectionMode == DatePickerSelectionMode.range &&
              T == List<DateTime?>),
      'The picker selection mode must match the return type.',
    );

    return showDialog<T>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: CustomDatePicker(
            selectionMode: selectionMode,
            initialSelectedDate: initialDate,
            initialSelectedRange: initialRange,
            minDate: minDate,
            maxDate: maxDate,
            onDateSelected: (value) => Navigator.pop<T>(context, value as T),
            onRangeSelected: (value) => Navigator.pop<T>(
              context,
              [value.startDate, value.endDate] as T,
            ),
            onCancel: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  static const defaultDateRangeYears = 20;

  late final PageController pageController;
  final ScrollController yearPickerController = ScrollController();
  late final DateTime firstMonth;
  late final DateTime lastMonth;
  late DateTime focusedMonth;

  DateTime? selectedDate;
  DatePickerRange? selectedRange;

  bool isYearPickerOpen = false;

  @override
  void initState() {
    super.initState();

    selectedDate = widget.initialSelectedDate;
    selectedRange = widget.initialSelectedRange;

    final now = clock.now();
    firstMonth = monthStart(
      widget.minDate ??
          DateTime(now.year - defaultDateRangeYears, now.month, now.day),
    );
    lastMonth = monthStart(
      widget.maxDate ??
          DateTime(now.year + defaultDateRangeYears, now.month, now.day),
    );
    assert(
      !lastMonth.isBefore(firstMonth),
      'maxDate must not be before minDate.',
    );
    assert(
      selectedDate == null || !isDateOutsideBounds(selectedDate!),
      'initialSelectedDate must be within minDate and maxDate.',
    );
    assert(
      selectedRange == null ||
          (selectedRange!.startDate == null ||
                  !isDateOutsideBounds(selectedRange!.startDate!)) &&
              (selectedRange!.endDate == null ||
                  !isDateOutsideBounds(selectedRange!.endDate!)),
      'initialSelectedRange must be within minDate and maxDate.',
    );

    DateTime focus;
    if (widget.selectionMode == DatePickerSelectionMode.single &&
        selectedDate != null) {
      focus = selectedDate!;
    } else if (widget.selectionMode == DatePickerSelectionMode.range &&
        selectedRange?.startDate != null) {
      focus = selectedRange!.startDate!;
    } else {
      focus = now;
    }
    focusedMonth = monthStart(focus);
    if (focusedMonth.isBefore(firstMonth)) {
      focusedMonth = firstMonth;
    } else if (focusedMonth.isAfter(lastMonth)) {
      focusedMonth = lastMonth;
    }
    pageController = PageController(initialPage: pageForMonth(focusedMonth));
  }

  @override
  void dispose() {
    pageController.dispose();
    yearPickerController.dispose();
    super.dispose();
  }

  DateTime monthForPage(int page) {
    return DateTime(firstMonth.year, firstMonth.month + page, 1);
  }

  int pageForMonth(DateTime month) {
    final monthDiff =
        (month.year - firstMonth.year) * 12 + (month.month - firstMonth.month);
    return monthDiff.clamp(0, monthCount - 1);
  }

  int get monthCount =>
      (lastMonth.year - firstMonth.year) * 12 +
      lastMonth.month -
      firstMonth.month +
      1;

  static DateTime monthStart(DateTime date) =>
      DateTime(date.year, date.month, 1);

  bool isDateOutsideBounds(DateTime date) {
    final day = dateOnly(date);
    return day.isBefore(dateOnly(widget.minDate ?? firstMonth)) ||
        day.isAfter(dateOnly(widget.maxDate ?? lastMonth));
  }

  void onPageChanged(int page) {
    setState(() {
      focusedMonth = monthForPage(page);
    });
  }

  void jumpToMonth(DateTime month) {
    final targetMonth = DateTime(month.year, month.month, 1);
    setState(() {
      focusedMonth = targetMonth;
      isYearPickerOpen = false;
    });
    final page = pageForMonth(targetMonth);
    pageController.jumpToPage(page);
  }

  void onDayTapped(DateTime date) {
    if (isDateDisabled(date)) return;

    HapticFeedback.lightImpact();

    setState(() {
      if (widget.selectionMode == DatePickerSelectionMode.single) {
        selectedDate = date;
      } else {
        final currentStart = selectedRange?.startDate;
        final currentEnd = selectedRange?.endDate;

        if (currentStart == null || currentEnd != null) {
          selectedRange = DatePickerRange(startDate: date, endDate: null);
        } else if (isBeforeDay(date, currentStart)) {
          selectedRange = DatePickerRange(startDate: date, endDate: null);
        } else {
          selectedRange = DatePickerRange(
            startDate: currentStart,
            endDate: date,
          );
        }
      }
    });
  }

  bool isDateDisabled(DateTime date) {
    final day = dateOnly(date);
    if (widget.minDate != null && day.isBefore(dateOnly(widget.minDate!))) {
      return true;
    }
    if (widget.maxDate != null && day.isAfter(dateOnly(widget.maxDate!))) {
      return true;
    }
    return false;
  }

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isBeforeDay(DateTime a, DateTime b) {
    return dateOnly(a).isBefore(dateOnly(b));
  }

  bool get isSubmitEnabled {
    if (widget.selectionMode == DatePickerSelectionMode.single) {
      return selectedDate != null;
    }
    return selectedRange?.isComplete ?? false;
  }

  void handleSubmit() {
    if (!isSubmitEnabled) return;
    HapticFeedback.lightImpact();
    if (widget.selectionMode == DatePickerSelectionMode.single) {
      widget.onDateSelected?.call(selectedDate!);
    } else {
      widget.onRangeSelected?.call(selectedRange!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeName = Localizations.localeOf(context).toString();

    return Container(
      width: 320,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.talleeColors.boxColor,
        borderRadius: AppColors.standardBorderRadiusAll,
        border: Border.all(color: context.talleeColors.boxBorderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DatePickerHeader(
            focusedMonth: focusedMonth,
            localeName: localeName,
            pageController: pageController,
            isYearPickerOpen: isYearPickerOpen,
            onToggleYearPicker: toggleYearPicker,
            canNavigatePrevious: focusedMonth.isAfter(firstMonth),
            canNavigateNext: focusedMonth.isBefore(lastMonth),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 270,
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: isYearPickerOpen
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: DatePickerCalendar(
                localeName: localeName,
                pageController: pageController,
                itemCount: monthCount,
                monthForPage: monthForPage,
                onPageChanged: onPageChanged,
                selectionMode: widget.selectionMode,
                selectedDate: selectedDate,
                selectedRange: selectedRange,
                isDateDisabled: isDateDisabled,
                onDayTapped: onDayTapped,
              ),
              secondChild: DatePickerYearPicker(
                controller: yearPickerController,
                focusedMonth: focusedMonth,
                minDate: widget.minDate,
                maxDate: widget.maxDate,
                onYearSelected: (year) =>
                    jumpToMonth(DateTime(year, focusedMonth.month, 1)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DatePickerActionButtons(
            isSubmitEnabled: isSubmitEnabled,
            onCancel: () {
              HapticFeedback.lightImpact();
              widget.onCancel?.call();
            },
            onSubmit: handleSubmit,
          ),
        ],
      ),
    );
  }

  void toggleYearPicker() {
    HapticFeedback.lightImpact();
    setState(() {
      isYearPickerOpen = !isYearPickerOpen;
    });
    if (isYearPickerOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        scrollYearPickerToFocusedYear();
      });
    }
  }

  void scrollYearPickerToFocusedYear() {
    final currentYear = clock.now().year;
    final startYear = widget.minDate?.year ?? (currentYear - 20);
    final yearIndex = focusedMonth.year - startYear;

    if (yearIndex < 0) return;

    final rowIndex = yearIndex ~/ 3;
    final renderObject = yearPickerController.position.context.storageContext
        .findRenderObject();
    if (renderObject is! RenderBox) return;

    final itemWidth = (renderObject.size.width - 16) / 3;
    final itemHeight = itemWidth / 2.2;
    final rowExtent = itemHeight + 8;
    final targetOffset =
        8 +
        rowIndex * rowExtent -
        (yearPickerController.position.viewportDimension - itemHeight) / 2;
    final maxOffset = yearPickerController.position.maxScrollExtent;
    yearPickerController.animateTo(
      targetOffset.clamp(0.0, maxOffset).toDouble(),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }
}
