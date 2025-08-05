// lib/models/event_model.dart
import 'package:flutter/material.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String category;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final bool isLive;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.isLive,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      category: json['category'],
      location: json['location'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isLive: json['isLive'],
    );
  }

  // Helper to get an icon based on category
  IconData getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'robotics':
        return Icons.smart_toy_outlined;
      case 'programming':
        return Icons.code;
      case 'talks':
        return Icons.campaign_outlined;
      case 'gaming':
        return Icons.sports_esports_outlined;
      default:
        return Icons.event;
    }
  }
}