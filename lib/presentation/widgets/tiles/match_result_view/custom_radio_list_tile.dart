import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class CustomRadioListTile<T> extends StatelessWidget {
  /// A custom radio list tile widget that encapsulates a [Radio] button with additional styling and functionality.
  /// - [text]: The text to display next to the radio button.
  /// - [value]: The value associated with the radio button.
  /// - [onContainerTap]: The callback invoked when the container is tapped.
  const CustomRadioListTile({
    super.key,
    required this.content,
    required this.value,
    required this.onContainerTap,
  });

  /// The text to display next to the radio button.
  final Widget content;

  /// The value associated with the radio button.
  final T value;

  /// The callback invoked when the container is tapped.
  final ValueChanged<T> onContainerTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onContainerTap(value),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: CustomTheme.boxColor,
          border: Border.all(color: CustomTheme.boxBorderColor),
          borderRadius: CustomTheme.standardBorderRadiusAll,
        ),
        child: Row(
          children: [
            Radio<T>(value: value, toggleable: true),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}
