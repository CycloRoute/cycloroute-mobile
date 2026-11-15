import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_results/data/models/saved_route_meta.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class SavedRouteItem {
  const SavedRouteItem({
    required this.id,
    required this.name,
    required this.routeId,
    this.routePayload,
    this.meta,
    this.createdAt,
  });

  final String id;
  final String name;
  final String routeId;
  final RouteOption? routePayload;
  final SavedRouteMeta? meta;
  final DateTime? createdAt;

  GeoPoint? get origin => meta?.origin ?? _coordinatesEndpoints?.origin;
  GeoPoint? get destination =>
      meta?.destination ?? _coordinatesEndpoints?.destination;
  String? get originLabel => meta?.originLabel;
  String? get destinationLabel => meta?.destinationLabel;

  ({GeoPoint origin, GeoPoint destination})? get _coordinatesEndpoints {
    final coordinates = routePayload?.coordinates ?? const <GeoPoint>[];
    if (coordinates.length < 2) {
      return null;
    }
    return (origin: coordinates.first, destination: coordinates.last);
  }

  bool get canNavigate =>
      routePayload != null && origin != null && destination != null;

  factory SavedRouteItem.fromJson(Map<String, dynamic> json) {
    final payload = json['route_payload'];
    RouteOption? routeOption;
    SavedRouteMeta? meta;

    if (payload is Map<String, dynamic>) {
      final metaJson = payload[SavedRouteMeta.storageKey];
      if (metaJson is Map<String, dynamic>) {
        meta = SavedRouteMeta.fromJson(metaJson);
      }
      routeOption = RouteOption.fromJson(payload);
    }

    return SavedRouteItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Saved route',
      routeId: json['route_id']?.toString() ?? '',
      routePayload: routeOption,
      meta: meta,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}

class RouteHistoryItem {
  const RouteHistoryItem({
    required this.id,
    required this.routeId,
    this.name,
    this.createdAt,
    this.routePayload,
    this.meta,
  });

  final String id;
  final String routeId;
  final String? name;
  final DateTime? createdAt;
  final RouteOption? routePayload;
  final SavedRouteMeta? meta;

  GeoPoint? get origin => meta?.origin ?? _coordinatesEndpoints?.origin;
  GeoPoint? get destination =>
      meta?.destination ?? _coordinatesEndpoints?.destination;
  String? get originLabel => meta?.originLabel;
  String? get destinationLabel => meta?.destinationLabel;

  ({GeoPoint origin, GeoPoint destination})? get _coordinatesEndpoints {
    final coordinates = routePayload?.coordinates ?? const <GeoPoint>[];
    if (coordinates.length < 2) {
      return null;
    }
    return (origin: coordinates.first, destination: coordinates.last);
  }

  bool get canNavigate =>
      routePayload != null && origin != null && destination != null;

  String get listTitle {
    final origin = originLabel?.trim();
    final destination = destinationLabel?.trim();
    if (origin != null &&
        origin.isNotEmpty &&
        destination != null &&
        destination.isNotEmpty) {
      return '$origin → $destination';
    }
    if (destination != null && destination.isNotEmpty) {
      return destination;
    }
    return displayTitle;
  }

  double distanceForDisplayM() {
    return meta?.traveledDistanceM ?? routePayload?.distanceM ?? 0;
  }

  bool get endedBeforeArrival => meta?.rideCompleted == false;

  String get displayTitle {
    if (name?.trim().isNotEmpty == true) {
      return name!.trim();
    }
    if (destinationLabel?.trim().isNotEmpty == true) {
      return destinationLabel!.trim();
    }
    final routeName = routePayload?.name;
    if (routeName != null &&
        routeName.trim().isNotEmpty &&
        routeName != routeId) {
      return routeName;
    }
    return routeId;
  }

  factory RouteHistoryItem.fromJson(Map<String, dynamic> json) {
    final payload = json['selected_route'] ?? json['route_payload'];
    RouteOption? routeOption;
    SavedRouteMeta? meta;

    if (payload is Map<String, dynamic>) {
      final metaJson = payload[SavedRouteMeta.storageKey];
      if (metaJson is Map<String, dynamic>) {
        meta = SavedRouteMeta.fromJson(metaJson);
      }
      routeOption = RouteOption.fromJson(payload);
    }

    if (meta == null) {
      final originJson = json['origin'];
      final destinationJson = json['destination'];
      if (originJson is Map<String, dynamic> &&
          destinationJson is Map<String, dynamic>) {
        meta = SavedRouteMeta(
          origin: GeoPoint.fromJson(originJson),
          destination: GeoPoint.fromJson(destinationJson),
        );
      }
    }

    final routeId =
        json['route_id']?.toString() ?? routeOption?.routeId ?? '';

    return RouteHistoryItem(
      id: json['id']?.toString() ?? '',
      routeId: routeId,
      name: json['name']?.toString(),
      routePayload: routeOption,
      meta: meta,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}

class RouteCoverageArea {
  const RouteCoverageArea({
    required this.id,
    required this.name,
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  final String id;
  final String name;
  final double south;
  final double west;
  final double north;
  final double east;

  factory RouteCoverageArea.fromJson(Map<String, dynamic> json) {
    final bbox = json['bbox'];
    final box = bbox is Map ? Map<String, dynamic>.from(bbox) : const {};
    return RouteCoverageArea(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      south: (box['south'] as num?)?.toDouble() ?? 0,
      west: (box['west'] as num?)?.toDouble() ?? 0,
      north: (box['north'] as num?)?.toDouble() ?? 0,
      east: (box['east'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RouteCoverageSnapshot {
  const RouteCoverageSnapshot({required this.areas});

  final List<RouteCoverageArea> areas;

  bool get isEmpty => areas.isEmpty;

  factory RouteCoverageSnapshot.fromDecoded(dynamic decoded) {
    if (decoded is! Map) {
      return const RouteCoverageSnapshot(areas: []);
    }
    final raw = decoded['covered_areas'];
    if (raw is! List) {
      return const RouteCoverageSnapshot(areas: []);
    }

    final areas = <RouteCoverageArea>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      areas.add(RouteCoverageArea.fromJson(Map<String, dynamic>.from(entry)));
    }
    return RouteCoverageSnapshot(areas: areas);
  }
}
