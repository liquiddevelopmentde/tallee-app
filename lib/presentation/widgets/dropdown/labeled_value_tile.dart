import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';

/// A tappable value row styled like a dropdown button, used for sections that
/// navigate to a picker instead of opening a dropdown.
class LabeledValueTile extends StatelessWidget {
  const LabeledValueTile({super.key, this.value, this.onTap});

  /// The selected value shown on the left, e.g. a game or group name.
  final String? value;

  /// Invoked when the tile is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () async {
              await HapticFeedback.selectionClick();
              onTap!();
            },
      child: Container(
        height: CustomTheme.controlHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: CustomTheme.controlBoxDecoration,
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? '',
                style: const TextStyle(
                  color: CustomTheme.textColor,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: CustomTheme.hintColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
