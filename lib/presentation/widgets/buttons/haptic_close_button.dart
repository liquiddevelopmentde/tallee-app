import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

class HapticCloseButton extends StatelessWidget {
  const HapticCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final iconData = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => CupertinoIcons.xmark,
      _ => Icons.close_rounded,
    };

    return HapticIconButton(
      icon: Icon(iconData),
      onPressed: () async {
        Navigator.of(context).maybePop();
      },
    );
  }
}
