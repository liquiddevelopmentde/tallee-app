import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppSkeleton extends StatefulWidget {
  /// A widget that provides a skeleton loading effect to its child widget tree.
  /// - [child]: The widget tree to apply the skeleton effect to.
  /// - [enabled]: A boolean to enable or disable the skeleton effect.
  /// - [fixLayoutBuilder]: A boolean to fix the layout builder for AnimatedSwitcher.
  /// - [alignment]: The alignment used for the custom layout builder and optional Align wrapper. Defaults to [Alignment.center].
  const AppSkeleton({
    super.key,
    required this.child,
    this.enabled = true,
    this.fixLayoutBuilder = false,
    this.alignment = Alignment.center,
  });

  /// The widget tree to apply the skeleton effect to.
  final Widget child;

  /// A boolean to enable or disable the skeleton effect.
  final bool enabled;

  /// A boolean to fix the layout builder for AnimatedSwitcher.
  final bool fixLayoutBuilder;

  /// The alignment used for the custom layout builder and optional Align wrapper
  final Alignment alignment;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      effect: PulseEffect(
        from: Colors.grey[800]!,
        to: Colors.grey[600]!,
        duration: const Duration(milliseconds: 800),
      ),
      enabled: widget.enabled,
      enableSwitchAnimation: true,
      switchAnimationConfig: SwitchAnimationConfig(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.linear,
        switchOutCurve: Curves.linear,
        transitionBuilder: AnimatedSwitcher.defaultTransitionBuilder,
        layoutBuilder: !widget.fixLayoutBuilder
            ? AnimatedSwitcher.defaultLayoutBuilder
            : (Widget? currentChild, List<Widget> previousChildren) {
                final children = <Widget>[...previousChildren];
                if (currentChild != null) children.add(currentChild);
                return Stack(alignment: widget.alignment, children: children);
              },
      ),
      child: widget.fixLayoutBuilder
          ? Align(alignment: widget.alignment, child: widget.child)
          : widget.child,
    );
  }
}
