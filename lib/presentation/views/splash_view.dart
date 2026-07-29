import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tallee/presentation/views/main_menu/custom_navigation_bar.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
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
      backgroundColor: const Color(0xFFEF681F),
      body: SizedBox.expand(
        child: Lottie.asset(
          'assets/logo-animation.json',
          controller: _controller,
          fit: BoxFit.cover,
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
