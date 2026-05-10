import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class CustomCheckboxListTile extends StatelessWidget {
  const CustomCheckboxListTile({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
  });

  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
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
              onChanged: (bool? v) {
                if (v == null) return;
                onChanged(v);
              },
            ),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
