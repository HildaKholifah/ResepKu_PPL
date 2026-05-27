import 'package:app_resepku/presentation/edit_resep_page.dart';
import 'package:app_resepku/presentation/home_page.dart';
import 'package:app_resepku/presentation/profil_page.dart';
import 'package:app_resepku/presentation/tambah_resep_page.dart';
import 'package:flutter/material.dart';
import 'package:app_resepku/data/model/recipe.dart';
import 'package:app_resepku/data/repository/recipe_repository.dart';
import 'package:app_resepku/presentation/detail_resep_page.dart';

class ResepSayaPage extends StatefulWidget {
  final String username;

  const ResepSayaPage({super.key, required this.username});

  @override
  State<ResepSayaPage> createState() => _MyRecipePageState();
}

class _MyRecipePageState extends State<ResepSayaPage> {
  final RecipeRepository _repository = RecipeRepository();

  bool _isLoading = true;
  List<Recipe> _recipes = [];

  static const primaryBrown = Color(0xFF6B3E26);

  @override
  void initState() {
    super.initState();
    _loadMyRecipes();
  }

  Future<void> _loadMyRecipes() async {
    try {
      // Ambil resep milik user yang login
      final myRecipes = await _repository.getMyRecipes();

      setState(() {
        _recipes = myRecipes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading my recipes: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryBrown,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Tambah Resep",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          final result =
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TambahResepPage()),
              ).then((_) {
                _loadMyRecipes();
              });
        },
      ),
    );
  }

  // APP Bar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFB8792F),
      centerTitle: true,
      title: const Text(
        "Resep Saya",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Content
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recipes.isEmpty) {
      return const Center(
        child: Text(
          "Kamu belum menambahkan resep.\nKlik + untuk menambah.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recipes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return _recipeCard(_recipes[index]);
      },
    );
  }

  // Card
  Widget _recipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailRecipePage(recipe: recipe)),
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
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: recipe.imageUrl != null
                    ? Image.network(
                        recipe.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,

                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },

                        errorBuilder: (context, error, stackTrace) {
                          print("ERROR GAMBAR:");
                          print(error);

                          print("URL:");
                          print(recipe.imageUrl);

                          return Container(
                            color: Colors.red.shade100,
                            child: Center(
                              child: Text(
                                error.toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          );
                        },
                      )
                    : _imagePlaceholder(),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditResepPage(recipe: recipe),
                      ),
                    );

                    if (result == true) {
                      _loadMyRecipes(); // refresh
                    }
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(recipe.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int recipeId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Resep"),
        content: const Text("Yakin ingin menghapus resep ini?"),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context);
              await _repository.deleteRecipe(recipeId);
              _loadMyRecipes();
            },
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.fastfood, size: 40)),
    );
  }
}
