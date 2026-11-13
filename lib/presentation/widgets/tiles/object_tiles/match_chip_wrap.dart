part of 'game_matches_tile.dart';

/// A wrap of tappable [PlayerProfileListTile] chips for the given [matches].
class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.matches, required this.onMatchTap});

  final List<Match> matches;
  final ValueChanged<Match> onMatchTap;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: _chipSpacing,
    runSpacing: 8,
    children: [
      for (final match in matches)
        PlayerProfileListTile(
          title: match.name,
          count: match.players.length,
          onTap: () => onMatchTap(match),
        ),
    ],
  );
}
