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
    required this.leadingWidget,
    required this.title,
    required this.content,
    this.trailingWidget,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.horizontalAlignment = CrossAxisAlignment.center,
  });

  final Icon leadingWidget;
  final String title;
  final Widget? trailingWidget;
  final Widget content;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final CrossAxisAlignment horizontalAlignment;

  @override
  State<InfoTile> createState() => _InfoTileState();
}

class _InfoTileState extends State<InfoTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(12),
      margin: widget.margin,
      height: widget.height,
      width: widget.width ?? 380,
      decoration: CustomTheme.standardBoxDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: widget.horizontalAlignment,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  widget.leadingWidget,
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
              if (widget.trailingWidget != null) widget.trailingWidget!,
            ],
          ),
          const SizedBox(height: 10),
          widget.content,
        ],
      ),
    );
  }
}
