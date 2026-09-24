import 'package:flutter/material.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/associate_game_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/widgets/match_profile_body.dart';

class PreviewMatchView extends StatelessWidget {
  const PreviewMatchView({super.key, required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.preview_match), centerTitle: true),
      body: SafeArea(
        child: MatchProfileBody(
          match: match,
          isPreview: true,
          onConfirm: () async {
            await Navigator.of(context).push(
              adaptivePageRoute(
                builder: (context) => AssociateGameView(match: match),
              ),
            );
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
