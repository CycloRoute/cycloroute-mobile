import 'dart:convert';

import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';
import 'package:cyclerisk/features/route_search/data/models/place_suggestion_kind.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.name,
    required this.address,
    required this.point,
    this.kind = PlaceSuggestionKind.search,
  });

  final String name;
  final String address;
  final GeoPoint point;
  final PlaceSuggestionKind kind;

  String get title => name.trim().isEmpty ? address : name;

  String localizedTitle(AppLocalizations l10n) {
    switch (kind) {
      case PlaceSuggestionKind.currentLocation:
        return l10n.currentLocation;
      case PlaceSuggestionKind.mapPick:
        return name.trim().isEmpty ? l10n.mapSelectedLocation : name;
      case PlaceSuggestionKind.search:
        return title;
    }
  }

  String subtitleFor(AppLocalizations l10n) {
    if (kind == PlaceSuggestionKind.currentLocation) {
      return '${point.lat.toStringAsFixed(6)}, ${point.lng.toStringAsFixed(6)}';
    }

    final subtitle = address == title ? '' : address;
    if (subtitle.isNotEmpty) {
      return subtitle;
    }

    return '${point.lat.toStringAsFixed(6)}, ${point.lng.toStringAsFixed(6)}';
  }

  String get subtitle => address == title ? '' : address;

  bool isSameLocationAs(PlaceSuggestion other) {
    const epsilon = 0.00001;
    return (point.lat - other.point.lat).abs() < epsilon &&
        (point.lng - other.point.lng).abs() < epsilon;
  }

  factory PlaceSuggestion.currentLocation(GeoPoint point) {
    return PlaceSuggestion(
      name: '',
      address:
          '${point.lat.toStringAsFixed(6)}, ${point.lng.toStringAsFixed(6)}',
      point: point,
      kind: PlaceSuggestionKind.currentLocation,
    );
  }

  factory PlaceSuggestion.mapPick({
    required GeoPoint point,
    required String label,
    String address = '',
  }) {
    return PlaceSuggestion(
      name: label,
      address: address,
      point: point,
      kind: PlaceSuggestionKind.mapPick,
    );
  }

  factory PlaceSuggestion.fromNominatimJson(
    Map<String, dynamic> json, {
    PlaceSuggestionKind kind = PlaceSuggestionKind.search,
  }) {
    final displayName = json['display_name']?.toString() ?? 'Selected place';
    final address = json['address'] is Map<String, dynamic>
        ? json['address'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final name = json['name']?.toString().trim().isNotEmpty == true
        ? json['name'].toString()
        : (address['road'] ??
                  address['amenity'] ??
                  address['suburb'] ??
                  address['city'] ??
                  displayName)
              .toString();

    return PlaceSuggestion(
      name: name,
      address: displayName,
      point: GeoPoint(
        lat: double.parse(json['lat'].toString()),
        lng: double.parse(json['lon'].toString()),
      ),
      kind: kind,
    );
  }

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      point: GeoPoint.fromJson(json['point'] as Map<String, dynamic>),
      kind: PlaceSuggestionKind.fromStorage(json['kind']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'point': point.toJson(),
      'kind': kind.storageValue,
    };
  }

  Map<String, dynamic> toRecentPlaceRequest(String type) {
    return {
      'type': type,
      'name': name,
      'address': address,
      'point': point.toJson(),
      'kind': kind.storageValue,
    };
  }

  String encode() => jsonEncode(toJson());

  static PlaceSuggestion? tryDecode(String value) {
    try {
      return PlaceSuggestion.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
