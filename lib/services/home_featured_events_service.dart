import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';


class HomeFeaturedEventModel {
  final String id;
  final String title;
  final String category;
  final String date;
  final String venue;
  final String imageUrl;
  final String fallbackAsset;
  final int order;
  final bool isActive;
  final String? tag;
  final String? targetEventId;

  HomeFeaturedEventModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.venue,
    required this.imageUrl,
    required this.fallbackAsset,
    required this.order,
    required this.isActive,
    this.tag,
    this.targetEventId,
  });

  factory HomeFeaturedEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HomeFeaturedEventModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      date: data['date'] ?? '',
      venue: data['venue'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      fallbackAsset: data['fallbackAsset'] ?? 'assets/robo.png',
      order: (data['order'] as num?)?.toInt() ?? 99,
      isActive: data['isActive'] ?? true,
      tag: data['tag'],
      targetEventId: data['targetEventId'],
    );
  }
}

class HomeFeaturedEventsService {
  static final HomeFeaturedEventsService _instance = HomeFeaturedEventsService._internal();
  factory HomeFeaturedEventsService() => _instance;
  HomeFeaturedEventsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of active featured events ordered by priority `order`
  Stream<List<HomeFeaturedEventModel>> getFeaturedEventsStream() {
    debugPrint("🚀 Starting Firestore stream for home_featured_events...");
    return _firestore
        .collection('home_featured_events')
        .snapshots()
        .map((snapshot) {
          debugPrint("📦 Firestore snapshot received: ${snapshot.docs.length} total docs");
          final activeEvents = snapshot.docs
              .map((doc) {
                debugPrint("   📄 Doc: ${doc.id} -> isActive=${doc.data()['isActive']}");
                return HomeFeaturedEventModel.fromFirestore(doc);
              })
              .where((event) => event.isActive == true)
              .toList();
          
          activeEvents.sort((a, b) => a.order.compareTo(b.order));
          
          debugPrint("🔥 Active events to show: ${activeEvents.length}");
          return activeEvents;
        })
        .handleError((error, stackTrace) {
          debugPrint("❌ Firestore Stream Error: $error");
          debugPrint("   Stacktrace: $stackTrace");
        });
  }
}
