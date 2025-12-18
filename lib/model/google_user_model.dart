import 'dart:convert';

class GoogleUser {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final String token;

  GoogleUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'token': token,
    };
  }

  factory GoogleUser.fromMap(Map<String, dynamic> map) {
    return GoogleUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      token: map['token'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory GoogleUser.fromJson(String source) =>
      GoogleUser.fromMap(json.decode(source));
}
