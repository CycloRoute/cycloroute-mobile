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

class RouteCoveragePoint {
  const RouteCoveragePoint({
    required this.latitude,
    required this.longitude,
    this.coverage,
    this.scored,
  });

  final double latitude;
  final double longitude;
  final double? coverage;
  final bool? scored;

  factory RouteCoveragePoint.fromJson(Map<String, dynamic> json) {
    return RouteCoveragePoint(
      latitude: (json['latitude'] as num? ?? json['lat'] as num? ?? 0)
          .toDouble(),
      longitude: (json['longitude'] as num? ?? json['lng'] as num? ?? 0)
          .toDouble(),
      coverage: (json['coverage'] as num?)?.toDouble(),
      scored: json['scored'] as bool?,
    );
  }
}
