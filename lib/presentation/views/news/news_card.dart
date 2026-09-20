import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/dto/news_item.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.newsItem});

  final NewsItem newsItem;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context).localeName;
    final heading =
        newsItem.localizedHeading[locale] ?? newsItem.localizedHeading['en']!;
    final text =
        newsItem.localizedText[locale] ?? newsItem.localizedText['en']!;

    final iconColor = getColorFromAppColor(newsItem.iconColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 2,
        children: [
          ColoredIconContainer(
            icon: newsItem.icon,
            containerSize: 44,
            color: iconColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                DefaultTextStyle.merge(
                  style: const TextStyle(overflow: TextOverflow.visible),
                  softWrap: true,
                  child: MarkdownBody(
                    data: text,
                    styleSheet: buildMarkdownSheet(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet buildMarkdownSheet(BuildContext context) {
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: CustomTheme.textColor,
        overflow: TextOverflow.visible,
      ),
      strong: const TextStyle(
        color: CustomTheme.textColor,
        fontWeight: FontWeight.bold,
        overflow: TextOverflow.visible,
      ),
    );
  }
}
