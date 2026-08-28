import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';

class SettingsListTile extends StatefulWidget {
  /// A customizable settings list tile widget that displays an icon, title, and an optional suffix widget.
  /// - [icon]: The icon displayed on the left side of the tile.
  /// - [title]: The title text displayed next to the icon.
  /// - [suffixWidget]: An optional widget displayed on the right side of the tile.
  /// - [onPressed]: The callback invoked when the tile is tapped.
  /// - [expandedContent]: A widget revealed below the tile when it is tapped.
  /// - [description]: An optional description shown in the tile.
  const SettingsListTile({
    super.key,
    required this.icon,
    required this.title,
    this.suffixWidget,
    this.onPressed,
    this.expandedContent,
    this.description,
  });

  final IconData icon;
  final String title;
  final String? description;
  final Widget? suffixWidget;
  final VoidCallback? onPressed;
  final Widget? expandedContent;

  @override
  State<SettingsListTile> createState() => _SettingsListTileState();
}

class _SettingsListTileState extends State<SettingsListTile> {
  bool isExpanded = false;

  bool get canExpand => widget.expandedContent != null;

  bool get hasDescription => widget.description != null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: GestureDetector(
          onTap: handleTap,
          child: Container(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: CustomTheme.standardBoxDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ColoredIconContainer(
                          icon: widget.icon,
                          containerSize: 44,
                          iconSize: 28,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          widget.title,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.suffixWidget != null) widget.suffixWidget!,
                        // Arrow icon for expanded content
                        if (canExpand) ...[
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            duration: const Duration(milliseconds: 200),
                            turns: isExpanded ? 0.5 : 0,
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: CustomTheme.hintColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                if (hasDescription) ...[
                  const SizedBox(height: 10),
                  Text(
                    widget.description!,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CustomTheme.hintColor,
                    ),
                  ),
                ],

                // expanded content
                if (canExpand)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: isExpanded
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: widget.expandedContent,
                            ),
                          )
                        : const SizedBox(width: double.infinity, height: 0),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The widget ignores the onTap when [expandedContent] is provided
  Future<void> handleTap() async {
    await HapticFeedback.selectionClick();
    canExpand
        ? setState(() => isExpanded = !isExpanded)
        : widget.onPressed?.call();
  }
}
