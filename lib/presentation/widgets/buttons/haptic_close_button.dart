import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticCloseButton extends StatelessWidget {
  const HapticCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final iconData = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => CupertinoIcons.xmark,
      _ => Icons.close_rounded,
    };

    return IconButton(
      icon: Icon(iconData),
      onPressed: () async {
        await HapticFeedback.mediumImpact();
        Navigator.of(context).maybePop();
      },
    );
  }
}
