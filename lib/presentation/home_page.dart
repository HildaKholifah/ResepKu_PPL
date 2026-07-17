import 'package:app_resepku/presentation/custom_app_bar.dart';
import 'package:app_resepku/presentation/detail_resep_page.dart';
import 'package:app_resepku/presentation/profil_page.dart';
import 'package:app_resepku/presentation/favorit_page.dart';
import 'package:app_resepku/presentation/resep_saya_page.dart';
import 'package:flutter/material.dart';
import 'package:app_resepku/data/model/recipe.dart';
import 'package:app_resepku/data/repository/recipe_repository.dart';

// View Model
class HomeViewModel extends ChangeNotifier {
  final RecipeRepository repository;

  HomeViewModel(this.repository);

  bool isLoading = false;
  String? errorMessage;
  List<Recipe> recipes = [];

  Future<void> fetchRecipes() async {
    try {
      isLoading = true;
      notifyListeners();

      recipes = await repository.getAllRecipes();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// UI
class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeViewModel viewModel;
  int _selectedIndex = 0;
  List get _pages => [
    dashboard(),
    ResepSayaPage(username: widget.username),
    FavoritPage(),
    ProfilPage(),
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _filteredRecipes = [];

  static const primaryBrown = Color(0xFF6B3E26);

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel(RecipeRepository());
    viewModel.fetchRecipes();

    viewModel.addListener(() {
      setState(() {
        _filteredRecipes = viewModel.recipes;
      });
    });
  }

  void _onSearch(String query) {
    setState(() {
      _filteredRecipes = viewModel.recipes
          .where(
            (recipe) =>
                recipe.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: _buildBottomNav(),
      body: _pages[_selectedIndex],
    );
  }

  // dashboard
  Widget dashboard() {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "ResepKu",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _greetingText(),
            const SizedBox(height: 20),
            _searchBar(),
            const SizedBox(height: 20),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // Content State
  Widget _buildContent() {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }

    if (_filteredRecipes.isEmpty) {
      return const Center(
        child: Text(
          "Resep tidak ditemukan",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      itemCount: _filteredRecipes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        print(_filteredRecipes[index].imageUrl);
        return _recipeCard(_filteredRecipes[index]);
      },
    );
  }

  Widget _greetingText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Halo, ${widget.username} 👋",
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: primaryBrown,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Temukan resep untuk anda recook.",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: "Cari resep...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: primaryBrown,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.search, color: Colors.white),
        ),
      ],
    );
  }

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
                child: Builder(
                  builder: (context) {
                    if (recipe.imageUrl == null || recipe.imageUrl!.isEmpty) {
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
  }

  Widget _imageError() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.fastfood, size: 40)),
    );
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: primaryBrown,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) async {
        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          await viewModel.fetchRecipes();

          setState(() {
            _filteredRecipes = viewModel.recipes;
          });
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: "Resep Saya"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorit"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
      ],
    );
  }
}
