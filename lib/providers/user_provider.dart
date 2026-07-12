import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import '../utils/errorHandler.dart';
import '../constant/sharedPerfence.dart';

class UserState {
  final String token;
  final String email;
  final String name;
  final bool profileCompleted;
  
  final String rollNumber;
  final String collegeEmail;
  final String year;
  final String branch;
  final String program;
  final String phone;

  UserState({
    this.token = '',
    this.email = '',
    this.name = '',
    this.profileCompleted = false,
    this.rollNumber = '',
    this.collegeEmail = '',
    this.year = '',
    this.branch = '',
    this.program = '',
    this.phone = '',
  });

  bool get isAuthenticated => token.isNotEmpty;

  UserState copyWith({
    String? token,
    String? email,
    String? name,
    bool? profileCompleted,
    String? rollNumber,
    String? collegeEmail,
    String? year,
    String? branch,
    String? program,
    String? phone,
  }) {
    return UserState(
      token: token ?? this.token,
      email: email ?? this.email,
      name: name ?? this.name,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      rollNumber: rollNumber ?? this.rollNumber,
      collegeEmail: collegeEmail ?? this.collegeEmail,
      year: year ?? this.year,
      branch: branch ?? this.branch,
      program: program ?? this.program,
      phone: phone ?? this.phone,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState()) {
    _loadStateFromPrefs();
  }

  /// Load session from local storage on startup
  Future<void> _loadStateFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharedPreferenceConstants.userToken) ?? '';
      final email = prefs.getString(SharedPreferenceConstants.userEmail) ?? '';
      final name = prefs.getString(SharedPreferenceConstants.userName) ?? '';
      final profileCompleted = prefs.getBool(SharedPreferenceConstants.userProfileCompleted) ?? false;

      final rollNumber = prefs.getString(SharedPreferenceConstants.userRoll) ?? '';
      final collegeEmail = prefs.getString(SharedPreferenceConstants.userCollegeEmail) ?? '';
      final year = prefs.getString(SharedPreferenceConstants.userYear) ?? '';
      final branch = prefs.getString(SharedPreferenceConstants.userBranch) ?? '';
      final program = prefs.getString(SharedPreferenceConstants.userProgram) ?? '';
      final phone = prefs.getString(SharedPreferenceConstants.userPhone) ?? '';

      state = UserState(
        token: token,
        email: email,
        name: name,
        profileCompleted: profileCompleted,
        rollNumber: rollNumber,
        collegeEmail: collegeEmail,
        year: year,
        branch: branch,
        program: program,
        phone: phone,
      );
    } catch (e) {
      print('Error loading UserState from prefs: $e');
    }
  }

  /// Save session to local storage
  Future<void> _saveStateToPrefs(UserState newState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SharedPreferenceConstants.userToken, newState.token);
      await prefs.setString(SharedPreferenceConstants.userEmail, newState.email);
      await prefs.setString(SharedPreferenceConstants.userName, newState.name);
      await prefs.setBool(SharedPreferenceConstants.userProfileCompleted, newState.profileCompleted);

      await prefs.setString(SharedPreferenceConstants.userRoll, newState.rollNumber);
      await prefs.setString(SharedPreferenceConstants.userCollegeEmail, newState.collegeEmail);
      await prefs.setString(SharedPreferenceConstants.userYear, newState.year);
      await prefs.setString(SharedPreferenceConstants.userBranch, newState.branch);
      await prefs.setString(SharedPreferenceConstants.userProgram, newState.program);
      await prefs.setString(SharedPreferenceConstants.userPhone, newState.phone);
    } catch (e) {
      print('Error saving UserState to prefs: $e');
    }
  }

  /// Sign in using microservice endpoints
  Future<bool> signInWithGoogle({
    required BuildContext context,
    required String email,
    required String googleId,
    String? name,
  }) async {
    try {
      final response = await UserService.loginWithGoogle(
        email: email,
        googleId: googleId,
        name: name,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String token = responseData['token'] ?? '';
        final userObj = responseData['user'] ?? {};

        if (token.isEmpty) {
          if (context.mounted) {
            showMessage(context, "Authentication failed — invalid server token", isError: true);
          }
          return false;
        }

        // Update state with newly authenticated details
        final newState = state.copyWith(
          token: token,
          email: userObj['email'] ?? email,
          name: userObj['name'] ?? name ?? '',
        );
        state = newState;
        await _saveStateToPrefs(newState);

        // Fetch fresh profile state to check completion
        if (context.mounted) {
          await fetchProfileDetails(context);
        }

        return true;
      } else {
        if (context.mounted) {
          final body = jsonDecode(response.body);
          final error = body['message'] ?? 'Failed to log in with Google';
          showMessage(context, error, isError: true);
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        showMessage(context, "An error occurred during authentication: $e", isError: true);
      }
      return false;
    }
  }

  /// Fetch user profile details
  Future<bool> fetchProfileDetails(BuildContext context) async {
    if (state.token.isEmpty) return false;

    try {
      final response = await UserService.getProfile(state.token);

      if (response.statusCode == 200) {
        final profileObj = jsonDecode(response.body);
        final newState = state.copyWith(
          profileCompleted: true,
          rollNumber: profileObj['rollNumber'] ?? '',
          collegeEmail: profileObj['collegeEmail'] ?? '',
          year: profileObj['year']?.toString() ?? '',
          branch: profileObj['branch'] ?? '',
          program: profileObj['program'] ?? '',
          phone: profileObj['phone'] ?? '',
          name: profileObj['name'] ?? state.name,
        );
        state = newState;
        await _saveStateToPrefs(newState);
        return true;
      } else if (response.statusCode == 404) {
        // Profile not completed yet
        final newState = state.copyWith(profileCompleted: false);
        state = newState;
        await _saveStateToPrefs(newState);
        return false;
      }
      return false;
    } catch (e) {
      print('Error fetching profile details: $e');
      return false;
    }
  }

  /// Complete/Update profile details
  Future<bool> completeProfile({
    required BuildContext context,
    required String name,
    required String rollNumber,
    required String collegeEmail,
    required String year,
    required String branch,
    required String program,
    required String phone,
  }) async {
    if (state.token.isEmpty) return false;

    try {
      final response = await UserService.updateProfile(
        name: name,
        rollNumber: rollNumber,
        collegeEmail: collegeEmail,
        year: year,
        branch: branch,
        program: program,
        phone: phone,
        token: state.token,
      );

      debugPrint("updateProfile response status: ${response.statusCode}");
      debugPrint("updateProfile response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final profileObj = responseData['profile'] ?? {};

        final newState = state.copyWith(
          profileCompleted: true,
          rollNumber: profileObj['rollNumber'] ?? rollNumber,
          collegeEmail: profileObj['collegeEmail'] ?? collegeEmail,
          year: profileObj['year']?.toString() ?? year,
          branch: profileObj['branch'] ?? branch,
          program: profileObj['program'] ?? program,
          phone: profileObj['phone'] ?? phone,
          name: profileObj['name'] ?? name,
        );
        state = newState;
        await _saveStateToPrefs(newState);

        if (context.mounted) {
          showMessage(context, "Profile completed successfully!");
        }
        return true;
      } else {
        if (context.mounted) {
          final body = jsonDecode(response.body);
          final error = body['message'] ?? 'Failed to update profile';
          showMessage(context, error, isError: true);
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        showMessage(context, "An error occurred while updating profile: $e", isError: true);
      }
      return false;
    }
  }

  /// Save user's FCM token to database
  Future<void> syncFcmToken(String fcmToken) async {
    if (state.token.isEmpty) return;
    try {
      await UserService.saveFcmToken(fcmToken: fcmToken, token: state.token);
    } catch (e) {
      print('Failed to sync FCM token: $e');
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    state = UserState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharedPreferenceConstants.userToken);
    await prefs.remove(SharedPreferenceConstants.userEmail);
    await prefs.remove(SharedPreferenceConstants.userName);
    await prefs.remove(SharedPreferenceConstants.userProfileCompleted);
    await prefs.remove(SharedPreferenceConstants.userRoll);
    await prefs.remove(SharedPreferenceConstants.userCollegeEmail);
    await prefs.remove(SharedPreferenceConstants.userYear);
    await prefs.remove(SharedPreferenceConstants.userBranch);
    await prefs.remove(SharedPreferenceConstants.userProgram);
    await prefs.remove(SharedPreferenceConstants.userPhone);
    await prefs.remove(SharedPreferenceConstants.userComedyRegistered);
    await prefs.remove(SharedPreferenceConstants.userComedyStatus);
    await prefs.remove(SharedPreferenceConstants.userComedyTicketCode);
  }
}

/// Global provider for managing user state
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
