import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tallee/presentation/utils/capped_bouncing_scroll_physics.dart';

/// App-wide scroll behavior adapted to the current platform.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final platform = getPlatform(context);

    if (platform == TargetPlatform.iOS) {
      return const CappedBouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    }

    return const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (axisDirectionToAxis(details.direction) != Axis.vertical) return child;

    if (getPlatform(context) == TargetPlatform.iOS) {
      return CupertinoScrollbar(controller: details.controller, child: child);
    }
    return Scrollbar(
      controller: details.controller,
      radius: const Radius.circular(12),
      child: child,
    );
  }
}
