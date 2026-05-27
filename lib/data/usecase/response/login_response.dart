import 'package:app_resepku/data/model/user.dart';

class LoginResponse {
  final String status;
  final String message;
  final String token;
  final User user;

  LoginResponse({
    required this.status,
    required this.message,
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      user: User.fromMap(json['user']),
    );
  }
}
