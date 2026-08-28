import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';

/// A unified list tile for editing a match result.
///
/// Shows a participant (player or team) in the app's standard tile style with
/// an optional selection highlight and a ruleset-specific [trailing] control.
class MatchResultListTile extends StatelessWidget {
  const MatchResultListTile({
    super.key,
    required this.child,
    this.onTap,
    this.trailing,
    this.leading,
    this.selected = false,
  });

  /// The main content of the tile, e.g. the player/team name.
  final Widget child;

  /// Optional widget shown on the left, e.g. a placement badge.
  final Widget? leading;

  /// Optional widget shown on the right, e.g. a check icon or score stepper.
  final Widget? trailing;

  /// Invoked when the tile is tapped.
  final VoidCallback? onTap;

  /// Whether the tile should be highlighted as selected.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () async {
              await HapticFeedback.selectionClick();
              onTap!();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: CustomTheme.tileMargin,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: selected
            ? CustomTheme.highlightedBoxDecoration
            : CustomTheme.standardBoxDecoration,
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Expanded(child: child),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}