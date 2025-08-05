import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../model/event_model.dart'; // Import the new model

class AppState extends ChangeNotifier {
  List<Event> _events = [];
  int _currentIndex = 0; // Assuming this is for your BottomNavBar

  List<Event> get events => _events;
  int get currentIndex => _currentIndex;

  AppState() {
    loadEvents();
  }

  // Load events from the JSON asset
  Future<void> loadEvents() async {
    final String jsonString = await rootBundle.loadString('assets/data/events.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);
    _events = jsonResponse.map((eventJson) => Event.fromJson(eventJson)).toList();
    notifyListeners(); // Notify widgets that the data has changed
  }
  
  // Keep data-related logic here
  List<Event> getEventsByCategory(String category) {
    if (category == 'All') return _events;
    return _events.where((event) => event.category == category).toList();
  }

  List<Event> getNearbyEvents(double lat, double lng, double radiusKm) {
    List<Event> nearby = [];
    for (var event in _events) {
      double distance = Geolocator.distanceBetween(lat, lng, event.latitude, event.longitude) / 1000;
      if (distance <= radiusKm) {
        nearby.add(event);
      }
    }
    return nearby;
  }
  
  void setCurrentIndex(int index) {
      _currentIndex = index;
      notifyListeners();
  }
}