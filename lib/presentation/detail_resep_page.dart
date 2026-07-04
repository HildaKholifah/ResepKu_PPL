import 'package:app_resepku/data/repository/favorit_repository.dart';
import 'package:app_resepku/data/usecase/response/favorite_response.dart';
import 'package:flutter/material.dart';
import 'package:app_resepku/data/model/recipe.dart';
import 'package:app_resepku/data/model/comment.dart';
import 'package:app_resepku/data/repository/comment_repository.dart';
import 'package:share_plus/share_plus.dart';

class DetailRecipePage extends StatefulWidget {
  final Recipe recipe;

  const DetailRecipePage({super.key, required this.recipe});

  @override
  State<DetailRecipePage> createState() => _DetailRecipePageState();
}

class _DetailRecipePageState extends State<DetailRecipePage> {
  // warna utama
  static const primaryBrown = Color(0xFF6B3E26);

  // repository favorite
  final FavoriteRepository favoriteRepository = FavoriteRepository();

  // repository comment
  final CommentRepository commentRepository = CommentRepository();

  // controller komentar
  final TextEditingController commentController = TextEditingController();

  // list komentar
  List<Comment> comments = [];

  // Komentar Error
  String? commentError;

  // loading komentar
  bool isLoadingComment = true;

  // status favorite
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    // load komentar
    _loadComments();

    // cek status favorite
    _loadFavoriteStatus();
  }

  // SHARE RESEP
  void _shareRecipe() {
    final recipe = widget.recipe;

    final text =
        '''
🍳 ${recipe.title}

📝 Deskripsi:
${recipe.description}

🥗 Bahan:
• ${recipe.ingredients.join('\n• ')}

👨‍🍳 Langkah:
${recipe.steps.join('\n')}

Dibagikan dari aplikasi ResepKu ❤️
''';

    Share.share(text);
  }

  // TOGGLE FAVORITE
  Future<void> _toggleFavorite() async {
    try {
      late final response;

      if (isFavorite) {
        response = await favoriteRepository.removeFavorite(widget.recipe.id);
      } else {
        response = await favoriteRepository.addFavorite(widget.recipe.id);
      }

      // setState(() {
      //   isFavorite = !isFavorite;
      // });
      await _loadFavoriteStatus();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error : $e")));
    }
  }

  // LOAD KOMENTAR
  Future<void> _loadComments() async {
    try {
      final result = await commentRepository.getComments(widget.recipe.id);

      setState(() {
        comments = result;
        isLoadingComment = false;
      });
    } catch (e) {
      setState(() {
        isLoadingComment = false;
      });
    }
  }

  // LOAD FAVORITE STATUS
  Future<void> _loadFavoriteStatus() async {
    try {
      final result = await favoriteRepository.checkFavorite(
        widget.recipe.id,
      );

      if (!mounted) return;

      setState(() {
        isFavorite = result;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // TAMBAH KOMENTAR
  Future<void> _addComment() async {
    if (commentController.text.trim().isEmpty) {
      setState(() {
        commentError = "Komentar tidak boleh kosong";
      });
      return;
    }

    setState(() {
      commentError = null;
    });

    try {
      await commentRepository.addComment(
        widget.recipe.id,
        commentController.text.trim(),
      );

      commentController.clear();

      await _loadComments();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // APPBAR
      appBar: _buildAppBar(context),

      // BODY
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // gambar resep
              _imageSection(),

              // isi detail
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // judul
                    _titleSection(),

                    const SizedBox(height: 14),

                    // deskripsi
                    _descriptionSection(),

                    const SizedBox(height: 28),

                    // tombol action
                    _actionButtons(),

                    const SizedBox(height: 28),

                    // bahan
                    _sectionTitle("Bahan", Icons.restaurant_menu),

                    const SizedBox(height: 12),

                    _ingredientsSection(),

                    const SizedBox(height: 28),

                    // langkah
                    _sectionTitle("Langkah Memasak", Icons.menu_book),

                    const SizedBox(height: 12),

                    _stepsSection(),

                    const SizedBox(height: 28),

                    // komentar
                    _sectionTitle("Komentar", Icons.comment),

                    const SizedBox(height: 12),

                    _commentInputSection(),

                    const SizedBox(height: 20),

                    _commentListSection(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // APP BAR
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFB8792F),

      elevation: 2,

      centerTitle: true,

      title: const Text(
        "Detail Resep",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),

      // tombol kembali
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),

      // // tombol favorite
      // actions: [
      //   IconButton(
      //     onPressed: _toggleFavorite,

      //     icon: Icon(
      //       isFavorite ? Icons.favorite : Icons.favorite_border,

      //       color: isFavorite ? Colors.red : Colors.white,
      //     ),
      //   ),
      // ],
    );
  }

  // IMAGE SECTION
  Widget _imageSection() {
    if (widget.recipe.imageUrl == null || widget.recipe.imageUrl!.isEmpty) {
      return _imagePlaceholder();
    }

    return Padding(
      padding: const EdgeInsets.all(16),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),

        child: Image.network(
          widget.recipe.imageUrl!,

          height: 240,
          width: double.infinity,
          fit: BoxFit.cover,

          errorBuilder: (_, __, ___) {
            return _imagePlaceholder();
          },
        ),
      ),
    );
  }

  // placeholder image
  Widget _imagePlaceholder() {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Container(
        height: 240,
        width: double.infinity,

        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),

        child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
      ),
    );
  }

  // TITLE
  Widget _titleSection() {
    return Text(
      widget.recipe.title,

      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryBrown,
        height: 1.3,
      ),
    );
  }

  // DESCRIPTION
  Widget _descriptionSection() {
    return Text(
      widget.recipe.description,

      style: TextStyle(fontSize: 16, height: 1.7, color: Colors.grey.shade800),
    );
  }

  // ACTION BUTTONS
  Widget _actionButtons() {
    return Row(
      children: [
        // tombol share
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareRecipe,

            icon: const Icon(Icons.share, color: Colors.white),

            label: const Text(
              "Share",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // tombol favorit
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _toggleFavorite,

            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,

              color: Colors.white,
            ),

            label: Text(
              isFavorite ? "Favorit" : "Tambah Favorit",

              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,

              padding: const EdgeInsets.symmetric(vertical: 14),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // SECTION TITLE
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryBrown),

        const SizedBox(width: 8),

        Text(
          title,

          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryBrown,
          ),
        ),
      ],
    );
  }

  // INGREDIENTS
  Widget _ingredientsSection() {
    if (widget.recipe.ingredients.isEmpty) {
      return const Text(
        "Bahan belum tersedia",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: widget.recipe.ingredients.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Icon(Icons.check_circle, size: 18, color: Colors.green),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      item,

                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // STEPS
  Widget _stepsSection() {
    if (widget.recipe.steps.isEmpty) {
      return const Text(
        "Langkah memasak belum tersedia",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: widget.recipe.steps.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final step = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // nomor langkah
                  Container(
                    width: 30,
                    height: 30,

                    decoration: const BoxDecoration(
                      color: primaryBrown,
                      shape: BoxShape.circle,
                    ),

                    child: Center(
                      child: Text(
                        "$index",

                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // isi langkah
                  Expanded(
                    child: Text(
                      step,

                      style: const TextStyle(fontSize: 15, height: 1.7),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // INPUT KOMENTAR
  Widget _commentInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _addComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBrown,
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),

        if (commentError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              commentError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // LIST KOMENTAR
  Widget _commentListSection() {
    // loading
    if (isLoadingComment) {
      return const Center(child: CircularProgressIndicator());
    }

    // kosong
    if (comments.isEmpty) {
      return const Text(
        "Belum ada komentar",
        style: TextStyle(color: Colors.grey),
      );
    }

    // tampilkan komentar
    return Column(
      children: comments.map((comment) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),

            title: Text(
              comment.userName,

              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),

              child: Text(comment.comment),
            ),
          ),
        );
      }).toList(),
    );
  }
}
