import 'dart:convert';

class ProfilResponse {
  final String status;
  final String message;

  ProfilResponse({
    required this.status,
    required this.message,
  });

  factory ProfilResponse.fromJson(String str) =>
      ProfilResponse.fromMap(json.decode(str));

  factory ProfilResponse.fromMap(Map<String, dynamic> json) {
    return ProfilResponse(
      status: json['status']?.toString() ?? 'success',
      message: json['message']?.toString() ?? 'Berhasil',
    );
  }
}