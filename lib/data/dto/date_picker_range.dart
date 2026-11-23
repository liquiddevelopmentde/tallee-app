/// Represents a range of dates selected in a date picker.
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
