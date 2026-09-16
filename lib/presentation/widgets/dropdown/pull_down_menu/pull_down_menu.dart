import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/dropdown/pull_down_menu/pull_down_menu_tile.dart';

class PullDownMenu extends PopupRoute<void> {
  /// The [PopupRoute] that positions, animates and renders the menu surface for a
  /// [CustomPullDownMenu] relative to its trigger button.
  /// - [buttonRect]: The trigger button's rect in overlay coordinates.
  /// - [overlaySize]: The size of the overlay the menu is placed in.
  /// - [items]: The tiles to render inside the menu.
  /// - [menuWidth]: The width of the opened menu.
  PullDownMenu({
    required this.buttonRect,
    required this.overlaySize,
    required this.items,
    required this.menuWidth,
  });

  final Rect buttonRect;
  final Size overlaySize;
  final List<PullDownMenuTile> items;
  final double menuWidth;

  @override
  Color? get barrierColor => Colors.black.withValues(alpha: 0.35);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 180);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    const margin = 8.0;
    final top = buttonRect.bottom + 4;
    final right = (overlaySize.width - buttonRect.right).clamp(
      margin,
      overlaySize.width - menuWidth - margin,
    );

    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return Stack(
      children: [
        Positioned(
          top: top,
          right: right,
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              alignment: Alignment.topRight,
              scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
              child: menuSurface(),
            ),
          ),
        ),
      ],
    );
  }

  Widget menuSurface() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: menuWidth,
        decoration: BoxDecoration(
          color: CustomTheme.boxColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 50,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(mainAxisSize: MainAxisSize.min, children: items),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
