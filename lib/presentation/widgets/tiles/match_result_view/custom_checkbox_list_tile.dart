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
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        padding: const EdgeInsets.only(left: 2, right: 5),
        decoration: BoxDecoration(
          color: CustomTheme.boxColor,
          border: Border.all(color: CustomTheme.boxBorderColor),
          borderRadius: CustomTheme.standardBorderRadiusAll,
        ),
        child: Row(
          children: [
            Checkbox(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              value: value,
              onChanged: (bool? v) {
                HapticFeedback.selectionClick();
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
