import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/marathon_models.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'recent_runs_$username';
    final cacheTimeKey = 'recent_runs_time_$username';

    // Check cache first
    final lastFetch = prefs.getInt(cacheTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cachedStr = prefs.getString(cacheKey);
    
    // If cache is fresh (less than 5 mins old), use it
    if (cachedStr != null && (now - lastFetch) < 5 * 60 * 1000) {
      final List decoded = jsonDecode(cachedStr);
      return decoded.map((e) => PracticeLog.fromJson(e)).toList();
    }

    try {
      final response = await _supabase
          .from('practice_logs')
          .select()
          .eq('username', username)
          .order('created_at', ascending: false)
          .limit(5);

      final runs = (response as List).map((e) => PracticeLog.fromJson(e)).toList();
      await prefs.setString(cacheKey, jsonEncode(response));
      await prefs.setInt(cacheTimeKey, now);
      return runs;
    } catch (e) {
      if (cachedStr != null) {
        final List decoded = jsonDecode(cachedStr);
        return decoded.map((e) => PracticeLog.fromJson(e)).toList();
      }
      rethrow;
    }
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
  /// Uses the get_user_progress RPC on Supabase for data accuracy and performance.
  Future<ProgressStats> getUserProgress(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'progress_stats_$username';
    final cacheTimeKey = 'progress_stats_time_$username';

    // Check cache first
    final lastFetch = prefs.getInt(cacheTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cachedStr = prefs.getString(cacheKey);

    // If cache is fresh (less than 5 mins old), use it
    if (cachedStr != null && (now - lastFetch) < 5 * 60 * 1000) {
      return ProgressStats.fromJson(jsonDecode(cachedStr));
    }

    try {
      final response = await _supabase.rpc('get_user_progress', params: {
        'p_username': username,
      });

      final stats = ProgressStats.fromJson(response);
      await prefs.setString(cacheKey, jsonEncode(response));
      await prefs.setInt(cacheTimeKey, now);
      return stats;
    } catch (e) {
      if (cachedStr != null) {
        return ProgressStats.fromJson(jsonDecode(cachedStr));
      }
      rethrow;
    }
  }
}
