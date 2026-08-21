import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/event_attendance_service.dart';
import '../utils/errorHandler.dart';
import 'user_provider.dart';

class BackendEvent {
  final String id;
  final String name;
  final String venueName;
  final String venueLocation;
  final double latitude;
  final double longitude;
  final int points;

  BackendEvent({
    required this.id,
    required this.name,
    required this.venueName,
    required this.venueLocation,
    required this.latitude,
    required this.longitude,
    required this.points,
  });

  factory BackendEvent.fromJson(Map<String, dynamic> json) {
    return BackendEvent(
      id: json['id']?.toString() ?? json['name'] ?? '',
      name: json['name'] ?? '',
      venueName: json['venue_name'] ?? json['venue_location'] ?? 'Event Venue',
      venueLocation: json['venue_location'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 26.1878,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 91.6916,
      points: json['points'] ?? 150,
    );
  }
}

class RewardItem {
  final String id;
  final String title;
  final String description;
  final int cost;
  final String category;
  final String icon;

  RewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.category,
    required this.icon,
  });

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      cost: json['cost'] ?? 0,
      category: json['category'] ?? 'REWARD',
      icon: json['icon'] ?? 'card_giftcard',
    );
  }
}

class CheckinRecord {
  final String id;
  final String eventId;
  final String eventName;
  final int pointsEarned;
  final String createdAt;

  CheckinRecord({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.pointsEarned,
    required this.createdAt,
  });

  factory CheckinRecord.fromJson(Map<String, dynamic> json) {
    return CheckinRecord(
      id: json['id']?.toString() ?? '',
      eventId: json['eventId'] ?? '',
      eventName: json['eventName'] ?? '',
      pointsEarned: json['pointsEarned'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class RedemptionRecord {
  final String id;
  final String rewardId;
  final String rewardTitle;
  final int pointsSpent;
  final String redemptionCode;
  final String status;
  final String createdAt;

  RedemptionRecord({
    required this.id,
    required this.rewardId,
    required this.rewardTitle,
    required this.pointsSpent,
    required this.redemptionCode,
    required this.status,
    required this.createdAt,
  });

  factory RedemptionRecord.fromJson(Map<String, dynamic> json) {
    return RedemptionRecord(
      id: json['id']?.toString() ?? '',
      rewardId: json['rewardId'] ?? '',
      rewardTitle: json['rewardTitle'] ?? '',
      pointsSpent: json['pointsSpent'] ?? 0,
      redemptionCode: json['redemptionCode'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class EventPointsState {
  final bool isLoading;
  final int totalPoints;
  final List<CheckinRecord> checkins;
  final List<RedemptionRecord> redemptions;
  final List<RewardItem> catalog;
  final List<BackendEvent> events;
  final String? errorMessage;

  EventPointsState({
    this.isLoading = false,
    this.totalPoints = 0,
    this.checkins = const [],
    this.redemptions = const [],
    this.catalog = const [],
    this.events = const [],
    this.errorMessage,
  });

  EventPointsState copyWith({
    bool? isLoading,
    int? totalPoints,
    List<CheckinRecord>? checkins,
    List<RedemptionRecord>? redemptions,
    List<RewardItem>? catalog,
    List<BackendEvent>? events,
    String? errorMessage,
  }) {
    return EventPointsState(
      isLoading: isLoading ?? this.isLoading,
      totalPoints: totalPoints ?? this.totalPoints,
      checkins: checkins ?? this.checkins,
      redemptions: redemptions ?? this.redemptions,
      catalog: catalog ?? this.catalog,
      events: events ?? this.events,
      errorMessage: errorMessage,
    );
  }
}

class EventPointsNotifier extends StateNotifier<EventPointsState> {
  final Ref _ref;

  EventPointsNotifier(this._ref) : super(EventPointsState());

  /// Fetch events list directly from custom app-backend API
  Future<void> fetchEventsList() async {
    final userState = _ref.read(userProvider);
    if (userState.token.isEmpty) return;

    try {
      final response = await EventAttendanceService.fetchEventsList(userState.token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final eventList = (data['events'] as List? ?? [])
            .map((item) => BackendEvent.fromJson(item))
            .toList();

        state = state.copyWith(events: eventList);
      }
    } catch (e) {
      print('Error fetching events from backend: $e');
    }
  }

  /// Fetch user points balance, checkins, and redemption history
  Future<void> fetchUserPoints() async {
    final userState = _ref.read(userProvider);
    if (userState.token.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await EventAttendanceService.fetchUserPoints(userState.token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final int pts = data['totalPoints'] ?? 0;

        final checkinList = (data['checkins'] as List? ?? [])
            .map((item) => CheckinRecord.fromJson(item))
            .toList();

        final redemptionList = (data['redemptions'] as List? ?? [])
            .map((item) => RedemptionRecord.fromJson(item))
            .toList();

        state = state.copyWith(
          isLoading: false,
          totalPoints: pts,
          checkins: checkinList,
          redemptions: redemptionList,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      print('Error fetching user points: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Fetch rewards catalog
  Future<void> fetchCatalog() async {
    final userState = _ref.read(userProvider);
    if (userState.token.isEmpty) return;

    try {
      final response = await EventAttendanceService.fetchRewardsCatalog(userState.token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = (data['rewards'] as List? ?? [])
            .map((item) => RewardItem.fromJson(item))
            .toList();

        state = state.copyWith(catalog: items);
      }
    } catch (e) {
      print('Error fetching rewards catalog: $e');
    }
  }

  /// Check in to event after location + face verification
  Future<bool> checkInToEvent({
    required BuildContext context,
    required String eventId,
    required String eventName,
    double? latitude,
    double? longitude,
    int points = 150,
  }) async {
    final userState = _ref.read(userProvider);
    if (userState.token.isEmpty) {
      if (context.mounted) {
        showMessage(context, "Please sign in first.", isError: true);
      }
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final response = await EventAttendanceService.checkInToEvent(
        token: userState.token,
        eventId: eventId,
        eventName: eventName,
        latitude: latitude,
        longitude: longitude,
        faceVerified: true,
        points: points,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final int updatedPoints = data['totalPoints'] ?? (state.totalPoints + points);
        
        state = state.copyWith(
          isLoading: false,
          totalPoints: updatedPoints,
        );

        await fetchUserPoints(); // refresh history

        if (context.mounted) {
          showMessage(context, "Checked in! You earned +$points points!");
        }
        return true;
      } else {
        state = state.copyWith(isLoading: false);
        final error = data['error'] ?? 'Check-in failed';
        if (context.mounted) {
          showMessage(context, error, isError: true);
        }
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        showMessage(context, "Network issue during check-in: $e", isError: true);
      }
      return false;
    }
  }

  /// Redeem reward item (e.g. Comedy Night Pass)
  Future<RedemptionRecord?> redeemReward({
    required BuildContext context,
    required String rewardId,
  }) async {
    final userState = _ref.read(userProvider);
    if (userState.token.isEmpty) {
      if (context.mounted) {
        showMessage(context, "Please sign in first.", isError: true);
      }
      return null;
    }

    state = state.copyWith(isLoading: true);

    try {
      final response = await EventAttendanceService.redeemReward(
        token: userState.token,
        rewardId: rewardId,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final int updatedPoints = data['totalPoints'] ?? state.totalPoints;
        final redemption = RedemptionRecord.fromJson(data['redemption'] ?? {});

        state = state.copyWith(
          isLoading: false,
          totalPoints: updatedPoints,
        );

        await fetchUserPoints(); // Refresh list

        if (context.mounted) {
          showMessage(context, data['message'] ?? "Reward redeemed successfully!");
        }
        return redemption;
      } else {
        state = state.copyWith(isLoading: false);
        final error = data['error'] ?? 'Failed to redeem reward';
        if (context.mounted) {
          showMessage(context, error, isError: true);
        }
        return null;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        showMessage(context, "Connection error: $e", isError: true);
      }
      return null;
    }
  }
}

final eventPointsProvider =
    StateNotifierProvider<EventPointsNotifier, EventPointsState>((ref) {
  return EventPointsNotifier(ref);
});
