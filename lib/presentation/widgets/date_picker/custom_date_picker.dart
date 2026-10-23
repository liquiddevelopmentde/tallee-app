import 'package:clock/clock.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/custom_text_button.dart';

/// Selection mode for [CustomDatePicker].
enum DatePickerSelectionMode { single, range }

/// Represents a range of dates selected in [CustomDatePicker].
class DatePickerRange {
  final DateTime? startDate;
  final DateTime? endDate;

  const DatePickerRange({this.startDate, this.endDate});

  bool get isComplete => startDate != null && endDate != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DatePickerRange &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

/// A custom date picker supporting single date and date range selection.
/// - [selectionMode]: Whether to select one date or a date range.
/// - [initialSelectedDate]: The initially selected date in single-date mode.
/// - [initialSelectedRange]: The initially selected range in range mode.
/// - [minDate] and [maxDate]: Optional inclusive date boundaries.
/// - [firstDayOfWeek]: ISO weekday number used as the first weekday.
/// - [showActionButtons]: Whether to show cancel and confirm buttons.
/// - [onDateSelected] and [onRangeSelected]: Called when the selection changes.
/// - [onDateSubmitted] and [onRangeSubmitted]: Called when the selection is
///   confirmed.
/// - [onCancel]: Called when the selection is cancelled.
class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({
    super.key,
    this.selectionMode = DatePickerSelectionMode.single,
    this.initialSelectedDate,
    this.initialSelectedRange,
    this.minDate,
    this.maxDate,
    this.firstDayOfWeek = 1,
    this.showActionButtons = true,
    this.onDateSubmitted,
    this.onRangeSubmitted,
    this.onCancel,
    this.onDateSelected,
    this.onRangeSelected,
  }) : assert(firstDayOfWeek >= 1 && firstDayOfWeek <= 7);

  final DatePickerSelectionMode selectionMode;
  final DateTime? initialSelectedDate;
  final DatePickerRange? initialSelectedRange;
  final DateTime? minDate;
  final DateTime? maxDate;

  final int firstDayOfWeek;

  final bool showActionButtons;

  final ValueChanged<DateTime>? onDateSubmitted;

  final ValueChanged<DatePickerRange>? onRangeSubmitted;

  final VoidCallback? onCancel;

  final ValueChanged<DateTime>? onDateSelected;

  final ValueChanged<DatePickerRange>? onRangeSelected;

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  static const int _initialPage = 1200;

  late final PageController _pageController;
  final ScrollController _yearPickerController = ScrollController();
  late final DateTime _initialMonth;
  late DateTime _focusedMonth;

  DateTime? _selectedDate;
  DatePickerRange? _selectedRange;

  bool _isYearPickerOpen = false;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.initialSelectedDate;
    _selectedRange = widget.initialSelectedRange;

    DateTime focus;
    if (widget.selectionMode == DatePickerSelectionMode.single &&
        _selectedDate != null) {
      focus = _selectedDate!;
    } else if (widget.selectionMode == DatePickerSelectionMode.range &&
        _selectedRange?.startDate != null) {
      focus = _selectedRange!.startDate!;
    } else {
      focus = clock.now();
    }

    _focusedMonth = DateTime(focus.year, focus.month, 1);
    _initialMonth = _focusedMonth;
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _yearPickerController.dispose();
    super.dispose();
  }

  DateTime _monthForPage(int page) {
    final offset = page - _initialPage;
    return DateTime(_initialMonth.year, _initialMonth.month + offset, 1);
  }

  int _pageForMonth(DateTime month) {
    final monthDiff =
        (month.year - _initialMonth.year) * 12 +
        (month.month - _initialMonth.month);
    return _initialPage + monthDiff;
  }

  void _onPageChanged(int page) {
    setState(() {
      _focusedMonth = _monthForPage(page);
    });
  }

  void _jumpToMonth(DateTime month) {
    final targetMonth = DateTime(month.year, month.month, 1);
    setState(() {
      _focusedMonth = targetMonth;
      _isYearPickerOpen = false;
    });
    final page = _pageForMonth(targetMonth);
    _pageController.jumpToPage(page);
  }

  void _onDayTapped(DateTime date) {
    if (_isDateDisabled(date)) return;

    HapticFeedback.lightImpact();

    DateTime? selectedDate;
    DatePickerRange? selectedRange;
    setState(() {
      if (widget.selectionMode == DatePickerSelectionMode.single) {
        _selectedDate = date;
        selectedDate = date;
      } else {
        final currentStart = _selectedRange?.startDate;
        final currentEnd = _selectedRange?.endDate;

        if (currentStart == null || currentEnd != null) {
          _selectedRange = DatePickerRange(startDate: date, endDate: null);
        } else if (_isBeforeDay(date, currentStart)) {
          _selectedRange = DatePickerRange(startDate: date, endDate: null);
        } else {
          _selectedRange = DatePickerRange(
            startDate: currentStart,
            endDate: date,
          );
        }
        selectedRange = _selectedRange;
      }
    });

    if (selectedDate != null) {
      widget.onDateSelected?.call(selectedDate!);
      if (!widget.showActionButtons) {
        widget.onDateSubmitted?.call(selectedDate!);
      }
    } else if (selectedRange != null) {
      widget.onRangeSelected?.call(selectedRange!);
      if (!widget.showActionButtons && selectedRange!.isComplete) {
        widget.onRangeSubmitted?.call(selectedRange!);
      }
    }
  }

  bool _isDateDisabled(DateTime date) {
    final day = _dateOnly(date);
    if (widget.minDate != null && day.isBefore(_dateOnly(widget.minDate!))) {
      return true;
    }
    if (widget.maxDate != null && day.isAfter(_dateOnly(widget.maxDate!))) {
      return true;
    }
    return false;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool _isBeforeDay(DateTime a, DateTime b) {
    return _dateOnly(a).isBefore(_dateOnly(b));
  }

  bool get _isSubmitEnabled {
    if (widget.selectionMode == DatePickerSelectionMode.single) {
      return _selectedDate != null;
    }
    return _selectedRange?.isComplete ?? false;
  }

  void _handleSubmit() {
    if (!_isSubmitEnabled) return;
    HapticFeedback.lightImpact();
    if (widget.selectionMode == DatePickerSelectionMode.single) {
      widget.onDateSubmitted?.call(_selectedDate!);
    } else {
      widget.onRangeSubmitted?.call(_selectedRange!);
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
          _buildHeader(context, localeName),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _isYearPickerOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _buildCalendarView(context, localeName),
            secondChild: _buildYearPickerView(context),
          ),
          if (widget.showActionButtons) ...[
            const SizedBox(height: 12),
            _buildActionButtons(context, loc),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String localeName) {
    final monthYearStr = DateFormat.yMMMM(localeName).format(_focusedMonth);

    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            _pageController.previousPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
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
                _isYearPickerOpen = !_isYearPickerOpen;
              });
              if (_isYearPickerOpen) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _scrollYearPickerToFocusedYear();
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
                    turns: _isYearPickerOpen ? 0.5 : 0.0,
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
            _pageController.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
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

  Widget _buildCalendarView(BuildContext context, String localeName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildWeekdayHeader(context, localeName),
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, page) {
              final month = _monthForPage(page);
              return _buildMonthGrid(context, month);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(BuildContext context, String localeName) {
    // Generate weekday names based on firstDayOfWeek
    final monday = DateTime(2026, 1, 5); // Known Monday
    final weekdays = <String>[];
    for (int i = 0; i < 7; i++) {
      final day = monday.add(
        Duration(days: (widget.firstDayOfWeek - 1 + i) % 7),
      );
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

  Widget _buildMonthGrid(BuildContext context, DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final weekdayOfFirst = firstDayOfMonth.weekday; // ISO 1..7
    final leadingDays = (weekdayOfFirst - widget.firstDayOfWeek + 7) % 7;
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
                child: _buildDayCell(
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

  Widget _buildDayCell({
    required BuildContext context,
    required DateTime cellDate,
    required DateTime month,
    required int colIndex,
  }) {
    final isCurrentMonth =
        cellDate.year == month.year && cellDate.month == month.month;
    final isDisabled = !isCurrentMonth || _isDateDisabled(cellDate);
    final isToday = _isSameDay(cellDate, clock.now());

    bool isSelected = false;
    bool isStart = false;
    bool isEnd = false;
    bool isInRange = false;

    if (widget.selectionMode == DatePickerSelectionMode.single) {
      isSelected = isCurrentMonth && _isSameDay(cellDate, _selectedDate);
    } else {
      final start = _selectedRange?.startDate;
      final end = _selectedRange?.endDate;

      isStart = isCurrentMonth && start != null && _isSameDay(cellDate, start);
      isEnd = isCurrentMonth && end != null && _isSameDay(cellDate, end);

      if (start != null && end != null) {
        final day = _dateOnly(cellDate);
        final startDay = _dateOnly(start);
        final endDay = _dateOnly(end);
        isInRange =
            isCurrentMonth && day.isAfter(startDay) && day.isBefore(endDay);
      }
    }

    final hasRangeActive =
        widget.selectionMode == DatePickerSelectionMode.range &&
        _selectedRange?.startDate != null;

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
      onTap: isDisabled ? null : () => _onDayTapped(cellDate),
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          if (hasRangeActive)
            _buildRangeSpanDecoration(
              colIndex: colIndex,
              isStart: isStart,
              isEnd: isEnd,
              isInRange: isInRange,
              hasEndSelected: _selectedRange?.endDate != null,
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

  Widget _buildRangeSpanDecoration({
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
      // Start and end are same day
      return const SizedBox.shrink();
    }

    if (isStart && hasEndSelected) {
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

  Widget _buildYearPickerView(BuildContext context) {
    final currentYear = clock.now().year;
    final startYear = widget.minDate?.year ?? (currentYear - 20);
    final endYear = widget.maxDate?.year ?? (currentYear + 20);
    final years = List.generate(endYear - startYear + 1, (i) => startYear + i);

    return SizedBox(
      height: 270,
      child: GridView.builder(
        controller: _yearPickerController,
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
          final isSelected = year == _focusedMonth.year;
          final isCurrentYear = year == currentYear;

          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              HapticFeedback.lightImpact();
              _jumpToMonth(DateTime(year, _focusedMonth.month, 1));
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

  void _scrollYearPickerToFocusedYear() {
    final currentYear = clock.now().year;
    final startYear = widget.minDate?.year ?? (currentYear - 20);
    final yearIndex = _focusedMonth.year - startYear;
    if (yearIndex < 0) return;

    final rowIndex = yearIndex ~/ 3;
    final targetOffset = rowIndex * 54.0;
    final maxOffset = _yearPickerController.position.maxScrollExtent;
    _yearPickerController.jumpTo(targetOffset.clamp(0.0, maxOffset).toDouble());
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations loc) {
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
          onPressed: _isSubmitEnabled ? _handleSubmit : null,
          text: loc.confirm,
          style: TextStyle(
            color: _isSubmitEnabled
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
  int firstDayOfWeek = 1,
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
          firstDayOfWeek: firstDayOfWeek,
          showActionButtons: true,
          onDateSubmitted: (value) => Navigator.pop(context, value),
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
  int firstDayOfWeek = 1,
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
          firstDayOfWeek: firstDayOfWeek,
          showActionButtons: true,
          onRangeSubmitted: (value) =>
              Navigator.pop(context, [value.startDate, value.endDate]),
          onCancel: () => Navigator.pop(context),
        ),
      );
    },
  );
}
