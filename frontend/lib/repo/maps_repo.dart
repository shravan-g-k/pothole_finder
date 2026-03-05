import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/place_model/place_model.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsRepo {
  final backendEndpoint = '${dotenv.env['BACKEND_URL']!}/navigation';

  Future<String> getRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      throw Exception('At least two waypoints are required to get a route.');
    }
    final url =
        waypoints.length == 2
            ? '$backendEndpoint/get-route-polyline?startLat=${waypoints[0].latitude}&startLng=${waypoints[0].longitude}&endLat=${waypoints[1].latitude}&endLng=${waypoints[1].longitude}'
            : '$backendEndpoint/get-multi-route-polyline';

    if (waypoints.length == 2) {
      // GET request for two points
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to get route: ${response.body}');
      }
    } else {
      // POST request for multiple points
      final coordinates =
          waypoints.map((point) => [point.latitude, point.longitude]).toList();
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'coordinates': coordinates}),
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to get route: ${response.body}');
      }
    }
  }

  List<LatLng> convertToLatLng(String encodedString) {
    // Decodes the string into a list of PointLatLng
    final polyline = decodePolyline(encodedString);

    // Convert PointLatLng to Google Maps LatLng
    return polyline
        .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
        .toList();
  }

  List<LatLng> changeGeoJsonToLatLng(List<List<double>> encodedString) {
    //flip the values  in the list since geojson is in the format [lng, lat] and we need [lat, lng]
    return encodedString.map((point) => LatLng(point[1], point[0])).toList();
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
