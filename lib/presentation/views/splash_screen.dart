import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/views/main_menu/custom_navigation_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const CustomNavigationBar(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                }
              });
          },
        ),
      ),
    );
  }
}
