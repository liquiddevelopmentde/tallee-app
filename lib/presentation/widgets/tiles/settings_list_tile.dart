import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';

class SettingsListTile extends StatelessWidget {
  /// A customizable settings list tile widget that displays an icon, title, and an optional suffix widget.
  /// - [icon]: The icon displayed on the left side of the tile.
  /// - [title]: The title text displayed next to the icon.
  /// - [suffixWidget]: An optional widget displayed on the right side of the tile.
  /// - [onPressed]: The callback invoked when the tile is tapped.
  const SettingsListTile({
    super.key,
    required this.icon,
    required this.title,
    this.suffixWidget,
    this.onPressed,
  });

  /// The icon displayed on the left side of the tile.
  final IconData icon;

  /// The title text displayed next to the icon.
  final String title;

  /// An optional widget displayed on the right side of the tile.
  final Widget? suffixWidget;

  /// The callback invoked when the tile is tapped.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          child: GestureDetector(
            onTap: onPressed ?? () {},
            child: Container(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: CustomTheme.standardBoxDecoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ColoredIconContainer(
                        icon: icon,
                        containerSize: 44,
                        iconSize: 28,
                      ),
                      const SizedBox(width: 16),
                      Text(title, style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  if (suffixWidget != null)
                    suffixWidget!
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
