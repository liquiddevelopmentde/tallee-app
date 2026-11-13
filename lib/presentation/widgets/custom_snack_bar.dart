import 'package:material_ui/material_ui.dart';
import 'package:tallee/presentation/widgets/snack_bar_content.dart';

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    Key? key,
    required String message,
    IconData? actionIcon,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) : this._internal(
         key: key,
         message: message,
         actionIcon: actionIcon,
         actionLabel: actionLabel,
         onActionTap: onActionTap,
         duration: const Duration(milliseconds: 5000),
         proxy: ProxyAnimation(),
       );

  CustomSnackBar._internal({
    super.key,
    required String message,
    required this.proxy,
    this.actionIcon,
    this.actionLabel,
    this.onActionTap,
    super.duration,
  }) : super(
         animation: proxy,
         behavior: SnackBarBehavior.floating,
         backgroundColor: Colors.transparent,
         elevation: 0,
         content: SnackBarContent(
           message: message,
           animation: proxy,
           actionIcon: actionIcon,
           actionLabel: actionLabel,
           onActionTap: onActionTap,
         ),
       );

  final ProxyAnimation proxy;
  final IconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  SnackBar withAnimation(Animation<double> newAnimation, {Key? fallbackKey}) {
    proxy.parent = newAnimation;
    final animatedContent = content as SnackBarContent;

    return CustomSnackBar._internal(
      key: key ?? fallbackKey,
      message: animatedContent.message,
      actionIcon: animatedContent.actionIcon,
      actionLabel: animatedContent.actionLabel,
      onActionTap: animatedContent.onActionTap,
      duration: duration,
      proxy: proxy,
    );
  }
}
