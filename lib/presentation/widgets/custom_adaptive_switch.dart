import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';

class CustomAdaptiveSwitch extends StatefulWidget {
  /// A custom switch widget
  /// - [value]: The current value of the switch
  /// - [onChanged]: Callback invoked when the switch value changes
  /// - [padding]: Optional padding around the switch
  const CustomAdaptiveSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.padding,
  });

  final bool value;
  final void Function(bool)? onChanged;
  final EdgeInsets? padding;

  @override
  State<CustomAdaptiveSwitch> createState() => _CustomAdaptiveSwitchState();
}

class _CustomAdaptiveSwitchState extends State<CustomAdaptiveSwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: widget.value,
      onChanged: (bool value) => {
        widget.onChanged?.call(value),
        HapticFeedback.selectionClick(),
      },
      activeTrackColor: CustomTheme.primaryColor,
      padding: widget.padding,
    );
  }
}
