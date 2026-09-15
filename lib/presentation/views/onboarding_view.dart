import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/services/shared_preferences_service.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingView extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingView({super.key, required this.onCompleted});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const OnboardingPageData(
        title: 'Welcome to Tallee',
        description: 'Your companion for game nights. Record matches, track winners, and manage your play history.',
        icon: Icons.style_rounded,
      ),
      const OnboardingPageData(
        title: 'Flexible Rulesets',
        description: 'Create custom games and pick the ruleset that fits: highest score, lives, placement, and more.',
        icon: Icons.rule_rounded,
      ),
      const OnboardingPageData(
        title: 'Players & Teams',
        description: 'Organize your gaming circle into groups and split players into teams for any match.',
        icon: Icons.groups_rounded,
      ),
      const OnboardingPageData(
        title: 'Game Statistics',
        description: 'Get meaningful insights into your performance with custom statistics scoped to your needs.',
        icon: Icons.query_stats_rounded,
      ),
      const OnboardingPageData(
        title: 'Sharing & Privacy',
        description: 'Share matches easily via QR-codes or export specific matches and full backups as local files. Your data stays private by default.',
        icon: Icons.share,
      ),
    ];

    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              //TODO: remove splash and implement custom button (maybe)
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  SharedPreferencesService.setOnboardingCompleted(true);
                  widget.onCompleted();
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(color: CustomTheme.textColor),
                ),
              ),
            ),

            // Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          page.icon,
                          size: 100,
                          color: CustomTheme.primaryColor,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.visible,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: CustomTheme.hintColor,
                                overflow: TextOverflow.visible,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // Page Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 8),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? CustomTheme.primaryColor
                        : CustomTheme.textColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BottomAnimatedButton(
                    buttonType: ButtonType.primary,
                    buttonText: isLastPage ? 'Get Started' : 'Next',
                    sizeRelativeToWidth: 0.6,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (isLastPage) {
                        SharedPreferencesService.setOnboardingCompleted(true);
                        widget.onCompleted();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.fastOutSlowIn,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
