import 'package:flutter/material.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String category;
  final String location;
  final DateTime date; // Only one date now
  final bool isLive;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.location,
    required this.date,
    required this.isLive,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      category: json['category'],
      location: json['location'],
      date: DateTime.parse(json['date']), // match JSON
      isLive: json['isLive'] ?? false,
    );
  }

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
