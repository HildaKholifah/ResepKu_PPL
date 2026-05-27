import 'package:app_resepku/data/model/recipe.dart';

class RecipeResponse {
  final String status;
  final String message;
  final List<Recipe> data;

  RecipeResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RecipeResponse.fromMap(Map<String, dynamic> json) {
    try {
      // API bisa kirim 'success' atau 'status', dan 'data' harus array
      final data = json['data'];
      
      if (data is! List) {
        throw Exception('Invalid data format: expected List, got ${data.runtimeType}');
      }
      
      return RecipeResponse(
        status: (json['success'] ?? json['status'] ?? false).toString(),
        message: json['message'] ?? '',
        data: List<Recipe>.from(
          data.map((e) => Recipe.fromMap(e as Map<String, dynamic>))
        ),
      );
    } catch (e) {
      print('❌ Error parsing RecipeResponse: $e');
      rethrow;
    }
  }
}
