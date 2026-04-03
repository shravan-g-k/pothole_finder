import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/place_model/place_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:brotli/brotli.dart';

class MapsRepo {
  final backendEndpoint = '${dotenv.env['BACKEND_URL']!}/navigation';

  /// Fetch the route between two points.
  Future<Map<String, dynamic>> getRoute(LatLng start, LatLng end) async {
    final url =
        '$backendEndpoint/get-route-polyline?startLat=${start.latitude}&startLng=${start.longitude}&endLat=${end.latitude}&endLng=${end.longitude}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get route: ${response.body}');
    }
  }

  /// Decodes Mapbox/Google Polyline to List-LatLng
  List<LatLng> decodeRoutePolyline(String encoded) {
    if (encoded.isEmpty) return [];
    final List<List<num>> decoded = decodePolyline(encoded);
    return decoded
        .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
        .toList();
  }

  // Decompresses Brotli-compressed base64 segments string to List<dynamic>
  List<dynamic> decompressSegments(String compressedBase64) {
    if (compressedBase64.isEmpty) return [];
    try {
      final List<int> compressedBytes = base64Decode(compressedBase64);
      final List<int> decompressedBytes = brotli.decode(compressedBytes);
      final String jsonStr = utf8.decode(decompressedBytes);
      return jsonDecode(jsonStr);
    } catch (e) {
      return [];
    }
  }

  Set<Polyline> createPolylines(List<LatLng> routePoints) {
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: const Color(0xFF4285F4),
        width: 5,
      ),
    };
  }

  Future<List<PlaceModel>> getTextSearchResults(String query) async {
    final Uri uri = Uri.parse(
      '$backendEndpoint/places-text-search?query=$query',
    );

    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => PlaceModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch search results: ${response.body}');
    }
  }
}
