import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class CustomAdaptiveSwitch extends StatefulWidget {
  const CustomAdaptiveSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  State<CustomAdaptiveSwitch> createState() => _CustomAdaptiveSwitchState();
}

class _CustomAdaptiveSwitchState extends State<CustomAdaptiveSwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      activeTrackColor: CustomTheme.primaryColor,
      padding: const EdgeInsets.symmetric(vertical: -15),
      value: widget.value,
      onChanged: widget.onChanged,
    );
  }
}
