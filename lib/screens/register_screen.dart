import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Kita butuh 3 controller sekarang (Nama, Email, Password)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submit() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    // Validasi sederhana: tidak boleh ada yang kosong
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data')),
      );
      return;
    }

    // Panggil fungsi register di AuthProvider
    // Perhatikan: kita menggunakan 'auth.register', bukan 'auth.login'
    final success = await Provider.of<AuthProvider>(context, listen: false)
        .register(name, email, password);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi Gagal. Email mungkin sudah terdaftar.')),
      );
    } else if (success && mounted) {
      // Jika berhasil, kita tutup halaman register ini agar kembali ke flow utama
      // Karena di main.dart kita sudah pasang pengecekan status login,
      // aplikasi akan otomatis pindah ke Home Screen.
      Navigator.of(context).pop(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Akun Baru"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppLogo(
                  size: 120,               // Bisa dibesarkan
                  style: LogoStyle.soul,   // <--- GANTI GANTI DISINI
                  withText: true,          // Tampilkan teks DIRI di bawahnya
                ),
                const SizedBox(height: 32),

                // Input Nama (Baru ditambahkan)
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Panggilan',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Input Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Input Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Tombol Daftar
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Buat Akun'),
                ),
                
                const SizedBox(height: 16),
                
                // Tombol Kembali ke Login
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Kembali ke halaman Login
                  },
                  child: const Text('Sudah punya akun? Masuk disini'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}