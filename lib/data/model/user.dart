import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;

  // FOTO PROFILE
  final String? photo;

  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photo,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      id: json['id'],

      name: json['name'] ?? '',

      email: json['email'] ?? '',

      // PHOTO
      photo: json['photo'],

      createdAt:
          DateTime.tryParse(
            json['created_at'] ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,

    // PHOTO
    'photo': photo,

    'created_at': createdAt.toIso8601String(),
  };

  String toJson() => json.encode(toMap());
}