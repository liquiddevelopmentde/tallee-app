import 'package:material_ui/material_ui.dart';

/// Holds the search state of the main menu tabs, identified by the
/// widget type of the tab's view.
class SearchProvider extends ChangeNotifier {
  /// Views with active search mode.
  final Set<Type> _searchingViews = {};

  /// Views whose search bar is currently hidden by scrolling down.
  final Set<Type> _hiddenSearchBarViews = {};

  /// Whether the search mode is active in [view].
  bool isSearching(Type view) => _searchingViews.contains(view);

  /// Whether the search bar of [view] is currently shown while isSearching == true.
  bool isSearchBarVisible(Type view) => !_hiddenSearchBarViews.contains(view);

  /// Toggles the search mode of [view].
  void toggleSearch(Type view) {
    if (!_searchingViews.remove(view)) _searchingViews.add(view);
    _hiddenSearchBarViews.remove(view);
    notifyListeners();
  }

  /// Shows or hides the search bar of [view].
  void setSearchBarVisible({required Type view, bool visible = true}) {
    final changed = visible
        ? _hiddenSearchBarViews.remove(view)
        : _hiddenSearchBarViews.add(view);
    if (changed) notifyListeners();
  }
}
