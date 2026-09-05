import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tallee/core/custom_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.primaryColor,
      body: Center(
        child: Lottie.asset(
          'assets/logo-animation.json',
          controller: _controller,
          fit: BoxFit.contain,
          frameRate: FrameRate.max,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().then((value) {
                if (!mounted) return;
                widget.onFinished?.call();
              });
          },
        ),
      ),
    );
  }
}
