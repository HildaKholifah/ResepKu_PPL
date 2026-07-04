import 'dart:convert';

class FavoriteResponse {
  final bool success;
  final String message;

  FavoriteResponse({
    required this.success,
    required this.message,
  });

  factory FavoriteResponse.fromJson(String str) =>
      FavoriteResponse.fromMap(json.decode(str));

  factory FavoriteResponse.fromMap(Map<String, dynamic> json) {
    return FavoriteResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}