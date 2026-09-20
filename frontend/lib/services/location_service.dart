import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart' as native_geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'api_config.dart';

class PlaceSuggestion {
  final String label;
  final double lat;
  final double lng;

  const PlaceSuggestion({
    required this.label,
    required this.lat,
    required this.lng,
  });

  LatLng get point => LatLng(lat, lng);
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
    ),
  );

  final Dio _nominatim = Dio(
    BaseOptions(
      baseUrl: 'https://nominatim.openstreetmap.org',
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        'User-Agent': 'InstaCat/1.0 (ai-engineer-course)',
        'Accept-Language': 'en',
      },
    ),
  );

  Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please turn them on.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. Enable it in Settings.',
      );
    }
    return true;
  }

  Future<LatLng> getCurrentLatLng() async {
    await ensurePermission();
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return LatLng(pos.latitude, pos.longitude);
  }

  Future<String> reverseGeocode(LatLng point) async {
    final apiKey = ApiConfig.googleMapsApiKey;
    if (apiKey.isNotEmpty) {
      try {
        final label = await _reverseGeocodeGoogle(point, apiKey);
        if (label.isNotEmpty) return label;
      } catch (_) {
        // Fall back on error
      }
    }

    try {
      final placemarks = await native_geo.Geocoding().placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (placemarks.isNotEmpty) {
        final label = _formatPlacemark(placemarks.first);
        if (label.isNotEmpty) return label;
      }
    } catch (_) {
      // Fall through to Nominatim (needed on some platforms / web).
    }

    return _reverseGeocodeNominatim(point);
  }

  Future<String> _reverseGeocodeGoogle(LatLng point, String apiKey) async {
    final response = await _dio.get(
      'https://maps.googleapis.com/maps/api/geocode/json',
      queryParameters: {
        'latlng': '${point.latitude},${point.longitude}',
        'key': apiKey,
        'language': 'th',
      },
    );
    final data = response.data;
    if (data is Map && data['results'] is List) {
      final results = data['results'] as List;
      if (results.isNotEmpty && results.first is Map) {
        final first = results.first as Map;
        final formatted = first['formatted_address']?.toString().trim() ?? '';
        if (formatted.isNotEmpty) return formatted;
      }
    }
    return '';
  }

  Future<String> _reverseGeocodeNominatim(LatLng point) async {
    try {
      final response = await _nominatim.get(
        '/reverse',
        queryParameters: {
          'lat': point.latitude,
          'lon': point.longitude,
          'format': 'jsonv2',
          'zoom': 18,
          'addressdetails': 1,
        },
      );
      final data = response.data;
      if (data is Map) {
        final label = _formatNominatim(Map<String, dynamic>.from(data));
        if (label.isNotEmpty) return label;
      }
    } catch (_) {}

    return '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
  }

  Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final apiKey = ApiConfig.googleMapsApiKey;
    if (apiKey.isNotEmpty) {
      try {
        final results = await _searchGooglePlaces(q, apiKey);
        if (results.isNotEmpty) return results;
      } catch (_) {
        // Fall back to Nominatim on error
      }
    }

    return _searchNominatim(q);
  }

  Future<List<PlaceSuggestion>> _searchGooglePlaces(
    String q,
    String apiKey,
  ) async {
    final response = await _dio.get(
      'https://maps.googleapis.com/maps/api/place/textsearch/json',
      queryParameters: {
        'query': q,
        'key': apiKey,
        'language': 'th',
      },
    );

    final data = response.data;
    if (data is Map && data['results'] is List) {
      final results = data['results'] as List;
      return results.whereType<Map>().map((item) {
        final name = item['name']?.toString() ?? '';
        final address = item['formatted_address']?.toString() ?? '';
        final location =
            (item['geometry'] is Map) ? item['geometry']['location'] : null;
        final lat = double.tryParse(location?['lat']?.toString() ?? '') ?? 0;
        final lng = double.tryParse(location?['lng']?.toString() ?? '') ?? 0;

        final label = name.isNotEmpty
            ? (address.isNotEmpty && !address.startsWith(name)
                ? '$name ($address)'
                : name)
            : address;

        return PlaceSuggestion(
          label: label,
          lat: lat,
          lng: lng,
        );
      }).where((p) => p.label.isNotEmpty && (p.lat != 0 || p.lng != 0)).toList();
    }
    return const [];
  }

  Future<List<PlaceSuggestion>> _searchNominatim(String q) async {
    final response = await _nominatim.get(
      '/search',
      queryParameters: {
        'q': q,
        'format': 'jsonv2',
        'addressdetails': 1,
        'limit': 15,
      },
    );

    final list = response.data is List ? response.data as List : const [];
    return list.whereType<Map>().map((raw) {
      final map = Map<String, dynamic>.from(raw);
      final lat = double.tryParse(map['lat']?.toString() ?? '') ?? 0;
      final lng = double.tryParse(map['lon']?.toString() ?? '') ?? 0;
      return PlaceSuggestion(
        label: _formatNominatim(map),
        lat: lat,
        lng: lng,
      );
    }).where((p) => p.label.isNotEmpty).toList();
  }

  String _formatPlacemark(native_geo.Placemark p) {
    final parts = <String>[
      if ((p.name ?? '').trim().isNotEmpty &&
          p.name != p.locality &&
          p.name != p.street)
        p.name!.trim(),
      if ((p.street ?? '').trim().isNotEmpty) p.street!.trim(),
      if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
      if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
      if ((p.administrativeArea ?? '').trim().isNotEmpty)
        p.administrativeArea!.trim(),
      if ((p.country ?? '').trim().isNotEmpty) p.country!.trim(),
    ];

    final seen = <String>{};
    final unique = <String>[];
    for (final part in parts) {
      final key = part.toLowerCase();
      if (seen.add(key)) unique.add(part);
    }
    return unique.take(3).join(', ');
  }

  String _formatNominatim(Map<String, dynamic> data) {
    final display = data['display_name']?.toString().trim() ?? '';
    if (display.isEmpty) return '';

    final address = data['address'] is Map
        ? Map<String, dynamic>.from(data['address'] as Map)
        : const <String, dynamic>{};

    final preferred = <String>[
      _firstNonEmpty(address, [
        'amenity',
        'shop',
        'tourism',
        'leisure',
        'building',
        'road',
        'neighbourhood',
        'suburb',
        'city_district',
      ]),
      _firstNonEmpty(address, ['city', 'town', 'village', 'municipality']),
      _firstNonEmpty(address, ['state', 'province']),
      _firstNonEmpty(address, ['country']),
    ].where((s) => s.isNotEmpty).toList();

    if (preferred.isNotEmpty) {
      final seen = <String>{};
      final unique = <String>[];
      for (final part in preferred) {
        if (seen.add(part.toLowerCase())) unique.add(part);
      }
      return unique.take(3).join(', ');
    }

    final bits =
        display.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
    return bits.take(3).join(', ');
  }

  String _firstNonEmpty(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }
}
