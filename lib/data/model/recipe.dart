import 'dart:convert';

class Recipe {
  final int id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String? imageUrl;
  final int userId;
  final String? username;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    this.imageUrl,
    required this.userId,
    this.username,
    this.isFavorite = false,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    // Ingredients
    // Parse ingredients - bisa jadi String atau sudah List
    List<String> ingredientsList = [];
    if (map['ingredients'] != null) {
      if (map['ingredients'] is String) {
        // Jika String, parse sebagai JSON array
        ingredientsList = List<String>.from(
          jsonDecode(map['ingredients']) ?? [],
        );
      } else if (map['ingredients'] is List) {
        // Jika sudah List
        ingredientsList = List<String>.from(map['ingredients']);
      }
    }

    // Steps
    // Parse steps - bisa jadi String atau sudah List
    List<String> stepsList = [];
    if (map['steps'] != null) {
      if (map['steps'] is String) {
        // Jika String, parse sebagai JSON array
        stepsList = List<String>.from(jsonDecode(map['steps']) ?? []);
      } else if (map['steps'] is List) {
        // Jika sudah List
        stepsList = List<String>.from(map['steps']);
      }
    }

    return Recipe(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      ingredients: ingredientsList,
      steps: stepsList,
      imageUrl: map['image_url'],
      userId: map['user_id'] ?? 0,
      username: map['user']?['name'],
      isFavorite: map['isFavorited'] ?? false,
    );
  }
}
