import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class InfoTile extends StatefulWidget {
  /// A tile widget that displays a title with an icon and some content below it.
  /// - [title]: The title text displayed on the tile.
  /// - [icon]: The icon displayed next to the title.
  /// - [content]: The content widget displayed below the title.
  /// - [padding]: Optional padding for the tile content.
  /// - [height]: Optional height for the tile.
  /// - [width]: Optional width for the tile.
  const InfoTile({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.padding,
    this.height,
    this.width,
    this.horizontalAlignment = CrossAxisAlignment.center,
  });

  /// The title text displayed on the tile.
  final String title;

  /// The icon displayed next to the title.
  final IconData icon;

  /// The content widget displayed below the title.
  final Widget content;

  /// Optional padding for the tile content.
  final EdgeInsets? padding;

  /// Optional height for the tile.
  final double? height;

  /// Optional width for the tile.
  final double? width;

  /// The main axis alignment for the content.
  final CrossAxisAlignment horizontalAlignment;

  @override
  State<InfoTile> createState() => _InfoTileState();
}

class _InfoTileState extends State<InfoTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(12),
      height: widget.height,
      width: widget.width ?? 380,
      decoration: CustomTheme.standardBoxDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: widget.horizontalAlignment,
        children: [
          Row(
            children: [
              Icon(widget.icon),
              const SizedBox(width: 5),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          widget.content,
        ],
      ),
    );
  }
}
