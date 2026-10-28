import 'package:material_ui/material_ui.dart';

/// App-wide scroll behavior.
///
/// Uses [ClampingScrollPhysics] on every platform and disables the overscroll
/// indicator, so scrollables stop at their edges instead of bouncing or
/// stretching.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
