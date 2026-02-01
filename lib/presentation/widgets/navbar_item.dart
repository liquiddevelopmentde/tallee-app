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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );

    if (widget.isSelected) {
      _animationController.forward();
    }
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: widget.isSelected
                    ? _scaleAnimation
                    : const AlwaysStoppedAnimation(1.0),
                child: Icon(
                  widget.icon,
                  color: widget.isSelected
                      ? CustomTheme.navBarItemSelectedColor
                      : CustomTheme.navBarItemUnselectedColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected
                      ? CustomTheme.navBarItemSelectedColor
                      : CustomTheme.navBarItemUnselectedColor,
                  fontSize: widget.isSelected ? 12 : 11,
                  fontWeight: widget.isSelected
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ],
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
