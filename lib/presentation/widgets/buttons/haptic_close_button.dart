import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

class HapticCloseButton extends StatelessWidget {
  const HapticCloseButton({super.key, this.onPressed, this.color});

  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconData = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => CupertinoIcons.xmark,
      _ => Icons.close_rounded,
    };

    return HapticIconButton(
      icon: Icon(iconData, color: color ?? CustomTheme.textColor),
      onPressed:
          onPressed ??
          () async {
            Navigator.of(context).maybePop();
          },
    );
  }
}
