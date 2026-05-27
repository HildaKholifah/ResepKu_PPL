import 'dart:convert';

import 'package:app_resepku/data/service/http_service.dart';
import 'package:app_resepku/data/service/token_storage.dart';
import 'package:app_resepku/data/usecase/request/login_request.dart';
import 'package:app_resepku/data/usecase/request/register_request.dart';
import 'package:app_resepku/data/usecase/response/login_response.dart';
import 'package:app_resepku/data/usecase/response/register_response.dart';

class UserRepository {
  final HttpService httpService = HttpService();
  final TokenStorage tokenStorage = TokenStorage();

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await httpService.post('login', request.toMap());

    final decoded = jsonDecode(response.body);
    final loginResponse = LoginResponse.fromMap(decoded);

    // ✅ SIMPAN TOKEN JIKA LOGIN BERHASIL
    if (loginResponse.status == 'success' && loginResponse.token.isNotEmpty) {
      await tokenStorage.saveToken(loginResponse.token);
    }

    return loginResponse;
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await httpService.post('register', request.toMap());

    final decoded = jsonDecode(response.body);
    return RegisterResponse.fromMap(decoded);
  }

  Future<void> logout() async {
    try {
      await httpService.post('logout', {});
    } catch (_) {}
    await tokenStorage.clearToken();
  }
}
