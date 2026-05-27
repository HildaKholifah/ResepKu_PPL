import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_resepku/data/repository/recipe_repository.dart';

class TambahResepPage extends StatefulWidget {
  // final String username;
  const TambahResepPage({super.key}); // , required this.username

  @override
  State<TambahResepPage> createState() => _TambahResepPageState();
}

class _TambahResepPageState extends State<TambahResepPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtr = TextEditingController();
  final _descCtr = TextEditingController();
  final _ingredientCtr = TextEditingController();
  final _stepCtr = TextEditingController();

  final RecipeRepository _repository = RecipeRepository();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Resep"),
        backgroundColor: const Color(0xFFB8792F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _inputField(controller: _titleCtr, label: "Judul Resep"),
              const SizedBox(height: 14),
              _inputField(
                controller: _descCtr,
                label: "Deskripsi",
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              _inputField(
                controller: _ingredientCtr,
                label: "Bahan-bahan",
                hint: "Pisahkan dengan baris baru",
                maxLines: 4,
              ),
              const SizedBox(height: 14),
              _inputField(
                controller: _stepCtr,
                label: "Langkah-langkah",
                hint: "Tulis langkah berurutan",
                maxLines: 5,
              ),
              const SizedBox(height: 14),

              // Pilih foto
              GestureDetector(
                onTap: _showPickOptionsDialog,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageFile == null
                      ? const Center(child: Text("Ketuk untuk pilih foto"))
                      : Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6B3E26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SIMPAN RESEP",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper input field
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
  }) {
    final bool isMultiline = maxLines > 1;

    return TextFormField(
      controller: controller,
      maxLines: isMultiline ? null : 1,
      minLines: isMultiline ? maxLines : 1,

      keyboardType: isMultiline ? TextInputType.multiline : TextInputType.text,

      textInputAction: isMultiline
          ? TextInputAction.newline
          : TextInputAction.next,

      validator: (v) =>
          v == null || v.isEmpty ? "$label tidak boleh kosong" : null,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Pilih kamera/galeri
  void _showPickOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pilih foto"),
        content: const Text("Ambil dari kamera atau pilih dari galeri?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text("Kamera"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text("Galeri"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Foto resep wajib dipilih"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _repository.createRecipe(
        title: _titleCtr.text,
        description: _descCtr.text,
        ingredients: _ingredientCtr.text
            .split('\n')
            .where((e) => e.trim().isNotEmpty)
            .toList(),
        steps: _stepCtr.text
            .split('\n')
            .where((e) => e.trim().isNotEmpty)
            .toList(),
        imageFile: _imageFile!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Resep berhasil ditambahkan"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menambah resep: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
