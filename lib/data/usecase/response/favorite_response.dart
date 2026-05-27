import 'dart:convert';

class FavoriteResponse {
  final String status;
  final String message;

  FavoriteResponse({required this.status, required this.message});

  factory FavoriteResponse.fromJson(String str) =>
      FavoriteResponse.fromMap(json.decode(str));

  factory FavoriteResponse.fromMap(Map<String, dynamic> json) {
    return FavoriteResponse(status: json['status'], message: json['message']);
  }

  Map<String, dynamic> toMap() {
    return {'status': status, 'message': message};
  }

  String toJson() => json.encode(toMap());
}
