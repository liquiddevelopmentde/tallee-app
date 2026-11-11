import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/player_profile_list_tile.dart';

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
  /// Horizontal spacing between match chips.
  static const double _chipSpacing = 12;

  /// Horizontal and top padding of the surrounding [InfoTile].
  static const double _tilePadding = 12;

  late AnimationController expandController;
  late CurvedAnimation expandAnimation;

  bool isExpanded = false;

  @override
  void initState() {
    super.initState();

    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    );
    expandAnimation = CurvedAnimation(
      parent: expandController,
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  void dispose() {
    expandAnimation.dispose();
    expandController.dispose();
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
          title: '${loc.matches} (${widget.matches.length})',
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
                : buildMatchChips(collapsedCount, canExpand),
          ),
        );
      },
    );
  }

  Widget buildMatchChips(int collapsedCount, bool canExpand) {
    final visibleMatches = widget.matches.take(collapsedCount).toList();
    final hiddenMatches = widget.matches.skip(collapsedCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildChipWrap(visibleMatches),
        if (hiddenMatches.isNotEmpty)
          SizeTransition(
            sizeFactor: expandAnimation,
            alignment: AlignmentDirectional.topStart,
            child: FadeTransition(
              opacity: expandAnimation,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: buildChipWrap(hiddenMatches),
              ),
            ),
          ),
        if (canExpand) buildExpandToggle(),
      ],
    );
  }

  Widget buildChipWrap(List<Match> matches) => Wrap(
    spacing: _chipSpacing,
    runSpacing: 8,
    children: [
      for (final match in matches)
        PlayerProfileListTile(
          title: match.name,
          count: match.players.length,
          onTap: () => widget.onMatchTap(match),
        ),
    ],
  );

  Widget buildExpandToggle() => SizedBox(
    width: double.infinity,
    height: 32,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: toggleExpanded,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation.drive(Tween(begin: 0.8, end: 1)),
            child: child,
          ),
        ),
        child: Icon(
          isExpanded ? Icons.expand_less_rounded : Icons.more_horiz,
          key: ValueKey(isExpanded),
          size: 20,
          color: context.talleeColors.hintColor,
        ),
      ),
    ),
  );

  void toggleExpanded() {
    setState(() => isExpanded = !isExpanded);

    if (isExpanded) {
      expandController.forward();
    } else {
      expandController.reverse();
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
