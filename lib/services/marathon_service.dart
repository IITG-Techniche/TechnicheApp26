import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/marathon_models.dart';

class MarathonService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Enroll user
  Future<void> enrollUser(String username, String category, String pin) async {
    await _supabase.from('marathon_participants').insert({
      'username': username,
      'category': category,
      'pin': pin,
    });
  }

  // Check if enrolled
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

  // Log a run
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
    });
  }

  // Get recent 5 runs for a user
  Future<List<PracticeLog>> getRecentRuns(String username) async {
    final response = await _supabase
        .from('practice_logs')
        .select()
        .eq('username', username)
        .order('created_at', ascending: false)
        .limit(5);

    return (response as List).map((e) => PracticeLog.fromJson(e)).toList();
  }

  // Get all runs for a user
  Future<List<PracticeLog>> getAllRuns(String username) async {
    final response = await _supabase
        .from('practice_logs')
        .select()
        .eq('username', username)
        .order('created_at', ascending: false);

    return (response as List).map((e) => PracticeLog.fromJson(e)).toList();
  }

  // Get distance leaderboard
  Future<List<DistanceLeaderboardEntry>> getDistanceLeaderboard(
      String category) async {
    final response = await _supabase
        .from('distance_leaderboard')
        .select()
        .eq('category', category);
    return (response as List)
        .map((e) => DistanceLeaderboardEntry.fromJson(e))
        .toList();
  }

  // Get user progress stats
  Future<ProgressStats> getUserProgress(String username) async {
    final response = await _supabase
        .rpc('get_user_progress', params: {'p_username': username});
    if (response != null && response is Map<String, dynamic>) {
      return ProgressStats.fromJson(response);
    }
    return ProgressStats.empty();
  }
}
