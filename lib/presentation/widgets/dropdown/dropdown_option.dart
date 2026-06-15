import 'package:flutter/widgets.dart';

/// A single selectable option for a [LabeledDropdown].
class DropdownOption<T> {
  const DropdownOption({
    required this.value,
    required this.label,
    this.leading,
  });

  /// The value associated with this option.
  final T value;

  /// The text shown for this option.
  final String label;

  /// Optional widget shown before the [label] (e.g. a colored circle).
  final Widget? leading;
}
