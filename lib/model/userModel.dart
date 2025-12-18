import 'dart:convert';

class User {
  final String name;
  final String email;
  final String t_id;
  final String token;
  final int points;
  final int contact;
  final String state;
  final String city;
  final String institution;

  User({
    required this.name,
    required this.email,
    required this.t_id,
    required this.token,
    required this.points,
    required this.city,
    required this.contact,
    required this.state,
    required this.institution,
  });

  Map<String, dynamic> fromAppToDB() {
    return {
      't_id': t_id,
      'name': name,
      'email': email,
      'points': points,
      'token': token,
      'state': state,
      'city': city,
      'contact': contact,
      'institution': institution
    };
  }

  /// Helper to safely parse int from dynamic value (handles String/int/null)
  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory User.fromDBtoApp(Map<String, dynamic> map) {
    return User(
      t_id: map['t_id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      token: map['token']?.toString() ?? '',
      points: _parseInt(map['points']),
      city: map['city']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
      contact: _parseInt(map['contact']),
      institution: map['institution']?.toString() ?? '',
    );
  }

  factory User.fromJson(String source) =>
      User.fromDBtoApp(jsonDecode((source)));
}
