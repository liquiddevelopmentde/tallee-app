import 'package:material_ui/material_ui.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';
import 'package:tallee/presentation/widgets/dropdown/pull_down_menu/pull_down_menu.dart';
import 'package:tallee/presentation/widgets/dropdown/pull_down_menu/pull_down_menu_tile.dart';

export 'pull_down_menu_tile.dart';

class PullDownMenuButton extends StatelessWidget {
  /// A custom pull-down menu.
  /// - [items]: The tiles to display in the menu.
  /// - [icon]: The icon for the trigger button. Defaults to a vertical ellipsis.
  /// - [menuWidth]: The width of the opened menu. Defaults to 220.
  const PullDownMenuButton({
    super.key,
    required this.items,
    this.icon = const Icon(Icons.more_vert),
    this.menuWidth = 220,
  });

  final List<PullDownMenuTile> items;
  final Widget icon;
  final double menuWidth;

  @override
  Widget build(BuildContext context) {
    final buttonKey = GlobalKey();

    return HapticIconButton(
      key: buttonKey,
      icon: icon,
      onPressed: () => open(context, buttonKey),
    );
  }

  void open(BuildContext context, GlobalKey buttonKey) {
    final navigator = Navigator.of(context);
    final button = buttonKey.currentContext!.findRenderObject()! as RenderBox;
    final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;

    final buttonRect = Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(
        button.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
    );

    navigator.push(
      PullDownMenu(
        buttonRect: buttonRect,
        overlaySize: overlay.size,
        items: items,
        menuWidth: menuWidth,
      ),
    );
  }
}
