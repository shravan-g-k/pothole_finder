import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapsRepo {
  final backendEndpoint = '${dotenv.env['BACKEND_URL']!}/navigation';

  Future<String> getRoute(List<Map<String, double>> waypoints) async {
    if (waypoints.length < 2) {
      throw Exception('At least two waypoints are required to get a route.');
    }
    final url =
        waypoints.length == 2
            ? '$backendEndpoint/get-route-polyline?startLat=${waypoints[0]['lat']}&startLng=${waypoints[0]['lng']}&endLat=${waypoints[1]['lat']}&endLng=${waypoints[1]['lng']}'
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
          waypoints.map((point) => [point['lat'], point['lng']]).toList();
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
}
