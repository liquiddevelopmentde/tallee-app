import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/custom_text_button.dart';
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
      floatingActionWidget: FloatingActionWidget.directional(
        textDirection: Directionality.of(context),
        top: MediaQuery.paddingOf(context).top + 55,
        end: 0,
        child: CustomTextButton(
          text: AppLocalizations.of(context).skip,
          onPressed: () {
            showcaseProvider.skipTour();
            ShowcaseView.get().dismiss();
          },
        ),
      ),
      child: child,
    );
  }
}
