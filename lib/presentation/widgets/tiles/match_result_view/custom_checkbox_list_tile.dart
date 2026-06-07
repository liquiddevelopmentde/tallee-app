import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';

class CustomCheckboxListTile extends StatelessWidget {
  const CustomCheckboxListTile({
    super.key,
    required this.content,
    required this.value,
    required this.onChanged,
  });

  final Widget content;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.selectionClick();
        onChanged(!value);
      },
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
            Checkbox(
              value: value,
              onChanged: (bool? v) async {
                await HapticFeedback.selectionClick();
                if (v == null) return;
                onChanged(v);
              },
            ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}
