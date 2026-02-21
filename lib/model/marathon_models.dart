class MarathonParticipant {
  final String id;
  final String username;
  final String pin;
  final String category;
  final DateTime createdAt;

  MarathonParticipant({
    required this.id,
    required this.username,
    required this.pin,
    required this.category,
    required this.createdAt,
  });

  factory MarathonParticipant.fromJson(Map<String, dynamic> json) {
    return MarathonParticipant(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      pin: json['pin'] ?? '',
      category: json['category'] ?? '6K', // fallback
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'pin': pin,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PracticeLog {
  final String id;
  final String username;
  final double distanceKm;
  final double durationMinutes;
  final double avgPace;
  final DateTime createdAt;

  PracticeLog({
    required this.id,
    required this.username,
    required this.distanceKm,
    required this.durationMinutes,
    required this.avgPace,
    required this.createdAt,
  });

  factory PracticeLog.fromJson(Map<String, dynamic> json) {
    return PracticeLog(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      durationMinutes: (json['duration_minutes'] ?? 0).toDouble(),
      avgPace: (json['avg_pace'] ?? 0).toDouble(),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'distance_km': distanceKm,
      'duration_minutes': durationMinutes,
      'avg_pace': avgPace,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class DistanceLeaderboardEntry {
  final String username;
  final double totalDistance;

  DistanceLeaderboardEntry({
    required this.username,
    required this.totalDistance,
  });

  factory DistanceLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return DistanceLeaderboardEntry(
      username: json['username'] ?? '',
      totalDistance: (json['total_distance'] ?? 0).toDouble(),
    );
  }
}

class PaceLeaderboardEntry {
  final String username;
  final double avgPace;

  PaceLeaderboardEntry({
    required this.username,
    required this.avgPace,
  });

  factory PaceLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return PaceLeaderboardEntry(
      username: json['username'] ?? '',
      avgPace: (json['avg_pace'] ?? 0).toDouble(),
    );
  }
}

class DailyStat {
  final String dayName;
  final double distance;
  final double pace;
  final bool isToday;

  DailyStat({
    required this.dayName,
    required this.distance,
    required this.pace,
    required this.isToday,
  });

  factory DailyStat.fromJson(Map<String, dynamic> json) {
    return DailyStat(
      dayName: json['day_name'] ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      pace: (json['pace'] ?? 0).toDouble(),
      isToday: json['is_today'] ?? false,
    );
  }
}

class ProgressStats {
  final int streak;
  final double weeklyKm;
  final double weeklyPace;
  final double improvement;
  final List<DailyStat> dailyStats;

  ProgressStats({
    required this.streak,
    required this.weeklyKm,
    required this.weeklyPace,
    required this.improvement,
    required this.dailyStats,
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      streak: json['streak'] ?? 0,
      weeklyKm: (json['weekly_km'] ?? 0).toDouble(),
      weeklyPace: (json['weekly_pace'] ?? 0).toDouble(),
      improvement: (json['improvement'] ?? 0).toDouble(),
      dailyStats: (json['daily_stats'] as List? ?? [])
          .map((e) => DailyStat.fromJson(e))
          .toList(),
    );
  }

  factory ProgressStats.empty() {
    return ProgressStats(
      streak: 0,
      weeklyKm: 0.0,
      weeklyPace: 0.0,
      improvement: 0.0,
      dailyStats: [],
    );
  }
}
