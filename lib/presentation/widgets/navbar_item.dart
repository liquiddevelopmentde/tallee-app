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

  /// The index of the tab.
  final int index;

  /// A boolean indicating whether the tab is currently selected.
  final bool isSelected;

  /// The icon to display for the tab.
  final IconData icon;

  /// The label to display for the tab.
  final String label;

  /// The callback to be invoked when the tab is tapped.
  final Function(int) onTabTapped;

  @override
  State<NavbarItem> createState() => _NavbarItemState();
}

class _NavbarItemState extends State<NavbarItem>
    with SingleTickerProviderStateMixin {
  /// Animation controller for the scale animation
  late AnimationController _animationController;

  /// Scale animation for the icon when selected
  late Animation<double> _scaleAnimation;

  /// Color animation for the icon
  late Animation<Color?> _iconColorAnimation;

  /// Background color animation for the icon container
  late Animation<Color?> _bgColorAnimation;

  /// Font size animation for the label
  late Animation<double> _fontSizeAnimation;

  /// A simple double tween used to lerp between two font weights
  late Animation<double> _fontWeightT;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      // Set initial value directly so the visual state matches widget.isSelected
      value: widget.isSelected ? 1.0 : 0.0,
    );

    final curved = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(curved);

    _iconColorAnimation = ColorTween(
      begin: CustomTheme.navBarItemUnselectedColor,
      end: CustomTheme.navBarItemSelectedColor,
    ).animate(curved);

    _bgColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: CustomTheme.primaryColor.withAlpha(50),
    ).animate(curved);

    _fontSizeAnimation = Tween<double>(begin: 11.0, end: 12.0).animate(curved);

    // drives font weight interpolation
    _fontWeightT = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
  }

  // Retrigger animation on selection change
  @override
  void didUpdateWidget(NavbarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _animationController.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _animationController.reverse();
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
            animation: _animationController,
            builder: (context, child) {
              final iconColor = _iconColorAnimation.value!;
              final bgColor = _bgColorAnimation.value!;
              final fontSize = _fontSizeAnimation.value;
              final fontWeight = FontWeight.lerp(
                FontWeight.w500,
                FontWeight.bold,
                _fontWeightT.value,
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
                      scale: _scaleAnimation,
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
    _animationController.dispose();
    super.dispose();
  }
}
