import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class DirectionsService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/walking';

  Future<List<LatLng>> getDirections(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$startLng,$startLat;$endLng,$endLat?overview=full&geometries=geojson'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
          final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
          
          // Convert coordinates from [lng, lat] to LatLng
          return coordinates
              .map((point) => LatLng(point[1] as double, point[0] as double))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting directions: $e');
      return [];
    }
  }
}

