import 'package:material_ui/material_ui.dart';

/// App-wide scroll behavior adapted to the current platform.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final platform = getPlatform(context);

    if (platform == TargetPlatform.iOS) {
      return const BouncingScrollPhysics(
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
}
