import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  Future<String> _loadPrivacyPolicy(BuildContext context) async {
    final languageCode = Localizations.localeOf(context).languageCode;
    try {
      return await rootBundle.loadString(
        'assets/privacy_policy/privacy_policy_$languageCode.md',
      );
    } catch (_) {
      return await rootBundle.loadString(
        'assets/privacy_policy/privacy_policy_en.md',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.privacy_policy)),
      backgroundColor: CustomTheme.backgroundColor,
      body: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: CustomTheme.standardBoxDecoration,
        child: FutureBuilder<String>(
          future: _loadPrivacyPolicy(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(loc.error_loading_privacy_policy));
            }
            return Markdown(
              data: snapshot.data ?? '',
              shrinkWrap: true,
              softLineBreak: true,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                    p: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(overflow: TextOverflow.visible),
                  ),
            );
          },
        ),
      ),
    );
  }
}
