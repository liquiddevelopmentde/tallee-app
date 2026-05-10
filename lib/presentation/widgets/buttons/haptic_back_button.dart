import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticBackButton extends StatelessWidget {
  const HapticBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final iconData = switch (defaultTargetPlatform) {
      TargetPlatform.iOS ||
      TargetPlatform.macOS => Icons.arrow_back_ios_new_rounded,
      _ => Icons.arrow_back_rounded,
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
