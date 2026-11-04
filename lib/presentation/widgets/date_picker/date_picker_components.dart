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

class DatePickerHeader extends StatelessWidget {
  const DatePickerHeader({
    super.key,
    required this.focusedMonth,
    required this.localeName,
    required this.pageController,
    required this.isYearPickerOpen,
    required this.onToggleYearPicker,
  });

  final DateTime focusedMonth;
  final String localeName;
  final PageController pageController;
  final bool isYearPickerOpen;
  final VoidCallback onToggleYearPicker;

  @override
  Widget build(BuildContext context) {
    final monthYear = DateFormat.yMMMM(localeName).format(focusedMonth);
    return Row(
      children: [
        _DatePickerNavigationButton(
          icon: Icons.chevron_left_rounded,
          onTap: () => pageController.previousPage(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
          ),
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onToggleYearPicker,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      monthYear,
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
                    turns: isYearPickerOpen ? 0.5 : 0,
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
        _DatePickerNavigationButton(
          icon: Icons.chevron_right_rounded,
          onTap: () => pageController.nextPage(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
          ),
        ),
      ],
    );
  }
}

class _DatePickerNavigationButton extends StatelessWidget {
  const _DatePickerNavigationButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: context.talleeColors.textColor),
      ),
    );
  }
}

class DatePickerCalendar extends StatelessWidget {
  const DatePickerCalendar({
    super.key,
    required this.localeName,
    required this.pageController,
    required this.itemCount,
    required this.monthForPage,
    required this.onPageChanged,
    required this.selectionMode,
    required this.selectedDate,
    required this.selectedRange,
    required this.isDateDisabled,
    required this.onDayTapped,
  });

  final String localeName;
  final PageController pageController;
  final int itemCount;
  final DateTime Function(int page) monthForPage;
  final ValueChanged<int> onPageChanged;
  final DatePickerSelectionMode selectionMode;
  final DateTime? selectedDate;
  final DatePickerRange? selectedRange;
  final bool Function(DateTime date) isDateDisabled;
  final ValueChanged<DateTime> onDayTapped;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WeekdayHeader(localeName: localeName),
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: pageController,
            itemCount: itemCount,
            onPageChanged: onPageChanged,
            itemBuilder: (context, page) => _MonthGrid(
              month: monthForPage(page),
              selectionMode: selectionMode,
              selectedDate: selectedDate,
              selectedRange: selectedRange,
              isDateDisabled: isDateDisabled,
              onDayTapped: onDayTapped,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.localeName});

  final String localeName;

  @override
  Widget build(BuildContext context) {
    final monday = DateTime(2026, 1, 5);
    final weekdays = List.generate(
      7,
      (index) =>
          DateFormat.E(localeName).format(monday.add(Duration(days: index))),
    );

    return Row(
      children: weekdays
          .map(
            (dayName) => Expanded(
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
            ),
          )
          .toList(),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectionMode,
    required this.selectedDate,
    required this.selectedRange,
    required this.isDateDisabled,
    required this.onDayTapped,
  });

  final DateTime month;
  final DatePickerSelectionMode selectionMode;
  final DateTime? selectedDate;
  final DatePickerRange? selectedRange;
  final bool Function(DateTime date) isDateDisabled;
  final ValueChanged<DateTime> onDayTapped;

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final leadingDays = (firstDayOfMonth.weekday - 1) % 7;
    final gridStartDate = firstDayOfMonth.subtract(Duration(days: leadingDays));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        6,
        (rowIndex) => Expanded(
          child: Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              return Expanded(
                child: _DayCell(
                  cellDate: gridStartDate.add(Duration(days: cellIndex)),
                  month: month,
                  colIndex: colIndex,
                  selectionMode: selectionMode,
                  selectedDate: selectedDate,
                  selectedRange: selectedRange,
                  isDateDisabled: isDateDisabled,
                  onDayTapped: onDayTapped,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.cellDate,
    required this.month,
    required this.colIndex,
    required this.selectionMode,
    required this.selectedDate,
    required this.selectedRange,
    required this.isDateDisabled,
    required this.onDayTapped,
  });

  final DateTime cellDate;
  final DateTime month;
  final int colIndex;
  final DatePickerSelectionMode selectionMode;
  final DateTime? selectedDate;
  final DatePickerRange? selectedRange;
  final bool Function(DateTime date) isDateDisabled;
  final ValueChanged<DateTime> onDayTapped;

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDay(DateTime? a, DateTime? b) =>
      a != null &&
      b != null &&
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth =
        cellDate.year == month.year && cellDate.month == month.month;
    final isDisabled = !isCurrentMonth || isDateDisabled(cellDate);
    final isToday = isSameDay(cellDate, clock.now());
    var isSelected = false;
    var isStart = false;
    var isEnd = false;
    var isInRange = false;

    if (selectionMode == DatePickerSelectionMode.single) {
      isSelected = isCurrentMonth && isSameDay(cellDate, selectedDate);
    } else {
      final start = selectedRange?.startDate;
      final end = selectedRange?.endDate;
      isStart = isCurrentMonth && isSameDay(cellDate, start);
      isEnd = isCurrentMonth && isSameDay(cellDate, end);
      if (start != null && end != null) {
        final day = dateOnly(cellDate);
        isInRange =
            isCurrentMonth &&
            day.isAfter(dateOnly(start)) &&
            day.isBefore(dateOnly(end));
      }
    }

    final hasRangeActive =
        selectionMode == DatePickerSelectionMode.range &&
        selectedRange?.startDate != null;
    final textColor = isDisabled
        ? context.talleeColors.hintColor.withAlpha(70)
        : (isSelected || isStart || isEnd)
        ? Colors.white
        : !isCurrentMonth
        ? context.talleeColors.hintColor.withAlpha(120)
        : context.talleeColors.textColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isDisabled ? null : () => onDayTapped(cellDate),
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          if (hasRangeActive)
            _RangeSpanDecoration(
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
}

class _RangeSpanDecoration extends StatelessWidget {
  const _RangeSpanDecoration({
    required this.colIndex,
    required this.isStart,
    required this.isEnd,
    required this.isInRange,
    required this.hasEndSelected,
  });

  final int colIndex;
  final bool isStart;
  final bool isEnd;
  final bool isInRange;
  final bool hasEndSelected;

  @override
  Widget build(BuildContext context) {
    if (!hasEndSelected && !isStart || isStart && isEnd) {
      return const SizedBox.shrink();
    }
    final rangeColor = AppColors.primaryColor.withAlpha(45);
    if (isInRange) {
      final borderRadius = colIndex == 0
          ? const BorderRadius.horizontal(left: Radius.circular(17))
          : colIndex == 6
          ? const BorderRadius.horizontal(right: Radius.circular(17))
          : BorderRadius.zero;
      return Positioned.fill(
        child: Center(
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Container(height: 34, color: rangeColor),
          ),
        ),
      );
    }
    if (isStart && hasEndSelected) {
      if (colIndex == 6) return const SizedBox.shrink();
      return _RangeHalf(color: rangeColor, start: true);
    }
    if (isEnd && hasEndSelected) {
      if (colIndex == 0) return const SizedBox.shrink();
      return _RangeHalf(color: rangeColor, start: false);
    }
    return const SizedBox.shrink();
  }
}

class _RangeHalf extends StatelessWidget {
  const _RangeHalf({required this.color, required this.start});

  final Color color;
  final bool start;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Center(
        child: SizedBox(
          height: 34,
          child: Row(
            children: start
                ? [
                    const Expanded(child: SizedBox.shrink()),
                    Expanded(child: Container(color: color)),
                  ]
                : [
                    Expanded(child: Container(color: color)),
                    const Expanded(child: SizedBox.shrink()),
                  ],
          ),
        ),
      ),
    );
  }
}

class DatePickerYearPicker extends StatelessWidget {
  const DatePickerYearPicker({
    super.key,
    required this.controller,
    required this.focusedMonth,
    required this.minDate,
    required this.maxDate,
    required this.onYearSelected,
  });

  final ScrollController controller;
  final DateTime focusedMonth;
  final DateTime? minDate;
  final DateTime? maxDate;
  final ValueChanged<int> onYearSelected;

  @override
  Widget build(BuildContext context) {
    final currentYear = clock.now().year;
    final startYear = minDate?.year ?? currentYear - 20;
    final endYear = maxDate?.year ?? currentYear + 20;
    final years = List.generate(endYear - startYear + 1, (i) => startYear + i);
    return SizedBox(
      height: 270,
      child: GridView.builder(
        controller: controller,
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
              onYearSelected(year);
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
}

class DatePickerActionButtons extends StatelessWidget {
  const DatePickerActionButtons({
    super.key,
    required this.isSubmitEnabled,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool isSubmitEnabled;
  final VoidCallback? onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomTextButton(
          onPressed: onCancel,
          text: loc.cancel,
          style: TextStyle(
            color: context.talleeColors.hintColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        CustomTextButton(
          onPressed: isSubmitEnabled ? onSubmit : null,
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
