enum ObstacleCategory {
  blockedLane('blocked_lane'),
  construction('construction'),
  surfaceDamage('surface_damage'),
  debris('debris'),
  other('other');

  const ObstacleCategory(this.apiValue);

  final String apiValue;

  static ObstacleCategory fromApi(String? value) {
    return ObstacleCategory.values.firstWhere(
      (item) => item.apiValue == value?.trim().toLowerCase(),
      orElse: () => ObstacleCategory.other,
    );
  }
}

enum ObstacleSeverity {
  low('low'),
  medium('medium'),
  high('high');

  const ObstacleSeverity(this.apiValue);

  final String apiValue;

  static ObstacleSeverity fromApi(String? value) {
    return ObstacleSeverity.values.firstWhere(
      (item) => item.apiValue == value?.trim().toLowerCase(),
      orElse: () => ObstacleSeverity.medium,
    );
  }
}
