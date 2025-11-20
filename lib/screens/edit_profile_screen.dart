import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Isi nama otomatis dari data user sekarang
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController.text = user?.name ?? "";
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _save() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isSaving = true);

    final success = await Provider.of<AuthProvider>(context, listen: false)
        .updateProfile(_nameController.text, _selectedImage);

    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.pop(context); // Balik ke Profil
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil berhasil diperbarui!")));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal update profil.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    
    // --- THEME ---
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Edit Profil", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. AVATAR PICKER
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.cardTheme.color,
                      border: Border.all(color: AppColors.primary, width: 2),
                      image: _selectedImage != null
                          ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) // Gambar Baru
                          : (user?.avatarUrl != null
                              ? DecorationImage(image: NetworkImage(user!.avatarUrl!), fit: BoxFit.cover) // Gambar Lama
                              : null),
                    ),
                    child: (_selectedImage == null && user?.avatarUrl == null)
                        ? Icon(Icons.person, size: 60, color: textColor.withOpacity(0.2))
                        : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. FORM NAMA
            TextField(
              controller: _nameController,
              style: GoogleFonts.plusJakartaSans(color: textColor),
              decoration: InputDecoration(
                labelText: "Nama Lengkap",
                labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                prefixIcon: Icon(Icons.person_outline, color: theme.textTheme.bodyMedium?.color),
                filled: true,
                fillColor: theme.cardTheme.color,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            // 3. EMAIL (Read Only - Biar ga ribet verifikasi ulang)
            TextField(
              enabled: false, // Gabisa diedit
              controller: TextEditingController(text: user?.email),
              style: GoogleFonts.plusJakartaSans(color: textColor.withOpacity(0.5)),
              decoration: InputDecoration(
                labelText: "Email (Tidak dapat diubah)",
                labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                prefixIcon: Icon(Icons.email_outlined, color: theme.textTheme.bodyMedium?.color),
                filled: true,
                fillColor: theme.cardTheme.color?.withOpacity(0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),

            // 4. TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Simpan Perubahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}