/// Builds voice prompts from backend [instruction] text without rewriting it.
class NavigationTtsPrompt {
  static const approachBuckets = [250, 100, 50, 30];
  static const stepReachedThresholdM = 25;

  /// Speaks backend copy as-is, optionally prefixed with live distance.
  static String build({
    required String instruction,
    int? distanceM,
    String Function(int meters)? distanceFormatter,
  }) {
    final text = instruction.trim();
    if (text.isEmpty) {
      return '';
    }

    if (distanceM != null &&
        distanceM > 0 &&
        distanceM <= 900 &&
        distanceFormatter != null) {
      return '${distanceFormatter(distanceM)}, $text';
    }

    return text;
  }

  /// Returns the nearest approach bucket for [distanceM] that has not been
  /// announced yet. At 30 m only bucket 30 fires, not 250/100/50/30 in cascade.
  static int? nextApproachBucket({
    required int distanceM,
    required Set<int> announcedBuckets,
  }) {
    int? nearestBucket;
    for (final bucket in approachBuckets) {
      if (distanceM <= bucket) {
        nearestBucket = nearestBucket == null
            ? bucket
            : (bucket < nearestBucket ? bucket : nearestBucket);
      }
    }

    if (nearestBucket == null || announcedBuckets.contains(nearestBucket)) {
      return null;
    }

    return nearestBucket;
  }
}
