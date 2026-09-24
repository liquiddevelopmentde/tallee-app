import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/services/shared_preferences_service.dart';

/// Data model representing a single page in the onboarding carousel.
/// [title] - The headline title displayed on the onboarding page.
/// [description] - The detailed description text displayed below the title.
/// [icon] - The icon displayed prominently on the onboarding page.
/// [imagePath] - The image asset path displayed prominently on the onboarding page.
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    this.icon,
    this.imagePath,
  });

  final String title;
  final String description;
  final IconData? icon;
  final String? imagePath;
}

class OnboardingView extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingView({super.key, required this.onCompleted});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController pageController = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final pages = [
      OnboardingPageData(
        title: loc.onboarding_welcome_title,
        description: loc.onboarding_welcome_desc,
        imagePath: 'assets/App-Icon-Rounded.png',
      ),
      OnboardingPageData(
        title: loc.onboarding_rulesets_title,
        description: loc.onboarding_rulesets_desc,
        icon: Icons.rule_rounded,
      ),
      OnboardingPageData(
        title: loc.onboarding_players_teams_title,
        description: loc.onboarding_players_teams_desc,
        icon: Icons.groups_rounded,
      ),
      OnboardingPageData(
        title: loc.onboarding_statistics_title,
        description: loc.onboarding_statistics_desc,
        icon: Icons.query_stats_rounded,
      ),
      OnboardingPageData(
        title: loc.onboarding_privacy_title,
        description: loc.onboarding_privacy_desc,
        icon: Icons.share,
      ),
    ];

    final isLastPage = currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CustomTextButton(
                text: loc.skip,
                onPressed: () {
                  SharedPreferencesService.setOnboardingCompleted(true);
                  widget.onCompleted();
                },
              ),
            ),

            // Carousel
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (page.imagePath != null)
                          Image.asset(
                            page.imagePath!,
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                          )
                        else if (page.icon != null)
                          Icon(
                            page.icon,
                            size: 100,
                            color: CustomTheme.primaryColor,
                          ),
                        SizedBox(height: 20),
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
                  width: currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: currentPage == index
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
                    buttonText: isLastPage ? loc.get_started : loc.next,
                    sizeRelativeToWidth: 0.6,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (isLastPage) {
                        SharedPreferencesService.setOnboardingCompleted(true);
                        widget.onCompleted();
                      } else {
                        pageController.nextPage(
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
