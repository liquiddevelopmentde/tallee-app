import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/player_profile_list_tile.dart';

part 'match_chip_wrap.dart';
part 'match_chips.dart';
part 'match_expand_toggle.dart';

/// Horizontal spacing between match chips.
const double _chipSpacing = 12;

/// Horizontal and top padding of the surrounding [InfoTile].
const double _tilePadding = 12;

class GameMatchesTile extends StatefulWidget {
  /// A tile that lists the matches played with a game as chips.
  /// - [matches]: The matches to display, ordered from newest to oldest.
  /// - [onMatchTap]: Callback invoked when a match chip is tapped.
  /// - [isLoading]: Whether the matches are still being loaded.
  /// - [maxRows]: Maximum number of chip rows shown before the list becomes
  ///   expandable.
  const GameMatchesTile({
    super.key,
    required this.matches,
    required this.onMatchTap,
    this.isLoading = false,
    this.maxRows = 3,
  });

  final List<Match> matches;
  final ValueChanged<Match> onMatchTap;
  final bool isLoading;
  final int maxRows;

  @override
  State<GameMatchesTile> createState() => _GameMatchesTileState();
}

class _GameMatchesTileState extends State<GameMatchesTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late CurvedAnimation _expandAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  void dispose() {
    _expandAnimation.dispose();
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final collapsedCount = visibleChipCount(
          constraints.maxWidth - _tilePadding * 2,
        );
        final canExpand = collapsedCount < widget.matches.length;

        return InfoTile(
          title: loc.matches,
          leadingWidget: const Icon(MATCH_ICON),
          horizontalAlignment: CrossAxisAlignment.start,
          padding: EdgeInsets.fromLTRB(
            _tilePadding,
            _tilePadding,
            _tilePadding,
            canExpand ? 0 : _tilePadding,
          ),
          content: AppSkeleton(
            enabled: widget.isLoading,
            fixLayoutBuilder: true,
            alignment: Alignment.topLeft,
            child: widget.matches.isEmpty
                ? Text(
                    loc.no_matches_played_yet,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.talleeColors.textColor,
                    ),
                  )
                : _MatchChips(
                    matches: widget.matches,
                    collapsedCount: collapsedCount,
                    canExpand: canExpand,
                    isExpanded: _isExpanded,
                    expandAnimation: _expandAnimation,
                    onToggle: toggleExpanded,
                    onMatchTap: widget.onMatchTap,
                  ),
          ),
        );
      },
    );
  }

  void toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);

    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  /// Number of chips that fit into [GameMatchesTile.maxRows] rows at [maxWidth].
  int visibleChipCount(double maxWidth) {
    if (widget.matches.isEmpty) return 0;

    final style = DefaultTextStyle.of(context).style;
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);

    var rowWidth = 0.0;
    var rows = 1;
    var visibleCount = 0;

    for (final match in widget.matches) {
      final width = chipWidth(
        title: match.name,
        count: match.players.length,
        style: style,
        textScaler: textScaler,
        textDirection: textDirection,
      );
      final isRowEmpty = rowWidth == 0;
      final neededWidth = isRowEmpty ? width : rowWidth + _chipSpacing + width;

      if (neededWidth > maxWidth && !isRowEmpty) {
        rows++;
        if (rows > widget.maxRows) break;
        rowWidth = width;
      } else {
        rowWidth = neededWidth;
      }

      visibleCount++;
    }

    return visibleCount;
  }

  /// Approximates the width of a [PlayerProfileListTile] chip.
  double chipWidth({
    required String title,
    required int count,
    required TextStyle style,
    required TextScaler textScaler,
    required TextDirection textDirection,
  }) {
    final textStyle = style.copyWith(fontSize: 14);
    final titleWidth = textWidth(title, textStyle, textScaler, textDirection);
    final countWidth = textWidth(
      count.toString(),
      textStyle,
      textScaler,
      textDirection,
    );

    // Title padding (6 + 6), count padding (4 + 4), the gap between the count
    // and its icon (5) and the icon size (20).
    return titleWidth + 12 + countWidth + 8 + 5 + 20;
  }

  double textWidth(
    String text,
    TextStyle style,
    TextScaler textScaler,
    TextDirection textDirection,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();

    return painter.width;
  }
}
