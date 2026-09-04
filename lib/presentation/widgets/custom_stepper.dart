import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';

class CustomStepper extends StatefulWidget {
  const CustomStepper({
    super.key,
    required this.value,
    this.onChanged,
    this.maxValue,
    this.minValue,
  });

  final int value;
  final void Function(int)? onChanged;
  final int? maxValue;
  final int? minValue;

  @override
  State<CustomStepper> createState() => _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper> {
  late int value = widget.value;

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = widget.minValue != null
        ? value > widget.minValue!
        : true;
    final bool canIncrement = widget.maxValue != null
        ? value < widget.maxValue!
        : true;

    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.onBoxColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: CustomTheme.boxBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HapticIconButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            icon: Icon(
              Icons.remove,
              size: 20,
              color: canDecrement
                  ? CustomTheme.textColor
                  : CustomTheme.textColor.withAlpha(60),
            ),
            onPressed: canDecrement
                ? () => {value--, widget.onChanged?.call(value)}
                : null,
          ),
          Container(width: 1, height: 22, color: CustomTheme.boxBorderColor),
          HapticIconButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            icon: Icon(
              Icons.add,
              size: 20,
              color: canIncrement
                  ? CustomTheme.textColor
                  : CustomTheme.textColor.withAlpha(60),
            ),
            onPressed: canIncrement
                ? () => {value++, widget.onChanged?.call(value)}
                : null,
          ),
        ],
      ),
    );
  }
}
