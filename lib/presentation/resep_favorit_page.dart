import 'package:app_resepku/data/model/recipe.dart';
import 'package:app_resepku/data/repository/recipe_repository.dart';
import 'package:app_resepku/presentation/detail_resep_page.dart';
import 'package:flutter/material.dart';

class ResepFavoritPage extends StatefulWidget {
  const ResepFavoritPage({super.key});

  @override
  State<ResepFavoritPage> createState() => _ResepFavoritPageState();
}

class _ResepFavoritPageState extends State<ResepFavoritPage> {
  final RecipeRepository _repo = RecipeRepository();
  List<Recipe> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final fav = await _repo.getMyFavorites();
    setState(() {
      _favorites = fav;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8792F),
        centerTitle: true,
        title: const Text(
          "Favorit",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_favorites.isEmpty) {
              return const Center(child: Text('Belum ada favorit'));
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final recipe = _favorites[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailRecipePage(recipe: recipe),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Builder(
                            builder: (context) {
                              if (recipe.imageUrl == null ||
                                  recipe.imageUrl!.isEmpty) {
                                return _imageError();
                              } else {
                                return Image.network(
                                  recipe.imageUrl!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print("Image load error: $error");
                                    return Text("$error");
                                  },
                                );
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            recipe.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _imageError() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.fastfood, size: 40)),
    );
  }
}
