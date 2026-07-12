import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/comedy_service.dart';
import '../utils/errorHandler.dart';
import '../constant/sharedPerfence.dart';
import 'user_provider.dart';

class ComedyState {
  final bool isLoading;
  final bool registered;
  final String status;
  final String? ticketCode;

  ComedyState({
    this.isLoading = false,
    this.registered = false,
    this.status = '',
    this.ticketCode,
  });

  ComedyState copyWith({
    bool? isLoading,
    bool? registered,
    String? status,
    String? ticketCode,
  }) {
    return ComedyState(
      isLoading: isLoading ?? this.isLoading,
      registered: registered ?? this.registered,
      status: status ?? this.status,
      ticketCode: ticketCode ?? this.ticketCode,
    );
  }
}

class ComedyNotifier extends StateNotifier<ComedyState> {
  final Ref _ref;

  ComedyNotifier(this._ref) : super(ComedyState()) {
    _loadStateFromPrefs();
  }

  /// Load cached comedy status from SharedPreferences on startup
  Future<void> _loadStateFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool registered = prefs.getBool(SharedPreferenceConstants.userComedyRegistered) ?? false;
      final String status = prefs.getString(SharedPreferenceConstants.userComedyStatus) ?? '';
      final String? ticketCode = prefs.getString(SharedPreferenceConstants.userComedyTicketCode);

      state = ComedyState(
        isLoading: false,
        registered: registered,
        status: status,
        ticketCode: ticketCode,
      );
    } catch (e) {
      print('Error loading ComedyState from prefs: $e');
    }
  }

  /// Save current state to SharedPreferences for offline caching
  Future<void> _saveStateToPrefs(ComedyState newState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(SharedPreferenceConstants.userComedyRegistered, newState.registered);
      await prefs.setString(SharedPreferenceConstants.userComedyStatus, newState.status);
      if (newState.ticketCode != null) {
        await prefs.setString(SharedPreferenceConstants.userComedyTicketCode, newState.ticketCode!);
      } else {
        await prefs.remove(SharedPreferenceConstants.userComedyTicketCode);
      }
    } catch (e) {
      print('Error saving ComedyState to prefs: $e');
    }
  }

  /// Clear comedy preferences and reset state
  Future<void> clearComedyState() async {
    state = ComedyState();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SharedPreferenceConstants.userComedyRegistered);
      await prefs.remove(SharedPreferenceConstants.userComedyStatus);
      await prefs.remove(SharedPreferenceConstants.userComedyTicketCode);
    } catch (e) {
      print('Error clearing ComedyState from prefs: $e');
    }
  }

  /// Fetch registration status from server
  Future<void> fetchRegistrationStatus() async {
    final userState = _ref.read(userProvider);
    if (userState.token.isEmpty) {
      await clearComedyState();
      return;
    }

    // If ticket is already confirmed and we have a ticket code, skip fetching to prevent server spam
    if (state.registered && state.status == 'CONFIRMED' && state.ticketCode != null && state.ticketCode!.isNotEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final response = await ComedyService.checkComedyStatus(userState.token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool isRegistered = data['registered'] ?? false;
        
        final ComedyState newState;
        if (isRegistered) {
          newState = ComedyState(
            isLoading: false,
            registered: true,
            status: data['status'] ?? 'WAITLISTED',
            ticketCode: data['ticketCode'],
          );
        } else {
          newState = ComedyState(
            isLoading: false,
            registered: false,
            status: '',
            ticketCode: null,
          );
        }
        state = newState;
        await _saveStateToPrefs(newState);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      print('Error fetching comedy registration status: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Register for the Comedy Night event
  Future<bool> registerForComedy(BuildContext context) async {
    final userState = _ref.read(userProvider);
    if (userState.token.isEmpty) {
      if (context.mounted) {
        showMessage(context, "Please sign in first.", isError: true);
      }
      return false;
    }

    if (!userState.profileCompleted) {
      if (context.mounted) {
        showMessage(context, "Please complete your profile first.", isError: true);
      }
      return false;
    }

    state = state.copyWith(isLoading: true);
    try {
      final response = await ComedyService.registerComedy(userState.token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final registration = data['registration'] ?? {};

        final newState = ComedyState(
          isLoading: false,
          registered: true,
          status: registration['status'] ?? 'WAITLISTED',
          ticketCode: registration['ticketCode'],
        );

        state = newState;
        await _saveStateToPrefs(newState);

        if (context.mounted) {
          showMessage(context, "Registration successful! You are waitlisted.");
        }
        return true;
      } else {
        state = state.copyWith(isLoading: false);
        if (context.mounted) {
          final data = jsonDecode(response.body);
          final error = data['message'] ?? 'Failed to register';
          showMessage(context, error, isError: true);
        }
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        showMessage(context, "An error occurred during registration: $e", isError: true);
      }
      return false;
    }
  }
}

/// Global provider for managing comedy night state
final comedyProvider = StateNotifierProvider<ComedyNotifier, ComedyState>((ref) {
  return ComedyNotifier(ref);
});
