import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SearchBarScrollListener extends StatelessWidget {
  /// Listens to user scroll events of [child] and reports via
  /// [onVisibilityChanged] whether a search bar above the list should be
  /// visible: scrolling down hides it, scrolling up shows it.
  /// - [isSearchBarVisible]: Current visibility of the search bar
  /// - [onVisibilityChanged]: Called when the visibility of the search bar should change
  /// - [child]: The child widget
  const SearchBarScrollListener({
    super.key,
    required this.isSearchBarVisible,
    required this.onVisibilityChanged,
    required this.child,
  });

  final bool isSearchBarVisible;
  final ValueChanged<bool> onVisibilityChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse &&
              isSearchBarVisible) {
            // User scrolls down
            onVisibilityChanged(false);
          } else if (notification.direction == ScrollDirection.forward &&
              !isSearchBarVisible) {
            // User scrolls up
            onVisibilityChanged(true);
          }
          return true;
        },
        child: child,
      );
}
