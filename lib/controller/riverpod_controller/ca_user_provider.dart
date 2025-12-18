/// CA (Campus Ambassador) User State Provider using Riverpod
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techniche26/model/userModel.dart';

/// Notifier for CA User state
class CaUserNotifier extends StateNotifier<User> {
  CaUserNotifier()
      : super(User(
          email: '',
          t_id: '',
          name: '',
          points: 0,
          token: '',
          contact: 0,
          state: '',
          city: '',
          institution: '',
        ));

  /// Check if CA user is logged in (has valid token in state)
  bool get isCaLoggedIn => state.token.isNotEmpty;

  /// Update user state from JSON string
  void setUser(String userData) {
    try {
      state = User.fromJson(userData);
    } catch (e) {
      print("Error setting CA user data in Riverpod: $e");
      clearUser();
      rethrow;
    }
  }

  /// Update specific fields or replace the user object
  void updateUser(User newUser) {
    state = newUser;
  }

  /// Clear user state (logout)
  void clearUser() {
    state = User(
      email: '',
      t_id: '',
      name: '',
      points: 0,
      token: '',
      contact: 0,
      state: '',
      city: '',
      institution: '',
    );
  }
}

/// Global provider for accessing CA user state
final caUserProvider = StateNotifierProvider<CaUserNotifier, User>((ref) {
  return CaUserNotifier();
});
