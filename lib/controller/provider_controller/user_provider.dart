import 'package:techniche26/model/userModel.dart';
import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
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

  User get user => _user;

  Future<void> setUser(String userData) async {
    try {
      _user = User.fromJson(userData);
      notifyListeners();
    } catch (e) {
      print("Error setting user data: $e");
      await clearUser();
    }
  }

  Future<void> clearUser() async {
    _user = User(
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
    notifyListeners();
  }
}
