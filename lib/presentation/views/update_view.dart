import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/services/package_info_service.dart';

class UpdateView extends StatelessWidget {
  /// An update screen displaying a markdown file
  const UpdateView({super.key});

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
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: CustomTheme.standardBoxDecoration,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 10,
                          left: 10,
                          top: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            const ColoredIconContainer(
                              containerSize: 65,
                              iconSize: 65 / 1.5,
                              icon: Icons.newspaper,
                            ),
                            Column(
                              spacing: 2,
                              children: [
                                Text(
                                  loc.whats_new,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Version ${packageInfo.version} (${packageInfo.buildNumber})',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: CustomTheme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<String>(
                        future: loadMarkdownFiles(context),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(loc.error_loading_whats_new),
                            );
                          }
                          return Markdown(
                            data: snapshot.data ?? '',
                            selectable: true,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            styleSheet: buildMarkdownSheet(context),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: BottomAnimatedButton(
                buttonConstraints: const BoxConstraints(minWidth: 390),
                buttonText: loc.close,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet buildMarkdownSheet(BuildContext context) {
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: CustomTheme.textColor,
        overflow: TextOverflow.visible,
      ),
      h1: const TextStyle(
        color: CustomTheme.textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      h2: const TextStyle(
        color: CustomTheme.primaryColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      h3: const TextStyle(
        color: CustomTheme.textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      listBullet: const TextStyle(color: CustomTheme.textColor),
      strong: const TextStyle(
        color: CustomTheme.textColor,
        fontWeight: FontWeight.bold,
      ),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(top: BorderSide(color: CustomTheme.boxBorderColor)),
      ),
    );
  }

  Future<String> loadMarkdownFiles(BuildContext context) async {
    final languageCode = Localizations.localeOf(context).languageCode;
    try {
      return await rootBundle.loadString(
        'assets/whats_new/whats_new_$languageCode.md',
      );
    } catch (_) {
      return await rootBundle.loadString('assets/whats_new/whats_new_en.md');
    }
  }
}
