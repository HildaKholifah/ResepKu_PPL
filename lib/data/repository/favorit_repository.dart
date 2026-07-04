import 'dart:convert';

import 'package:app_resepku/data/service/http_service.dart';
import 'package:app_resepku/data/usecase/response/favorite_response.dart';

class FavoriteRepository {
  final HttpService httpService = HttpService();

  Future<FavoriteResponse> addFavorite(int recipeId) async {
    final response = await httpService.post(
      'favorites/$recipeId',
      {},
    );

    return FavoriteResponse.fromJson(response.body);
  }

  Future<FavoriteResponse> removeFavorite(int recipeId) async {
    final response = await httpService.delete(
      'favorites/$recipeId',
    );

    return FavoriteResponse.fromJson(response.body);
  }

  Future<bool> checkFavorite(int recipeId) async {
    final response = await httpService.get(
      'favorites/$recipeId/check',
    );

    final json = jsonDecode(response.body);

    return json['is_favorite'];
  }
}