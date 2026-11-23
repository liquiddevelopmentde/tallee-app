import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/presentation/widgets/dropdown/pull_down_menu/pull_down_menu_tile.dart';

class PullDownMenu extends PopupRoute<void> {
  /// The [PopupRoute] that positions, animates and renders the menu surface for a
  /// [PullDownMenu] relative to its trigger button.
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
              child: menuSurface(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget menuSurface(BuildContext context) => Material(
    color: Colors.transparent,
    child: Container(
      width: menuWidth,
      decoration: BoxDecoration(
        color: context.talleeColors.boxColor,
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
        child: AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topRight,
          child: _PullDownMenuContent(initialItems: items),
        ),
      ),
    ),
  );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}

class _PullDownMenuContent extends StatefulWidget {
  const _PullDownMenuContent({required this.initialItems});

  final List<PullDownMenuTile> initialItems;

  @override
  State<_PullDownMenuContent> createState() => _PullDownMenuContentState();
}

class _PullDownMenuContentState extends State<_PullDownMenuContent> {
  late List<PullDownMenuTile> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems;
  }

  void _openSubmenu(List<PullDownMenuTile> items) {
    setState(() => _items = items);
  }

  @override
  Widget build(BuildContext context) => PullDownMenuScope(
    openSubmenu: _openSubmenu,
    child: Column(
      key: ObjectKey(_items),
      mainAxisSize: MainAxisSize.min,
      children: _items,
    ),
  );
}

/// Lets tiles replace the content of the enclosing [PullDownMenu] with a
/// nested menu without opening a new route. This keeps the barrier in place,
/// so the background does not darken again on switching menus.
class PullDownMenuScope extends InheritedWidget {
  const PullDownMenuScope({
    super.key,
    required this.openSubmenu,
    required super.child,
  });

  /// Replaces the current menu items with the given list of tiles.
  final ValueChanged<List<PullDownMenuTile>> openSubmenu;

  static PullDownMenuScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<PullDownMenuScope>();

  @override
  bool updateShouldNotify(PullDownMenuScope oldWidget) =>
      openSubmenu != oldWidget.openSubmenu;
}
