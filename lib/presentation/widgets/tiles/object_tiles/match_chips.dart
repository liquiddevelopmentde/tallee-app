part of 'game_matches_tile.dart';

/// The match chips, split into the visible and the expandable part.
class _MatchChips extends StatelessWidget {
  const _MatchChips({
    required this.matches,
    required this.collapsedCount,
    required this.canExpand,
    required this.isExpanded,
    required this.expandAnimation,
    required this.onToggle,
    required this.onMatchTap,
  });

  final List<Match> matches;
  final int collapsedCount;
  final bool canExpand;
  final bool isExpanded;
  final Animation<double> expandAnimation;
  final VoidCallback onToggle;
  final ValueChanged<Match> onMatchTap;

  @override
  Widget build(BuildContext context) {
    final visibleMatches = matches.take(collapsedCount).toList();
    final hiddenMatches = matches.skip(collapsedCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChipWrap(matches: visibleMatches, onMatchTap: onMatchTap),
        if (hiddenMatches.isNotEmpty)
          SizeTransition(
            sizeFactor: expandAnimation,
            alignment: AlignmentDirectional.topStart,
            child: FadeTransition(
              opacity: expandAnimation,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _ChipWrap(
                  matches: hiddenMatches,
                  onMatchTap: onMatchTap,
                ),
              ),
            ),
          ),
        if (canExpand)
          _ExpandToggle(isExpanded: isExpanded, onToggle: onToggle),
      ],
    );
  }
}
