import 'package:material_ui/material_ui.dart';

/// Spacing values (paddings and margins) used across the app.
class AppSpacing {
  // Private constructor
  const AppSpacing._();

  static EdgeInsets get standardMargin =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

  static EdgeInsets get tileMargin =>
      const EdgeInsets.only(left: 12, right: 12, bottom: 10);

  /// Bottom padding for scrollable lists so the last item isn't covered by
  /// floating buttons or the navigation bar.
  static EdgeInsets listViewPadding(BuildContext context) =>
      EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom + 190);

  static EdgeInsets get filterRowPadding =>
      const EdgeInsets.only(bottom: 10, left: 12);
}
