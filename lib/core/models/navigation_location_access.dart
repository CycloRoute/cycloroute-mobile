/// Location access level relevant for turn-by-turn navigation in background.
enum NavigationLocationAccess {
  /// No usable location permission.
  denied,

  /// While-in-use only. Navigation may pause when the screen is off (especially iOS).
  foregroundOnly,

  /// Always / background location granted.
  background,
}

extension NavigationLocationAccessX on NavigationLocationAccess {
  bool get isUsable =>
      this == NavigationLocationAccess.foregroundOnly ||
      this == NavigationLocationAccess.background;

  bool get hasBackgroundAccess => this == NavigationLocationAccess.background;
}
