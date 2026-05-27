import 'dart:convert';
import 'dart:io';
import 'package:app_resepku/data/model/recipe.dart';
import 'package:app_resepku/data/service/http_service.dart';
import 'package:app_resepku/data/usecase/response/recipe_response.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class RecipeRepository {
  final HttpService httpService = HttpService();

  Future<bool> updateRecipe({
    required int id,
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> steps,
    File? imageFile, // optional
  }) async {
    final headers = await httpService.getHeaders();

    final uri = Uri.parse('${httpService.baseUrl}recipes/$id');
    final request = http.MultipartRequest('POST', uri);

    // Header (WAJIB)
    request.headers.addAll(headers);

    // Laravel method spoofing
    request.fields['_method'] = 'PUT';

    // Fields utama
    request.fields['title'] = title;
    request.fields['description'] = description;

    // Ingredients (ARRAY)
    for (int i = 0; i < ingredients.length; i++) {
      request.fields['ingredients[$i]'] = ingredients[i];
    }

    // Steps (ARRAY)
    for (int i = 0; i < steps.length; i++) {
      request.fields['steps[$i]'] = steps[i];
    }

    // Image (OPTIONAL)
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    print('UPDATE RECIPE STATUS: ${response.statusCode}');
    print('UPDATE RECIPE BODY: $body');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(body);
    }
  }

  Future<void> deleteRecipe(int id) async {
    final headers = await httpService.getHeaders();
    final response = await http.delete(
      Uri.parse('${httpService.baseUrl}recipes/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus resep');
    }
  }

  // Ambil semua resep
  Future<List<Recipe>> getAllRecipes() async {
    try {
      final response = await httpService.get('recipes');
      final decoded = jsonDecode(response.body);
      final recipeResponse = RecipeResponse.fromMap(decoded);
      return recipeResponse.data;
    } catch (e) {
      print('Error getAllRecipes: $e');
      return [];
    }
  }

  // Ambil resep user login
  Future<List<Recipe>> getMyRecipes() async {
    final response = await httpService.get('recipes/my');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded['data'];

      return data.map((e) => Recipe.fromMap(e)).toList();
    }

    throw Exception('Gagal mengambil resep saya');
  }

  // Tambah resep (WAJIB FILE)
  Future<bool> createRecipe({
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> steps,
    required File imageFile,
  }) async {
    final headers = await httpService.getHeaders();
    final compressedImage = await compressImage(imageFile);

    final uri = Uri.parse('${httpService.baseUrl}recipes');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);

    request.fields['title'] = title;
    request.fields['description'] = description;
    // request.fields['ingredients'] = jsonEncode(ingredients);
    for (int i = 0; i < ingredients.length; i++) {
      request.fields['ingredients[$i]'] = ingredients[i];
    }
    // request.fields['steps'] = jsonEncode(steps);
    for (int i = 0; i < steps.length; i++) {
      request.fields['steps[$i]'] = steps[i];
    }

    request.files.add(
      await http.MultipartFile.fromPath('image', compressedImage.path),
    );
    final response = await request.send();
    final body = await response.stream.bytesToString();

    print('CREATE RECIPE STATUS: ${response.statusCode}');
    print('CREATE RECIPE BODY: $body');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception(body);
    }
  }

  Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60, //  PENTING
      minWidth: 1024, //  PENTING
      minHeight: 1024, //  PENTING
    );

    if (result == null) throw Exception('Gagal kompres gambar');

    return File(result.path);
  }

  Future<bool> rateRecipe({required int recipeId, required int rating}) async {
    final uri = Uri.parse('${httpService.baseUrl}recipes/$recipeId/rate');
    final headers = await httpService.getHeaders();

    final response = await httpService.post('recipes/$recipeId/rate', {
      'rating': rating,
    });

    return response.statusCode == 200;
  }

  // Tambah / hapus favorit
  Future<bool> toggleFavorite(int recipeId) async {
    final uri = Uri.parse('${httpService.baseUrl}favorites/$recipeId');
    final headers = await httpService.getHeaders();

    final response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal toggle favorit: ${response.body}');
    }
  }

  // Ambil semua resep favorit user
  Future<List<Recipe>> getMyFavorites() async {
    final uri = Uri.parse('${httpService.baseUrl}favorites');
    final headers = await httpService.getHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat favorit: ${response.statusCode}');
    }

    final jsonData = jsonDecode(response.body);

    if (!jsonData.containsKey('data')) return [];

    return (jsonData['data'] as List).map((e) => Recipe.fromMap(e)).toList();
  }
}
