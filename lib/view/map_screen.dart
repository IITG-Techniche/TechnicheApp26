import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:amazon_clone/model/event_model.dart';
import 'package:http/http.dart' as http;
import 'package:amazon_clone/services/directions_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoading = true;
  double _rotation = 0.0;
  bool _isDarkMode = true;

  // State for events and directions
  List<Event> _events = [];
  final DirectionsService _directionsService = DirectionsService();
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await Future.wait([
      _loadEvents(),
      _getCurrentLocation(),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

Future<void> _loadEvents() async {
  const String apiUrl = 'http://192.168.1.5:4000/api/events'; 

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      final data = json.decode(response.body) as List;
      if (mounted) {
        setState(() {
          _events = data.map((e) => Event.fromJson(e)).toList();
        });
      }
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load events');
    }
  } catch (e) {
    print("Error loading events from API: $e");
    if (mounted) {
      // Handle error, maybe show a message to the user
      setState(() {
        _events = [];
      });
    }
  }
}

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      _setDefaultLocation();
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _mapController.move(
              LatLng(position.latitude, position.longitude), 17.0);
        });
      }
    } catch (e) {
      _setDefaultLocation();
      print("Error getting location: $e");
    }
  }

  Future<void> _showLocationServiceDisabledDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Location Services'),
          content: const SingleChildScrollView(
            child: Text(
                'To see your location on the map, please enable location services.'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        await _showLocationServiceDisabledDialog();
      }
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Location permissions are denied.')));
        }
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied. Please enable them in your app settings.')));
      }
      return false;
    }
    return true;
  }

  void _setDefaultLocation() {}

  void _toggleMapTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  Future<void> _fetchAndDrawRoute(Event event) async {
    Navigator.pop(context);

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location not available.')),
      );
      return;
    }
    final route = await _directionsService.getDirections(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      event.latitude,
      event.longitude,
    );

    setState(() {
      _routePoints = route;
    });
    if (_routePoints.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(_routePoints);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50.0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double navBarHeight = kBottomNavigationBarHeight + 15;

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: const Text('Campus Map'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: _showEventList,
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: navBarHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_routePoints.isNotEmpty)
              FloatingActionButton(
                heroTag: 'clear_route',
                onPressed: () {
                  setState(() {
                    _routePoints = [];
                  });
                },
                backgroundColor: const Color(0xFF23242B),
                child: const Icon(Icons.clear, color: Colors.white),
              ),
            if (_routePoints.isNotEmpty) const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'theme',
              onPressed: _toggleMapTheme,
              backgroundColor: const Color(0xFF23242B),
              child: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'compass',
              onPressed: () {
                setState(() {
                  _rotation = 0.0;
                  _mapController.rotate(0.0);
                });
              },
              backgroundColor: const Color(0xFF23242B),
              child: Transform.rotate(
                angle: _rotation,
                child:
                    const Icon(Icons.navigation_rounded, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'location',
              onPressed: _getCurrentLocation,
              backgroundColor: const Color(0xFF23242B),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(26.1923, 91.6951),
                initialZoom: 16.0,
                maxZoom: 18.0,
                minZoom: 14.0,
              ),
              children: [
                // Map Theme Layer
                if (_isDarkMode)
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.techniche.techniche_app',
                    tileBuilder: (context, tileWidget, tile) {
                      return ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          -1,
                          0,
                          0,
                          0,
                          255,
                          0,
                          -1,
                          0,
                          0,
                          255,
                          0,
                          0,
                          -1,
                          0,
                          255,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                        child: tileWidget,
                      );
                    },
                  )
                else
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.techniche.techniche_app',
                  ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5.0,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: _events.map((event) {
                    return Marker(
                      point: LatLng(event.latitude, event.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _showEventDetails(event),
                        child: _buildEventMarker(event),
                      ),
                    );
                  }).toList(),
                ),
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude),
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
            ),
    );
  }

  Widget _buildEventMarker(Event event) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: event.isLive ? Colors.redAccent : const Color(0xFF23242B),
        border: Border.all(
          color: event.isLive ? Colors.yellowAccent : Colors.blueAccent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: event.isLive
                ? Colors.red.withOpacity(0.7)
                : Colors.blue.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ],
      ),
      child: Center(
        child: Icon(event.getCategoryIcon(), color: Colors.white, size: 16),
      ),
    );
  }

  void _showEventList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text(
                  'Events Schedule',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return ListTile(
                        leading: Icon(event.getCategoryIcon(),
                            color: Colors.white, size: 28),
                        title: Text(event.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(event.location,
                            style: TextStyle(color: Colors.grey[400])),
                        trailing: event.isLive
                            ? const Text('LIVE',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold))
                            : null,
                        onTap: () {
                          _mapController.move(
                              LatLng(event.latitude, event.longitude), 17.5);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEventDetails(Event event) {
    final timeFormat = DateFormat.jm();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF23242B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      color: Colors.grey[400], size: 18),
                  const SizedBox(width: 8),
                  Text(event.location,
                      style: TextStyle(color: Colors.grey[300], fontSize: 16)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.grey[400], size: 18),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM d, yyyy').format(event.date),
                    style: TextStyle(color: Colors.grey[300], fontSize: 16),
                  ),
                  const Spacer(),
                  if (event.isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    )
                ],
              ),
              const Divider(color: Colors.grey, height: 30),
              Text(
                event.description,
                style: TextStyle(color: Colors.grey[200], fontSize: 15),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _fetchAndDrawRoute(event),
                  icon: const Icon(Icons.directions_walk),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
