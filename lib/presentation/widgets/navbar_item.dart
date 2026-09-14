import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class NavbarItem extends StatefulWidget {
  /// A navigation bar item widget that represents a single tab in a navigation bar.
  /// - [index]: The index of the tab.
  /// - [isSelected]: A boolean indicating whether the tab is currently selected.
  /// - [icon]: The icon to display for the tab.
  /// - [label]: The label to display for the tab.
  /// - [onTabTapped]: The callback to be invoked when the tab is tapped.
  const NavbarItem({
    super.key,
    required this.index,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTabTapped,
  });

  final int index;
  final bool isSelected;
  final IconData icon;
  final String label;
  final Function(int) onTabTapped;

  @override
  State<NavbarItem> createState() => _NavbarItemState();
}

class _NavbarItemState extends State<NavbarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  late Animation<Color?> iconColorAnimation;
  late Animation<Color?> bgColorAnimation;
  late Animation<double> fontSizeAnimation;
  late Animation<double> fontWeight;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      // Set initial value directly so the visual state matches widget.isSelected
      value: widget.isSelected ? 1.0 : 0.0,
    );

    final curved = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    );

    scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(curved);

    iconColorAnimation = ColorTween(
      begin: CustomTheme.navBarItemUnselectedColor,
      end: CustomTheme.navBarItemSelectedColor,
    ).animate(curved);

    bgColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: CustomTheme.primaryColor.withAlpha(50),
    ).animate(curved);

    fontSizeAnimation = Tween<double>(begin: 11.0, end: 12.0).animate(curved);

    // drives font weight interpolation
    fontWeight = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
  }

  // Retrigger animation on selection change
  @override
  void didUpdateWidget(NavbarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      animationController.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTabTapped(widget.index),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              final iconColor = iconColorAnimation.value!;
              final bgColor = bgColorAnimation.value!;
              final fontSize = fontSizeAnimation.value;
              final fontWeight = FontWeight.lerp(
                FontWeight.w500,
                FontWeight.bold,
                this.fontWeight.value,
              );
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                    ),
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: Icon(widget.icon, color: iconColor, size: 32),
                    ),
                  ),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
