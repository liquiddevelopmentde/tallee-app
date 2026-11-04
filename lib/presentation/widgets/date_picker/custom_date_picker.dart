import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';
import 'package:tallee/data/dto/date_picker_range.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/custom_text_button.dart';

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

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  static const int initialPage = 1200;

  late final PageController pageController;
  final ScrollController yearPickerController = ScrollController();
  late final DateTime initialMonth;
  late DateTime focusedMonth;

  DateTime? selectedDate;
  DatePickerRange? selectedRange;

  bool isYearPickerOpen = false;

  @override
  void initState() {
    super.initState();

    selectedDate = widget.initialSelectedDate;
    selectedRange = widget.initialSelectedRange;

    DateTime focus;
    if (widget.selectionMode == DatePickerSelectionMode.single &&
        selectedDate != null) {
      focus = selectedDate!;
    } else if (widget.selectionMode == DatePickerSelectionMode.range &&
        selectedRange?.startDate != null) {
      focus = selectedRange!.startDate!;
    } else {
      focus = clock.now();
    }

    focusedMonth = DateTime(focus.year, focus.month, 1);
    initialMonth = focusedMonth;
    pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    pageController.dispose();
    yearPickerController.dispose();
    super.dispose();
  }

  DateTime monthForPage(int page) {
    final offset = page - initialPage;
    return DateTime(initialMonth.year, initialMonth.month + offset, 1);
  }

  int pageForMonth(DateTime month) {
    final monthDiff =
        (month.year - initialMonth.year) * 12 +
        (month.month - initialMonth.month);
    return initialPage + monthDiff;
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

  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

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
    final loc = AppLocalizations.of(context);
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
          buildHeader(context, localeName),
          const SizedBox(height: 12),
          SizedBox(
            height: 270,
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: isYearPickerOpen
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: buildCalendarView(context, localeName),
              secondChild: buildYearPickerView(context),
            ),
          ),
          const SizedBox(height: 12),
          buildActionButtons(context, loc),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context, String localeName) {
    final monthYearStr = DateFormat.yMMMM(localeName).format(focusedMonth);

    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            pageController.previousPage(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.chevron_left_rounded,
              color: context.talleeColors.textColor,
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
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
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      monthYearStr,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: context.talleeColors.textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: isYearPickerOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: context.talleeColors.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            pageController.nextPage(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.chevron_right_rounded,
              color: context.talleeColors.textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCalendarView(BuildContext context, String localeName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildWeekdayHeader(context, localeName),
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemBuilder: (context, page) {
              final month = monthForPage(page);
              return buildMonthGrid(context, month);
            },
          ),
        ),
      ],
    );
  }

  Widget buildWeekdayHeader(BuildContext context, String localeName) {
    final monday = DateTime(2026, 1, 5); // Known Monday
    final weekdays = <String>[];
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      weekdays.add(DateFormat.E(localeName).format(day));
    }

    return Row(
      children: weekdays.map((dayName) {
        return Expanded(
          child: Center(
            child: Text(
              dayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.talleeColors.hintColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildMonthGrid(BuildContext context, DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final weekdayOfFirst = firstDayOfMonth.weekday;
    final leadingDays = (weekdayOfFirst - 1) % 7;
    final gridStartDate = firstDayOfMonth.subtract(Duration(days: leadingDays));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(6, (rowIndex) {
        return Expanded(
          child: Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final cellDate = gridStartDate.add(Duration(days: cellIndex));
              return Expanded(
                child: buildDayCell(
                  context: context,
                  cellDate: cellDate,
                  month: month,
                  colIndex: colIndex,
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget buildDayCell({
    required BuildContext context,
    required DateTime cellDate,
    required DateTime month,
    required int colIndex,
  }) {
    final isCurrentMonth =
        cellDate.year == month.year && cellDate.month == month.month;
    final isDisabled = !isCurrentMonth || isDateDisabled(cellDate);
    final isToday = isSameDay(cellDate, clock.now());

    bool isSelected = false;
    bool isStart = false;
    bool isEnd = false;
    bool isInRange = false;

    if (widget.selectionMode == DatePickerSelectionMode.single) {
      isSelected = isCurrentMonth && isSameDay(cellDate, selectedDate);
    } else {
      final start = selectedRange?.startDate;
      final end = selectedRange?.endDate;

      isStart = isCurrentMonth && start != null && isSameDay(cellDate, start);
      isEnd = isCurrentMonth && end != null && isSameDay(cellDate, end);

      if (start != null && end != null) {
        final day = dateOnly(cellDate);
        final startDay = dateOnly(start);
        final endDay = dateOnly(end);
        isInRange =
            isCurrentMonth && day.isAfter(startDay) && day.isBefore(endDay);
      }
    }

    final hasRangeActive =
        widget.selectionMode == DatePickerSelectionMode.range &&
        selectedRange?.startDate != null;

    Color textColor;
    if (isDisabled) {
      textColor = context.talleeColors.hintColor.withAlpha(70);
    } else if (isSelected || isStart || isEnd) {
      textColor = Colors.white;
    } else if (!isCurrentMonth) {
      textColor = context.talleeColors.hintColor.withAlpha(120);
    } else {
      textColor = context.talleeColors.textColor;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isDisabled ? null : () => onDayTapped(cellDate),
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          if (hasRangeActive)
            buildRangeSpanDecoration(
              colIndex: colIndex,
              isStart: isStart,
              isEnd: isEnd,
              isInRange: isInRange,
              hasEndSelected: selectedRange?.endDate != null,
            ),

          if (isSelected || isStart || isEnd)
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            ),

          SizedBox(
            width: 34,
            height: 34,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${cellDate.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: (isSelected || isStart || isEnd || isToday)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: textColor,
                  ),
                ),
                if (isToday && !isSelected && !isStart && !isEnd)
                  const Positioned(
                    bottom: 1,
                    child: SizedBox(
                      width: 4,
                      height: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRangeSpanDecoration({
    required int colIndex,
    required bool isStart,
    required bool isEnd,
    required bool isInRange,
    required bool hasEndSelected,
  }) {
    if (!hasEndSelected && !isStart) {
      return const SizedBox.shrink();
    }

    final rangeColor = AppColors.primaryColor.withAlpha(45);

    if (isInRange) {
      BorderRadius borderRadius = BorderRadius.zero;
      if (colIndex == 0) {
        borderRadius = const BorderRadius.horizontal(left: Radius.circular(17));
      } else if (colIndex == 6) {
        borderRadius = const BorderRadius.horizontal(
          right: Radius.circular(17),
        );
      }
      return Positioned.fill(
        child: Center(
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Container(
              width: double.infinity,
              height: 34,
              color: rangeColor,
            ),
          ),
        ),
      );
    }

    if (isStart && isEnd) {
      return const SizedBox.shrink();
    }

    if (isStart && hasEndSelected) {
      if (colIndex == 6) {
        return const SizedBox.shrink();
      }
      return Positioned.fill(
        child: Center(
          child: SizedBox(
            height: 34,
            width: double.infinity,
            child: Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                Expanded(child: Container(color: rangeColor)),
              ],
            ),
          ),
        ),
      );
    }

    if (isEnd && hasEndSelected) {
      if (colIndex == 0) {
        return const SizedBox.shrink();
      }
      return Positioned.fill(
        child: Center(
          child: SizedBox(
            height: 34,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(child: Container(color: rangeColor)),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget buildYearPickerView(BuildContext context) {
    final currentYear = clock.now().year;
    final startYear = widget.minDate?.year ?? (currentYear - 20);
    final endYear = widget.maxDate?.year ?? (currentYear + 20);
    final years = List.generate(endYear - startYear + 1, (i) => startYear + i);

    return SizedBox(
      height: 270,
      child: GridView.builder(
        controller: yearPickerController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          final isSelected = year == focusedMonth.year;
          final isCurrentYear = year == currentYear;

          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              HapticFeedback.lightImpact();
              jumpToMonth(DateTime(year, focusedMonth.month, 1));
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : context.talleeColors.onBoxColor,
                borderRadius: BorderRadius.circular(10),
                border: isCurrentYear && !isSelected
                    ? Border.all(color: AppColors.primaryColor)
                    : null,
              ),
              child: Text(
                '$year',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected || isCurrentYear
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : context.talleeColors.textColor,
                ),
              ),
            ),
          );
        },
      ),
    );
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

  Widget buildActionButtons(BuildContext context, AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomTextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            widget.onCancel?.call();
          },
          text: loc.cancel,
          style: TextStyle(
            color: context.talleeColors.hintColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        CustomTextButton(
          onPressed: isSubmitEnabled ? handleSubmit : null,
          text: loc.confirm,
          style: TextStyle(
            color: isSubmitEnabled
                ? AppColors.primaryColor
                : context.talleeColors.hintColor.withAlpha(100),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Helper function to display a single date picker in a dialog.
Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? minDate,
  DateTime? maxDate,
}) async {
  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: CustomDatePicker(
          selectionMode: DatePickerSelectionMode.single,
          initialSelectedDate: initialDate,
          minDate: minDate,
          maxDate: maxDate,
          onDateSelected: (value) => Navigator.pop(context, value),
          onCancel: () => Navigator.pop(context),
        ),
      );
    },
  );
}

/// Helper function to display a date range picker in a dialog.
Future<List<DateTime?>?> showCustomDateRangePicker({
  required BuildContext context,
  DateTime? initialStartDate,
  DateTime? initialEndDate,
  DateTime? minDate,
  DateTime? maxDate,
}) async {
  return showDialog<List<DateTime?>>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: CustomDatePicker(
          selectionMode: DatePickerSelectionMode.range,
          initialSelectedRange:
              initialStartDate != null || initialEndDate != null
              ? DatePickerRange(
                  startDate: initialStartDate,
                  endDate: initialEndDate,
                )
              : null,
          minDate: minDate,
          maxDate: maxDate,
          onRangeSelected: (value) =>
              Navigator.pop(context, [value.startDate, value.endDate]),
          onCancel: () => Navigator.pop(context),
        ),
      );
    },
  );
}
