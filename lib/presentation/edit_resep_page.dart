import 'dart:io';

import 'package:app_resepku/data/model/recipe.dart';
import 'package:app_resepku/data/repository/recipe_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditResepPage extends StatefulWidget {
  final Recipe recipe;
  const EditResepPage({super.key, required this.recipe});

  @override
  State<EditResepPage> createState() => _EditResepPageState();
}

class _EditResepPageState extends State<EditResepPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtr = TextEditingController();
  final _descCtr = TextEditingController();
  final _ingredientCtr = TextEditingController();
  final _stepCtr = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final RecipeRepository recipeRepository = RecipeRepository();

  File? _newImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleCtr.text = widget.recipe.title;
    _descCtr.text = widget.recipe.description;
    _ingredientCtr.text = widget.recipe.ingredients.join('\n');
    _stepCtr.text = widget.recipe.steps.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Resep"),
        backgroundColor: const Color(0xFFB8792F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _input(_titleCtr, "Judul"),
              const SizedBox(height: 12),
              _input(_descCtr, "Deskripsi", maxLines: 3),
              const SizedBox(height: 12),
              _input(_ingredientCtr, "Bahan (1 baris 1)", maxLines: 5),
              const SizedBox(height: 12),
              _input(_stepCtr, "Langkah (1 baris 1)", maxLines: 5),
              const SizedBox(height: 16),
          
              // Image Section
              GestureDetector(
                onTap: _pickImageDialog,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _buildImage(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3E26),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SIMPAN PERUBAHAN",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Image Preview
  Widget _buildImage() {
    if (_newImage != null) {
      return Image.file(_newImage!, fit: BoxFit.cover);
    }

    if (widget.recipe.imageUrl != null) {
      return Image.network(
        widget.recipe.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image)),
      );
    }

    return const Center(child: Text("Tap untuk ganti gambar"));
  }

  // Input
  Widget _input(
    TextEditingController ctr,
    String label, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctr,
      maxLines: maxLines,
      validator: (v) => v == null || v.isEmpty ? "$label wajib" : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Pick Image
  void _pickImageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ganti Gambar"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pick(ImageSource.camera);
            },
            child: const Text("Kamera"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pick(ImageSource.gallery);
            },
            child: const Text("Galeri"),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 70);
    if (file != null) {
      setState(() => _newImage = File(file.path));
    }
  }

  //Submit
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await recipeRepository.updateRecipe(
        id: widget.recipe.id,
        title: _titleCtr.text,
        description: _descCtr.text,
        ingredients: _ingredientCtr.text.split('\n'),
        steps: _stepCtr.text.split('\n'),
        imageFile: _newImage, // NULL = pakai lama
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}