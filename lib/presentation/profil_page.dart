import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:app_resepku/data/repository/profil_repository.dart';
import 'package:app_resepku/data/model/user.dart';
import 'package:app_resepku/data/repository/user_repository.dart';
import 'package:app_resepku/presentation/login_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final ProfilRepository _profileRepo = ProfilRepository();
  final UserRepository _userRepo = UserRepository();

  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;

  bool _isUploading = false;

  late Future<User> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileRepo.getProfile();
  }

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      final fileSize = await file.length();

      // 2 MB
      const maxSize = 2 * 1024 * 1024;

      if (fileSize > maxSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ukuran foto maksimal 2 MB"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final extension = pickedFile.path.split('.').last.toLowerCase();

      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format gambar harus JPG, JPEG, atau PNG'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _selectedImage = file;
      });

      await _uploadProfilePhoto();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= UPLOAD PHOTO =================
  Future<void> _uploadProfilePhoto() async {
    try {
      setState(() {
        _isUploading = true;
      });

      final response = await _profileRepo.uploadPhoto(
        _selectedImage!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedImage = null;
        _profileFuture = _profileRepo.getProfile();
      });
    } catch (e, stackTrace) {
      print("UPLOAD ERROR");
      print(e);
      print(stackTrace);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // ================= DIALOG GANTI PASSWORD =================
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();

    final newPasswordController = TextEditingController();

    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Ganti Password"),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                // Password Lama
                TextField(
                  controller: currentPasswordController,

                  obscureText: true,

                  decoration: const InputDecoration(labelText: "Password Lama"),
                ),

                const SizedBox(height: 12),

                // Password Baru
                TextField(
                  controller: newPasswordController,

                  obscureText: true,

                  decoration: const InputDecoration(labelText: "Password Baru"),
                ),

                const SizedBox(height: 12),

                // Konfirmasi Password
                TextField(
                  controller: confirmPasswordController,

                  obscureText: true,

                  decoration: const InputDecoration(
                    labelText: "Konfirmasi Password",
                  ),
                ),
              ],
            ),
          ),

          actions: [
            // Batal
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Batal"),
            ),

            // Simpan
            ElevatedButton(
              onPressed: () async {
                try {
                  await _profileRepo.changePassword(
                    currentPassword: currentPasswordController.text,

                    newPassword: newPasswordController.text,

                    confirmPassword: confirmPasswordController.text,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password berhasil diubah")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
                }
              },

              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // ================= DIALOG LOGOUT =================
  void _showLogoutDialog() {
    showDialog(
      context: context,

      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi'),

        content: const Text('Apakah Anda yakin ingin keluar?'),

        actions: [
          // Batal
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),

            child: const Text('Batal'),
          ),

          // Logout
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await _userRepo.logout();

                if (!mounted) return;

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),

                  (route) => false,
                );
              } catch (e) {
                print("Logout gagal: $e");
              }
            },

            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: const Color(0xFFB8792F),

        centerTitle: true,

        title: const Text(
          "Profil",

          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: FutureBuilder<User>(
        future: _profileFuture,

        builder: (context, snapshot) {
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Gagal memuat profil\n${snapshot.error}",

                style: const TextStyle(color: Colors.red),

                textAlign: TextAlign.center,
              ),
            );
          }

          final user = snapshot.data!;

          return _profileContent(context, user);
        },
      ),
    );
  }

  // ================= PROFILE CONTENT =================
  Widget _profileContent(BuildContext context, User user) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),

      child: Column(
        children: [
          const SizedBox(height: 30),

          // ================= AVATAR =================
          Column(
            children: [
              // Avatar
              _isUploading
                ? const CircularProgressIndicator()
                : GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFF6B3E26),
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (user.photo != null
                                ? NetworkImage(
                                    "${user.photo!}?t=${DateTime.now().millisecondsSinceEpoch}",
                                  )
                                : null) as ImageProvider?,
                      child: user.photo == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),

              const SizedBox(height: 10),

              // Tombol Edit Foto
              OutlinedButton.icon(
                onPressed: _pickImage,

                icon: const Icon(Icons.camera_alt, size: 18),

                label: const Text("Edit Foto Profil"),

                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B3E26),

                  side: const BorderSide(color: Color(0xFF6B3E26)),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ================= INFO PROFILE =================
          _infoTile("Username", user.name),

          _infoTile("Email", user.email),

          _infoTile("ID User", user.id.toString()),

          _infoTile("Dibuat", user.createdAt.toString().substring(0, 10)),

          const SizedBox(height: 20),

          // ================= GANTI PASSWORD =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: SizedBox(
              width: double.infinity,
              height: 48,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock_reset, color: Colors.white),

                label: const Text(
                  "GANTI PASSWORD",

                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),

                onPressed: _showChangePasswordDialog,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ================= LOGOUT =================
          Padding(
            padding: const EdgeInsets.all(16),

            child: SizedBox(
              width: double.infinity,
              height: 48,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),

                label: const Text(
                  "LOGOUT",

                  style: TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Colors.white,
                  ),
                ),

                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                onPressed: _showLogoutDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= INFO TILE =================
  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),

      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        child: ListTile(title: Text(label), subtitle: Text(value)),
      ),
    );
  }
}
