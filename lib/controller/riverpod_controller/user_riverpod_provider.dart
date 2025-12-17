import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techniche26/model/userModel.dart';
import 'dart:convert';

class UserNotifier extends StateNotifier<User> {
  UserNotifier()
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

  // Update user state from JSON string
  void setUser(String userData) {
    try {
      state = User.fromJson(userData);
    } catch (e) {
      print("Error setting user data in Riverpod: $e");
      clearUser();
      rethrow; // Re-throw to allow controller to handle the error
    }
  }

  // Update specific fields or replace the user object
  void updateUser(User newUser) {
    state = newUser;
  }

  // Clear user state (logout)
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

// Global provider for accessing user state
final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier();
});
