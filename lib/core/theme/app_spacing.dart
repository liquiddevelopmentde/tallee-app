import 'package:material_ui/material_ui.dart';

/// Spacing values (paddings and margins) used across the app.
abstract final class AppSpacing {
  /// Default width of full-width elements (buttons, tiles)
  /// relative to the screen width.
  static const double contentWidthFactor = 0.95;

  /// Horizontal page padding for content that isn't inside a tile.
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 12);

  static const EdgeInsets standardMargin = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );

  /// Margin for tiles.
  static const EdgeInsets tileMargin = EdgeInsets.only(
    left: 12,
    right: 12,
    bottom: 10,
  );

  /// Bottom padding for scrollable lists so the last item isn't covered by
  /// floating buttons or the navigation bar.
  static EdgeInsets listViewPadding(BuildContext context) =>
      EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom + 190);

  /// Distance of floating buttons from the bottom edge, above the system
  /// navigation / home indicator.
  static double floatingButtonBottom(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + 20;

  /// Padding for the row of filters.
  static const EdgeInsets filterRowPadding = EdgeInsets.only(
    bottom: 10,
    left: 12,
  );
}
