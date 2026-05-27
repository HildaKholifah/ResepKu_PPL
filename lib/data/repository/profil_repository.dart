import 'dart:convert';
import 'dart:io';
import 'package:app_resepku/data/model/user.dart';
import 'package:app_resepku/data/service/http_service.dart';
import 'package:app_resepku/data/usecase/response/profil_response.dart';

class ProfilRepository {
  final HttpService httpService = HttpService();

  Future<User> getProfile() async {
    final response = await httpService.get('me');

    if (response.statusCode != 200) {
      throw Exception('HTTP error');
    }
    final Map<String, dynamic> json = jsonDecode(response.body);

    if (!json.containsKey('user')) {
      throw Exception('Invalid profile response');
    }

    return User.fromMap(json['user']);
  }

  Future<dynamic> uploadPhoto(File image) async {
    final response = await httpService.postWithFile(
      'profile/photo',
      {},
      image,
      'photo',
    );

    return ProfilResponse.fromJson(response.body);
  }

  Future<dynamic> updateProfile({
    required String name,
    required String email,
    File? photo,
  }) async {

    final response = await httpService.postWithFile(
      'profile/update',

      {
        'name': name,
        'email': email,
      },

      photo,
      'photo',
    );

    return jsonDecode(response.body);
  }

  Future<dynamic> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {

    final response = await httpService.post(
      'change-password',

      {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      },
    );

    return response.body;
  }
}
