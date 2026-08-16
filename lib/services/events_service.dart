import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../model/events_data.dart';

class EventsService {
  static final EventsService _instance = EventsService._internal();
  factory EventsService() => _instance;
  EventsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<MainCategory>? _cachedCategories;

  /// Fetches main event categories from Firebase Firestore if available,
  /// falling back to assets/data/events_data.json, and finally local eventData.
  Future<List<MainCategory>> getCategories() async {
    if (_cachedCategories != null) return _cachedCategories!;

    // 1. Try Firebase Firestore
    try {
      final snapshot = await _firestore.collection('event_categories').get();
      if (snapshot.docs.isNotEmpty) {
        _cachedCategories = snapshot.docs
            .map((doc) => MainCategory.fromJson(doc.data()))
            .toList();
        return _cachedCategories!;
      }
    } catch (e) {
      debugPrint('Firestore fetch info: fallback to local JSON asset ($e)');
    }

    // 2. Try loading from assets/data/events_data.json
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/events_data.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedCategories =
          jsonList.map((item) => MainCategory.fromJson(item)).toList();
      return _cachedCategories!;
    } catch (e) {
      debugPrint('Local JSON asset load info: fallback to memory data ($e)');
    }

    // 3. Fallback to in-memory eventData
    _cachedCategories = eventData;
    return _cachedCategories!;
  }

  /// Fetches single event detail by title or ID.
  Future<EventDetail?> getEventByTitle(String title) async {
    final categories = await getCategories();
    final cleanQuery = title.trim().toLowerCase();

    for (final mainCat in categories) {
      for (final subCat in mainCat.subCategories) {
        for (final event in subCat.events) {
          if (event.title.trim().toLowerCase() == cleanQuery ||
              event.id.trim().toLowerCase() == cleanQuery) {
            return event;
          }
        }
      }
    }
    return findEventByTitle(title);
  }
}
