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

  factory User.fromDBtoApp(Map<String, dynamic> map) {
    return User(
      t_id: map['t_id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      token: map['token'] ?? '',
      points: map['points'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      contact: map['contact'] ?? '',
      institution: map['institution'] ?? '',
    );
  }

  factory User.fromJson(String source) =>
      User.fromDBtoApp(jsonDecode((source)));
}
