import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

class UpdateView extends StatelessWidget {
  const UpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.whats_new),
        leading: const SizedBox.shrink(),
      ),
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
                  child: FutureBuilder<String>(
                    future: loadWhatsNew(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text(loc.error_loading_whats_new));
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
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      h2: const TextStyle(
        color: CustomTheme.primaryColor,
        fontSize: 20,
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

  Future<String> loadWhatsNew(BuildContext context) async {
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
