import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:convert';


final Map<String, LatLng> venueCoordinates = {
    // 'Old Gymkhana': const LatLng(26.1879, 91.6938),
    // 'Lake': const LatLng(26.1862, 91.6974),
    // 'Cricket Ground': const LatLng(26.1905, 91.6998),
    // 'Lecture Hall 1': const LatLng(26.1920, 91.6950),
    // 'Conference Hall 3': const LatLng(26.1925, 91.6955),
    // 'Main Auditorium': const LatLng(26.1915, 91.6945),
    // 'Mini Audi': const LatLng(26.1918, 91.6948),
    // 'Near Library Ground': const LatLng(26.1900, 91.6960),
    // 'Conference Room (New Sac)': const LatLng(26.1895, 91.6980),
    // 'Swimming Pool Area': const LatLng(26.1910, 91.7005),
    // 'Starts from Subansiri': const LatLng(26.1855, 91.6940),
    // 'Conference Hall (Foyer)': const LatLng(26.1923, 91.6958),
    // 'New Sac Conference Hall': const LatLng(26.1897, 91.6982),
    // 'Conference Hall 2': const LatLng(26.1927, 91.6957),
};

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Position? currentPosition;
  double rotation = 0.0;
  bool isDarkMode = true;
  Set<String> _venues = {};
  String? _selectedVenue;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _fetchVenues();
  }

  Future<void> _fetchVenues() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    final scheduleJsonString = remoteConfig.getString('fest_schedule_json');
    if (scheduleJsonString.isNotEmpty) {
      final scheduleData = json.decode(scheduleJsonString);
      final Set<String> allVenues = {};
      final List<dynamic> days = scheduleData['days'] ?? [];

      for (var day in days) {
        final List<dynamic> events = day['events'] ?? [];
        for (var event in events) {
          if (event['venue'] != null) {
            allVenues.add(event['venue']);
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _venues = allVenues;
        });
      }
    }
  }

  Future<void> getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      _setDefaultLocation();
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          currentPosition = position;
        });
        _mapController.move(LatLng(position.latitude, position.longitude), 17.0);
      }
    } catch (e) {
      _setDefaultLocation();
      print("Error getting location: $e");
    }
  }

  void toggleMapTheme() {
    if (mounted) {
      setState(() {
        isDarkMode = !isDarkMode;
      });
    }
  }

  void resetRotation() {
    if (mounted) {
      setState(() {
        rotation = 0.0;
        _mapController.rotate(0.0);
      });
    }
  }

  Future<bool> _handleLocationPermission() async {
    return true;
  }

  void _setDefaultLocation() {
    if (mounted) {
      _mapController.move(const LatLng(26.1923, 91.6951), 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(26.1923, 91.6951),
        initialZoom: 16.0,
        maxZoom: 18.0,
        minZoom: 14.0,
        onTap: (_, __) {
          setState(() {
            _selectedVenue = null;
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.techniche.techniche_app',
          tileBuilder: isDarkMode ? (context, tileWidget, tile) {
            return ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                -1, 0, 0, 0, 255,
                0, -1, 0, 0, 255,
                0, 0, -1, 0, 255,
                0, 0, 0, 1, 0,
              ]),
              child: tileWidget,
            );
          } : null,
        ),
        MarkerLayer(
          markers: _venues.map((venueName) {
            final venueCoord = venueCoordinates[venueName];
            if (venueCoord == null) return null;

            final isSelected = _selectedVenue == venueName;

            return Marker(
              point: venueCoord,
              width: 150, 
              height: 80,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVenue = venueName;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0,2))
                          ]
                        ),
                        child: Text(
                          venueName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0, // Smaller text
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Icon(
                      Icons.location_on,
                      color: isSelected ? Colors.blueAccent : Colors.redAccent,
                      size: isSelected ? 40 : 30, 
                      shadows: [
                         BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).whereType<Marker>().toList(),
        ),
        if (currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                width: 80,
                height: 80,
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.shade400,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.7),
                          blurRadius: 20,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
