import 'package:app_resepku/data/service/http_service.dart';
import 'package:app_resepku/data/usecase/response/favorite_response.dart';

class FavoriteRepository {
  final HttpService httpService = HttpService();

  Future<FavoriteResponse> toggleFavorite(int recipeId) async {
    final response = await httpService.post('favorites/$recipeId', {});

    return FavoriteResponse.fromJson(response.body);
  }
}
