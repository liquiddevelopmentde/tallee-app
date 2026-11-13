part of 'game_matches_tile.dart';

/// The button that expands or collapses the hidden match chips.
class _ExpandToggle extends StatelessWidget {
  const _ExpandToggle({required this.isExpanded, required this.onToggle});

  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 32,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
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
          isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
          key: ValueKey(isExpanded),
          size: 20,
          color: context.talleeColors.hintColor,
        ),
      ),
    ),
  );
}
