import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/news/news.dart';
import 'package:tallee/presentation/views/news/news_card.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/services/package_info_service.dart';

class NewsView extends StatelessWidget {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final PackageInfo packageInfo = PackageInfoService.info;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        top: 28,
                        right: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 6,
                        children: [
                          // Icon
                          const ColoredIconContainer(
                            containerSize: 60,
                            icon: Icons.newspaper,
                          ),

                          // Title
                          Text(
                            loc.whats_new,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // Version
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: CustomTheme.onBoxColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${loc.version} ${packageInfo.version}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // News items
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        spacing: 20,
                        children: [
                          for (final item in news) NewsCard(newsItem: item),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: BottomAnimatedButton(
                buttonConstraints: const BoxConstraints(minWidth: 390),
                buttonText: loc.continue_,
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
