import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/state/showcase_provider.dart';

class CustomShowcaseWidget extends StatelessWidget {
  const CustomShowcaseWidget({
    super.key,
    required this.showcaseKey,
    required this.description,
    required this.identifier,
    required this.child,
    this.tooltipPosition = TooltipPosition.bottom,
    this.onTargetClick,
    this.disableBarrierInteraction = false,
    this.disposeOnTap,
    this.targetBorderRadius,
    this.targetPadding = EdgeInsets.zero,
  });

  final GlobalKey showcaseKey;
  final String description;
  final String identifier;
  final Widget child;
  final TooltipPosition tooltipPosition;
  final VoidCallback? onTargetClick;
  final bool disableBarrierInteraction;
  final bool? disposeOnTap;
  final BorderRadius? targetBorderRadius;
  final EdgeInsets targetPadding;

  @override
  Widget build(BuildContext context) {
    final showcaseProvider = Provider.of<ShowcaseProvider>(
      context,
      listen: false,
    );

    return Showcase(
      key: showcaseKey,
      description: description,
      targetPadding: targetPadding,
      targetBorderRadius: targetBorderRadius ?? BorderRadius.circular(12),
      descTextStyle: const TextStyle(
        overflow: TextOverflow.visible,
        color: Colors.black,
      ),
      descriptionTextAlign: TextAlign.center,
      scaleAnimationDuration: const Duration(milliseconds: 300),
      scaleAnimationCurve: Curves.easeInOut,
      onTargetClick: onTargetClick,
      disableBarrierInteraction: disableBarrierInteraction,
      disposeOnTap: disposeOnTap,
      disableMovingAnimation: true,
      tooltipPosition: tooltipPosition,
      floatingActionWidget: FloatingActionWidget(
        left: Screen.width * 0.82,
        bottom: Screen.height * 0.89,
        child: TextButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            showcaseProvider.skipTour();
            ShowcaseView.get().dismiss();
          },
          child: Text(
            AppLocalizations.of(context).showcase_skip,
            style: const TextStyle(color: CustomTheme.textColor),
          ),
        ),
      ),
      child: child,
    );
  }
}
