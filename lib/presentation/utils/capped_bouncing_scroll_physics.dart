import 'package:material_ui/material_ui.dart';

class CappedBouncingScrollPhysics extends BouncingScrollPhysics {
  /// iOS bounce physics that never overscroll further than [maxOverscroll].
  const new({super.parent, this.maxOverscroll = 150});

  final double maxOverscroll;

  @override
  CappedBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      CappedBouncingScrollPhysics(
        parent: buildParent(ancestor),
        maxOverscroll: maxOverscroll,
      );

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    final minAllowed = position.minScrollExtent - maxOverscroll;
    final maxAllowed = position.maxScrollExtent + maxOverscroll;
    if (value < minAllowed) return value - minAllowed;
    if (value > maxAllowed) return value - maxAllowed;
    return super.applyBoundaryConditions(position, value);
  }
}
