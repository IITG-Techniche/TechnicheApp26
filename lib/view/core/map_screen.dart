import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:techniche26/services/map_cache_service.dart';

const Map<String, Map<String, dynamic>> categoryStyles = {
  'Robotics': {'icon': Icons.smart_toy_outlined, 'color': Color(0xff00ffdd)},
  'Hackathons': {'icon': Icons.code, 'color': Color(0xff7f00ff)},
  'Workshops': {'icon': Icons.build_outlined, 'color': Color(0xfff9ff00)},
  'Techno': {'icon': Icons.lightbulb_outline, 'color': Color(0xff00e5ff)},
  'Tech-Expo': {'icon': Icons.camera_alt_outlined, 'color': Color(0xff00ff87)},
  'Lecture Series': {
    'icon': Icons.mic_external_on_outlined,
    'color': Color(0xffff4081)
  },
  'Entertainment': {
    'icon': Icons.music_note_outlined,
    'color': Color(0xffff9100)
  },
  'Nexus': {'icon': Icons.people_outline, 'color': Color(0xff00b0ff)},
  'Funniche': {'icon': Icons.gamepad_outlined, 'color': Color(0xffd500f9)},
  'Corporate': {'icon': Icons.business, 'color': Color(0xfff50057)},
  'Default': {'icon': Icons.event, 'color': Colors.grey},
};

final Map<String, LatLng> venueCoordinates = {
  "Old Gymkhana": const LatLng(26.192450, 91.695894),
  "Lake": const LatLng(26.190546, 91.694773),
  "Cricket Ground": const LatLng(26.190743, 91.697019),
  "Lecture Hall 1": const LatLng(26.188869, 91.691550),
  "Lecture Hall": const LatLng(26.189042, 91.691442),
  "IITG Circle": const LatLng(26.190865, 91.692867),
  "ED Lab": const LatLng(26.187656, 91.691551),
  "Conference Hall (Foyer)": const LatLng(26.191169, 91.692556),
  "Conference Hall 2": const LatLng(26.191169, 91.692556),
  "Conference Hall 3": const LatLng(26.191169, 91.692556),
  "Mini Audi": const LatLng(26.190689, 91.693047),
  "Audi": const LatLng(26.190943, 91.693001),
  "CCC": const LatLng(26.189215, 91.693057),
  "Swimming pool": const LatLng(26.191441, 91.698647),
  "5G1": const LatLng(26.186020, 91.689600),
  // "Cricket Ground": const LatLng(26.189954, 91.697348),
  "Near library ground": const LatLng(26.189991, 91.693029),
  "Conference room(new sac)": const LatLng(26.192760, 91.698913)
};

class MapScreen extends StatefulWidget {
  static const String routeName = '/map';
  final String? initialVenue;
  const MapScreen({super.key, this.initialVenue});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  Position? currentPosition;
  String? _selectedVenue;
  bool isSatelliteView = false;
  double rotation = 0.0;
  double _currentZoom = 16.0;
  bool _isLoadingLocation = false;

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _isScheduleLive = false;
  Map<String, dynamic> _scheduleData = {};
  List<dynamic> _allEvents = [];
  bool _isLoadingSchedule = true;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
    _initializeAndFetchSchedule().then((_) {
      _selectInitialVenue();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _initializeAndFetchSchedule() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));
    await _remoteConfig.setDefaults(const {
      "is_schedule_live": false,
      "fest_schedule_json": "{}",
    });
    await _fetchAndActivateSchedule();
  }

  Future<void> _fetchAndActivateSchedule() async {
    try {
      await _remoteConfig.fetchAndActivate();
      _isScheduleLive = _remoteConfig.getBool('is_schedule_live');
      if (_isScheduleLive) {
        final scheduleJsonString =
            _remoteConfig.getString('fest_schedule_json');
        _scheduleData = json.decode(scheduleJsonString);
        _processScheduleData();
      }
    } catch (e) {
      print("Error fetching remote config: $e");
      _isScheduleLive = false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSchedule = false;
        });
      }
    }
  }

  void _processScheduleData() {
    final List<dynamic> days = _scheduleData['days'] ?? [];
    final List<dynamic> allEvents = [];
    final now = DateTime.now();
    for (var dayData in days) {
      final String dayTitle = dayData['title'] ?? 'Day 1';
      final dayNumber =
          int.tryParse(dayTitle.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;

      final List<dynamic> events = dayData['events'] ?? [];
      for (var event in events) {
        if (venueCoordinates.containsKey(event['venue'])) {
          try {
            final timeParts =
                event['startTime'].split(':'); // "10:00" -> ["10", "00"]
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            final eventDateTime = DateTime(
                now.year, now.month, now.day + dayNumber - 1, hour, minute);
            event['eventDateTime'] = eventDateTime;
            event['date'] = dayTitle;
            allEvents.add(event);
          } catch (e) {
            print(
                "Could not parse time for event: ${event['name']}. Error: $e");
          }
        }
      }
    }
    allEvents.sort((a, b) => (a['eventDateTime'] as DateTime)
        .compareTo(b['eventDateTime'] as DateTime));

    if (mounted) {
      setState(() {
        _allEvents = allEvents;
        _pageController = PageController(viewportFraction: 0.85);
      });
    }
  }

  void _selectInitialVenue() {
    if (widget.initialVenue != null) {
      final index = _allEvents
          .indexWhere((event) => event['venue'] == widget.initialVenue);
      if (index != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController != null && _pageController!.hasClients) {
            _pageController!.jumpToPage(index);
          }
        });
      } else if (venueCoordinates.containsKey(widget.initialVenue)) {
        final venueCoord = venueCoordinates[widget.initialVenue]!;
        _mapController.move(venueCoord, 17.5);
        setState(() {
          _selectedVenue = widget.initialVenue;
        });
      }
    }
  }

  Future<void> _launchGoogleMaps(LatLng destination) async {
    final lat = destination.latitude;
    final lng = destination.longitude;
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    final hasPermission = await _handleLocationPermission();
    
    // Initialize map cache only after we've handled permissions
    await MapCacheService.init();

    if (!hasPermission) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
      _setDefaultLocation();
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      if (mounted) {
        setState(() {
          currentPosition = position;
          _isLoadingLocation = false;
        });
        _mapController.move(
            LatLng(position.latitude, position.longitude), 17.0);
      }
    } catch (e) {
      _setDefaultLocation();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to get current location'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      setState(() {
        _isLoadingLocation = false;
      });
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _showEnableGpsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.gps_fixed, color: Colors.blue),
              SizedBox(width: 10),
              Text('Enable GPS', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please turn on your device location (GPS) to continue.',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Enable', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Geolocator.openLocationSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange),
              SizedBox(width: 10),
              Text('Location Permission',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Location permission is permanently denied. Please enable it from your device settings.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
              child:
                  const Text('Settings', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Location services are disabled.");
      if (mounted) {
        await _showEnableGpsDialog();
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Location permissions are denied.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are required.')),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("Location permissions are permanently denied.");
      if (mounted) {
        _showPermanentlyDeniedDialog();
      }
      return false;
    }

    return true;
  }

  void _setDefaultLocation() {
    if (mounted) {
      _mapController.move(const LatLng(26.1923, 91.6951), 16.0);
    }
  }

  void toggleSatelliteView() {
    setState(() {
      isSatelliteView = !isSatelliteView;
    });
  }

  void resetRotation() {
    setState(() {
      rotation = 0.0;
      _mapController.rotate(0.0);
    });
  }

  double _calculateMarkerSize() {
    return (38 - (_currentZoom * 0.8)).clamp(18.0, 26.0);
  }

  Widget _buildFab({
    required String heroTag,
    required IconData icon,
    required VoidCallback onPressed,
    required int index,
    bool isLoading = false,
  }) {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _fabAnimation.value) * 100 * (index + 1)),
          child: Opacity(
            opacity: _fabAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E88E5).withOpacity(0.9),
                    const Color(0xFF1565C0).withOpacity(0.95),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: const Color(0xFF03DAC6).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onPressed,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            icon,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventSwiper() {
    if (_isLoadingSchedule || _allEvents.isEmpty) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: MediaQuery.of(context).padding.top + 25,
      left: 0,
      right: 0,
      height: 140,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _allEvents.length,
        onPageChanged: (index) {
          final event = _allEvents[index];
          final venueName = event['venue'];
          if (venueCoordinates.containsKey(venueName)) {
            final venueCoord = venueCoordinates[venueName]!;
            _mapController.move(venueCoord, 17.5);
            setState(() {
              _selectedVenue = venueName;
            });
          }
        },
        itemBuilder: (context, index) {
          return EventMapCard(event: _allEvents[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double userMarkerSize = _calculateMarkerSize();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(26.1923, 91.6951),
                    initialZoom: _currentZoom,
                    maxZoom: isSatelliteView ? 20.0 : 18.0,
                    minZoom: 14.0,
                    onTap: (_, __) {
                      setState(() {
                        _selectedVenue = null;
                      });
                    },
                    onPositionChanged: (camera, hasGesture) {
                      if (hasGesture) {
                        setState(() {
                          rotation = camera.rotationRad;
                          _currentZoom = camera.zoom;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: isSatelliteView
                          ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.techniche.techniche_app',
                    ),
                    MarkerLayer(
                      markers: venueCoordinates.entries.map((entry) {
                        final venueName = entry.key;
                        final venueCoord = entry.value;
                        final isSelected = _selectedVenue == venueName;

                        return Marker(
                          point: venueCoord,
                          width: 200,
                          height: 120,
                          child: GestureDetector(
                            onTap: () {
                              final index = _allEvents.indexWhere(
                                  (event) => event['venue'] == venueName);
                              if (index != -1 &&
                                  _pageController != null &&
                                  _pageController!.hasClients) {
                                _pageController!.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                setState(() {
                                  _selectedVenue = venueName;
                                  _mapController.move(venueCoord, 17.5);
                                });
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IntrinsicWidth(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              venueName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () =>
                                                _launchGoogleMaps(venueCoord),
                                            child: const Icon(
                                              Icons.directions,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Icon(
                                  Icons.location_on,
                                  color:
                                      const Color.fromARGB(203, 33, 149, 243),
                                  size: isSelected ? 40 : 36,
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (currentPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(currentPosition!.latitude,
                                currentPosition!.longitude),
                            width: userMarkerSize * 4,
                            height: userMarkerSize * 4,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SubtlePulsingDot(size: userMarkerSize * 2.8),
                                Container(
                                  width: userMarkerSize,
                                  height: userMarkerSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF2196F3),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2196F3)
                                            .withOpacity(0.7),
                                        blurRadius: 15,
                                        offset: const Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFF03DAC6)
                                            .withOpacity(0.4),
                                        blurRadius: 25,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          '© OpenStreetMap contributors',
                          onTap: () => launchUrl(
                              Uri.parse('https://openstreetmap.org/copyright')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildEventSwiper(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildFab(
            heroTag: 'satellite',
            icon: isSatelliteView ? Icons.map : Icons.satellite,
            onPressed: toggleSatelliteView,
            index: 0,
          ),
          _buildFab(
            heroTag: 'compass',
            icon: Icons.navigation_rounded,
            onPressed: resetRotation,
            index: 1,
          ),
          _buildFab(
            heroTag: 'location',
            icon: Icons.my_location,
            onPressed: getCurrentLocation,
            index: 2,
            isLoading: _isLoadingLocation,
          ),
        ],
      ),
    );
  }
}

class EventMapCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventMapCard({Key? key, required this.event}) : super(key: key);

  String _formatTime(String time) {
    try {
      return DateFormat("h:mm a").format(DateFormat("HH:mm").parse(time));
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String category = event['category'] ?? 'Default';
    final IconData icon = categoryStyles[category]?['icon'] ?? Icons.event;
    final Color color = categoryStyles[category]?['color'] ?? Colors.grey;
    final Color textColor = Colors.white;
    final Color subTextColor = Colors.white70;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E2A47).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.15),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          event['name'],
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event['venue'],
                          style: TextStyle(fontSize: 13, color: subTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${event['date']} | ${_formatTime(event['startTime'])} - ${_formatTime(event['endTime'])}',
                          style: TextStyle(
                              fontSize: 12,
                              color: subTextColor,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SubtlePulsingDot extends StatefulWidget {
  final double size;
  const SubtlePulsingDot({super.key, required this.size});

  @override
  State<SubtlePulsingDot> createState() => _SubtlePulsingDotState();
}

class _SubtlePulsingDotState extends State<SubtlePulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * (1 + _pulseAnimation.value * 0.5),
          height: widget.size * (1 + _pulseAnimation.value * 0.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2196F3)
                .withOpacity(0.4 * (1 - _pulseAnimation.value)),
            border: Border.all(
              color: const Color(0xFF03DAC6)
                  .withOpacity(0.7 * (1 - _pulseAnimation.value)),
              width: 2,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
