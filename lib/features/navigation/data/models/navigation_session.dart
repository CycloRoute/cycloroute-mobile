import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

enum NavigationSessionStatus { active, completed, cancelled }

class NavigationSession {
  const NavigationSession({
    required this.id,
    required this.destination,
    required this.activeRouteId,
    required this.status,
    required this.rerouteCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastKnown,
    this.lastRerouteAt,
  });

  final String id;
  final GeoPoint destination;
  final RoutePreference activeRouteId;
  final NavigationSessionStatus status;
  final GeoPoint? lastKnown;
  final DateTime? lastRerouteAt;
  final int rerouteCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory NavigationSession.fromJson(Map<String, dynamic> json) {
    return NavigationSession(
      id: json['id']?.toString() ?? '',
      destination: GeoPoint.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      activeRouteId: RoutePreference.fromApi(
        json['active_route_id']?.toString(),
      ),
      status: _statusFromApi(json['status']?.toString()),
      lastKnown: json['last_known'] is Map<String, dynamic>
          ? GeoPoint.fromJson(json['last_known'] as Map<String, dynamic>)
          : null,
      lastRerouteAt: json['last_reroute_at'] == null
          ? null
          : DateTime.tryParse(json['last_reroute_at'].toString()),
      rerouteCount: (json['reroute_count'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination.toJson(),
      'active_route_id': activeRouteId.apiValue,
      'status': status.name,
      if (lastKnown != null) 'last_known': lastKnown!.toJson(),
      if (lastRerouteAt != null)
        'last_reroute_at': lastRerouteAt!.toUtc().toIso8601String(),
      'reroute_count': rerouteCount,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  static NavigationSessionStatus _statusFromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'completed':
        return NavigationSessionStatus.completed;
      case 'cancelled':
        return NavigationSessionStatus.cancelled;
      default:
        return NavigationSessionStatus.active;
    }
  }
}
