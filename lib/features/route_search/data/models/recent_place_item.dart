import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';
import 'package:cyclerisk/features/route_search/data/models/place_suggestion.dart';
import 'package:cyclerisk/features/route_search/data/models/place_suggestion_kind.dart';

class RecentPlaceItem {
  const RecentPlaceItem({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
    required this.point,
    required this.kind,
    required this.lastUsedAt,
  });

  final String id;
  final String type;
  final String name;
  final String address;
  final GeoPoint point;
  final PlaceSuggestionKind kind;
  final DateTime lastUsedAt;

  factory RecentPlaceItem.fromJson(Map<String, dynamic> json) {
    return RecentPlaceItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'destination',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      point: GeoPoint.fromJson(json['point'] as Map<String, dynamic>),
      kind: PlaceSuggestionKind.fromStorage(json['kind']?.toString()),
      lastUsedAt: json['last_used_at'] == null
          ? DateTime.now()
          : DateTime.tryParse(json['last_used_at'].toString()) ?? DateTime.now(),
    );
  }

  PlaceSuggestion toPlaceSuggestion() {
    return PlaceSuggestion(
      name: name,
      address: address,
      point: point,
      kind: kind,
    );
  }
}

class RecentPlaceUpsertResponse {
  const RecentPlaceUpsertResponse({
    required this.item,
    required this.items,
  });

  final RecentPlaceItem item;
  final List<RecentPlaceItem> items;

  factory RecentPlaceUpsertResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return RecentPlaceUpsertResponse(
      item: RecentPlaceItem.fromJson(
        json['item'] as Map<String, dynamic>,
      ),
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(RecentPlaceItem.fromJson)
                .toList()
          : const [],
    );
  }

  List<PlaceSuggestion> toPlaceSuggestions() {
    return items.map((item) => item.toPlaceSuggestion()).toList();
  }
}
