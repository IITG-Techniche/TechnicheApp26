import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/marathon_models.dart';

/// Drop-in replacement for the old MarathonService.
/// Same class name, same method signatures — only the Supabase table names
/// and the getUserProgress() implementation changed.
///
/// Table changes vs old code:
///   OLD: marathon_participants  → SAME (no change)
///   OLD: practice_logs         → SAME (added step_count, calories, category columns)
///   OLD: distance_leaderboard  → SAME view name (updated to include category)
///   OLD: get_user_progress RPC → REMOVED — now computed in Dart via ProgressStats.fromLogs()
class MarathonService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ── Enrollment ────────────────────────────────────────────────────────────

  Future<void> enrollUser(
      String username, String category, String pin) async {
    await _supabase.from('marathon_participants').insert({
      'username': username,
      'category': category,
      'pin': pin,
    });
  }

  Future<MarathonParticipant?> getParticipant(String username) async {
    final response = await _supabase
        .from('marathon_participants')
        .select()
        .eq('username', username)
        .maybeSingle();

    if (response != null) {
      return MarathonParticipant.fromJson(response);
    }
    return null;
  }

  // ── Save run ──────────────────────────────────────────────────────────────
  /// Saves a completed run and returns its new UUID.
  /// Replaces the old logRun() which didn't save stepCount/calories.
  Future<String> saveRun(PracticeLog log) async {
    final res = await _supabase
        .from('practice_logs')
        .insert(log.toInsertMap())
        .select('id')
        .single();
    return res['id'] as String;
  }

  /// Legacy method kept for any old callers.
  /// Internally calls saveRun() with stepCount=0.
  Future<void> logRun({
    required String username,
    required double distanceKm,
    required double durationMinutes,
    required double avgPace,
  }) async {
    await _supabase.from('practice_logs').insert({
      'username': username,
      'distance_km': distanceKm,
      'duration_minutes': durationMinutes,
      'avg_pace': avgPace,
      'step_count': 0,
      'calories': 0,
    });
  }

  // ── Fetch runs ────────────────────────────────────────────────────────────

  Future<List<PracticeLog>> getRecentRuns(String username) async {
    final response = await _supabase
        .from('practice_logs')
        .select()
        .eq('username', username)
        .order('created_at', ascending: false)
        .limit(5);

    return (response as List).map((e) => PracticeLog.fromJson(e)).toList();
  }

  Future<List<PracticeLog>> getAllRuns(String username) async {
    final response = await _supabase
        .from('practice_logs')
        .select()
        .eq('username', username)
        .order('created_at', ascending: false);

    return (response as List).map((e) => PracticeLog.fromJson(e)).toList();
  }

  // ── Leaderboard ───────────────────────────────────────────────────────────

  Future<List<DistanceLeaderboardEntry>> getDistanceLeaderboard(
      String category) async {
    final response = await _supabase
        .from('distance_leaderboard')
        .select()
        .eq('category', category)
        .order('total_distance', ascending: false);

    return (response as List)
        .map((e) => DistanceLeaderboardEntry.fromJson(e))
        .toList();
  }

  // ── Progress stats ────────────────────────────────────────────────────────
  /// Replaces the old RPC call get_user_progress.
  /// Fetches last 14 days of runs and computes stats in Dart.
  Future<ProgressStats> getUserProgress(String username) async {
    final since = DateTime.now().subtract(const Duration(days: 14));

    final response = await _supabase
        .from('practice_logs')
        .select()
        .eq('username', username)
        .gte('created_at', since.toIso8601String())
        .order('created_at', ascending: true);

    final logs =
    (response as List).map((e) => PracticeLog.fromJson(e)).toList();

    return ProgressStats.fromLogs(logs);
  }
}
