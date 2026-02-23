import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class QuickInfoTile extends StatefulWidget {
  /// A tile widget that displays a title with an icon and a numeric value below it.
  /// - [title]: The title text displayed on the tile.
  /// - [icon]: The icon displayed next to the title.
  /// - [value]: The numeric value displayed below the title.
  /// - [height]: Optional height for the tile.
  /// - [width]: Optional width for the tile.
  /// - [padding]: Optional padding for the tile content.
  const QuickInfoTile({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    this.height,
    this.width,
    this.padding,
  });

  /// The title text displayed on the tile.
  final String title;

  /// The icon displayed next to the title.
  final IconData icon;

  /// The numeric value displayed below the title.
  final int value;

  /// Optional height for the tile.
  final double? height;

  /// Optional width for the tile.
  final double? width;

  /// Optional padding for the tile content.
  final EdgeInsets? padding;

  @override
  State<QuickInfoTile> createState() => _QuickInfoTileState();
}

class _QuickInfoTileState extends State<QuickInfoTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(12),
      height: widget.height ?? 110,
      width: widget.width ?? 180,
      decoration: CustomTheme.standardBoxDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
          const Spacer(),
          Text(
            widget.value.toString(),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
