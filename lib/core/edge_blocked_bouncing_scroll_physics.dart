import 'dart:math' show max, min;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// `ScrollPhysics` with iOS-like fling feel, but blocks overscroll on both ends.
class EdgeBlockedBouncingScrollPhysics extends BouncingScrollPhysics {
  const EdgeBlockedBouncingScrollPhysics({
    super.parent,
    this.momentumMultiplier = 1.35,
    this.friction = 0.012,
    this.minFlingVelocity = 20.0,
  });

  /// Multiplies fling velocity to build up more momentum.
  final double momentumMultiplier;

  /// Lower friction means longer, smoother deceleration.
  final double friction;

  /// Lower threshold makes short flicks feel more responsive.
  @override
  final double minFlingVelocity;

  @override
  EdgeBlockedBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return EdgeBlockedBouncingScrollPhysics(
      parent: buildParent(ancestor),
      momentumMultiplier: momentumMultiplier,
      friction: friction,
      minFlingVelocity: minFlingVelocity,
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (_isUnderscrolling(position, value)) {
      return value - position.pixels;
    }
    if (_isOverscrolling(position, value)) {
      return value - position.pixels;
    }
    if (_didHitTopEdge(position, value)) {
      return value - position.minScrollExtent;
    }
    if (_didHitBottomEdge(position, value)) {
      return value - position.maxScrollExtent;
    }

    return 0;
  }

  bool _isUnderscrolling(ScrollMetrics position, double value) {
    return value < position.pixels &&
        position.pixels <= position.minScrollExtent;
  }

  bool _isOverscrolling(ScrollMetrics position, double value) {
    return position.maxScrollExtent <= position.pixels &&
        position.pixels < value;
  }

  bool _didHitTopEdge(ScrollMetrics position, double value) {
    return value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels;
  }

  bool _didHitBottomEdge(ScrollMetrics position, double value) {
    return position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final Tolerance tolerance = toleranceFor(position);

    if (position.outOfRange) {
      final double end = position.pixels < position.minScrollExtent
          ? position.minScrollExtent
          : position.maxScrollExtent;
      final double adjustedVelocity = position.pixels < position.minScrollExtent
          ? max(0.0, velocity)
          : min(0.0, velocity);

      return ScrollSpringSimulation(
        spring,
        position.pixels,
        end,
        adjustedVelocity,
        tolerance: tolerance,
      );
    }

    if (velocity.abs() < tolerance.velocity ||
        velocity.abs() < minFlingVelocity) {
      return null;
    }
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent) {
      return null;
    }
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent) {
      return null;
    }

    return BoundedFrictionSimulation(
      friction,
      position.pixels,
      velocity * momentumMultiplier,
      position.minScrollExtent,
      position.maxScrollExtent,
    );
  }

  @override
  double carriedMomentum(double existingVelocity) {
    return super.carriedMomentum(existingVelocity) +
        (existingVelocity * (momentumMultiplier - 1));
  }
}
