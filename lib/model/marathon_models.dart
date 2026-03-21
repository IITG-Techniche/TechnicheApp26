// ════════════════════════════════════════════════════════════════════════════
// MARATHON MODELS
// Supabase tables: marathon_participants, practice_logs, distance_leaderboard
// ════════════════════════════════════════════════════════════════════════════

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
      category: json['category'] ?? '6KM',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'pin': pin,
    'category': category,
    'created_at': createdAt.toIso8601String(),
  };
}

// ── PracticeLog ───────────────────────────────────────────────────────────────
// Maps to Supabase table: practice_logs
// Now includes stepCount and calories for the new run tracking backend.

class PracticeLog {
  final String id;
  final String username;
  final double distanceKm;
  final double durationMinutes;
  final double avgPace;
  final int stepCount;
  final int calories;
  final String category;
  final DateTime createdAt;

  PracticeLog({
    required this.id,
    required this.username,
    required this.distanceKm,
    required this.durationMinutes,
    required this.avgPace,
    this.stepCount = 0,
    this.calories = 0,
    this.category = '6KM',
    required this.createdAt,
  });

  /// Used when inserting to Supabase — no id/created_at (auto-generated)
  Map<String, dynamic> toInsertMap() => {
    'username': username,
    'distance_km': distanceKm,
    'duration_minutes': durationMinutes,
    'avg_pace': avgPace,
    'step_count': stepCount,
    'calories': calories,
    'category': category,
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'distance_km': distanceKm,
    'duration_minutes': durationMinutes,
    'avg_pace': avgPace,
    'step_count': stepCount,
    'calories': calories,
    'category': category,
    'created_at': createdAt.toIso8601String(),
  };

  factory PracticeLog.fromJson(Map<String, dynamic> json) {
    return PracticeLog(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      durationMinutes: (json['duration_minutes'] ?? 0).toDouble(),
      avgPace: (json['avg_pace'] ?? 0).toDouble(),
      stepCount: (json['step_count'] ?? 0) is int
          ? (json['step_count'] ?? 0)
          : (json['step_count'] ?? 0).toInt(),
      calories: (json['calories'] ?? 0) is int
          ? (json['calories'] ?? 0)
          : (json['calories'] ?? 0).toInt(),
      category: json['category'] ?? '6KM',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// ── Leaderboard entries ───────────────────────────────────────────────────────

class DistanceLeaderboardEntry {
  final String username;
  final double totalDistance;
  final int totalRuns;
  final String category;

  DistanceLeaderboardEntry({
    required this.username,
    required this.totalDistance,
    this.totalRuns = 0,
    this.category = '6KM',
  });

  factory DistanceLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return DistanceLeaderboardEntry(
      username: json['username'] ?? '',
      totalDistance: (json['total_distance'] ?? 0).toDouble(),
      totalRuns: (json['total_runs'] ?? 0) is int
          ? (json['total_runs'] ?? 0)
          : (json['total_runs'] ?? 0).toInt(),
      category: json['category'] ?? '6KM',
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

// ── Daily stat (bar chart on dashboard) ──────────────────────────────────────

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

// ── Progress stats (dashboard) ────────────────────────────────────────────────

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

  /// Compute stats directly from a list of PracticeLogs.
  /// Called by MarathonService.getUserProgress() instead of the old RPC.
  factory ProgressStats.fromLogs(List<PracticeLog> logs) {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final startOfWeek =
    todayMidnight.subtract(Duration(days: now.weekday - 1));

    // This-week runs
    final thisWeekLogs =
    logs.where((r) => !r.createdAt.isBefore(startOfWeek)).toList();
    final weeklyKm =
    thisWeekLogs.fold(0.0, (s, r) => s + r.distanceKm);
    final weeklyPace = thisWeekLogs.isEmpty
        ? 0.0
        : thisWeekLogs.fold(0.0, (s, r) => s + r.avgPace) /
        thisWeekLogs.length;

    // Daily stats Mon–Sun
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dailyStats = List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      final dayLogs = logs.where((r) {
        final d =
        DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
        return d == day;
      }).toList();
      final dist = dayLogs.fold(0.0, (s, r) => s + r.distanceKm);
      final pace = dayLogs.isEmpty
          ? 0.0
          : dayLogs.fold(0.0, (s, r) => s + r.avgPace) / dayLogs.length;
      return DailyStat(
        dayName: dayNames[i],
        distance: dist,
        pace: pace,
        isToday: day == todayMidnight,
      );
    });

    // Streak — consecutive days with a run, counting back from today
    int streak = 0;
    for (int i = 0; i <= 13; i++) {
      final day = todayMidnight.subtract(Duration(days: i));
      final hasRun = logs.any((r) {
        final d =
        DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
        return d == day;
      });
      if (hasRun) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    // Improvement % vs last week
    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));
    final lastWeekKm = logs
        .where((r) =>
    !r.createdAt.isBefore(startOfLastWeek) &&
        r.createdAt.isBefore(startOfWeek))
        .fold(0.0, (s, r) => s + r.distanceKm);

    double improvement = 0;
    if (lastWeekKm > 0) {
      improvement = ((weeklyKm - lastWeekKm) / lastWeekKm) * 100;
    } else if (weeklyKm > 0) {
      improvement = 100;
    }

    return ProgressStats(
      streak: streak,
      weeklyKm: weeklyKm,
      weeklyPace: weeklyPace,
      improvement: improvement,
      dailyStats: dailyStats,
    );
  }
}
