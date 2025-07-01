import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
// import 'package:tb_project/screens/login_screen.dart'; // Hapus import ini karena tidak digunakan
import 'package:tb_project/screens/home_screen.dart'; // Pastikan ini diimpor untuk navigasi sukses register
import 'package:tb_project/providers/auth_provider.dart'; // Import AuthProvider

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  // GlobalKey untuk ScaffoldMessengerState untuk mengatasi warning context
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    // Menggunakan key untuk ScaffoldMessenger.of(context) agar aman di async gap
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleRegister() async {
    // Pastikan widget masih mounted sebelum menggunakan context
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Semua field harus diisi.");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Password dan konfirmasi password tidak cocok!");
      return;
    }

    if (password.length < 6) {
      _showSnackBar("Password minimal harus 6 karakter.");
      return;
    }

    try {
      final success = await authProvider.register(email, password);
      // Pastikan widget masih mounted setelah await
      if (!mounted) return;

      if (success) {
        _showSnackBar(
          "Registrasi berhasil! Anda telah masuk.", // Ubah pesan agar sesuai dengan auto-login
          color: Colors.green,
        );
        // Setelah register berhasil dan otomatis login, navigasi langsung ke HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()), // Navigasi ke HomeScreen
        );
      } else {
        _showSnackBar("Registrasi gagal. Coba lagi.");
      }
    } catch (e) {
      // Pastikan widget masih mounted setelah await
      if (!mounted) return;
      _showSnackBar(
        "Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ScaffoldMessenger( // Bungkus dengan ScaffoldMessenger
          key: _scaffoldMessengerKey, // Gunakan key yang telah dibuat
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed:
                    authProvider.isLoading
                        ? null // Nonaktifkan saat loading
                        : () {
                            Navigator.pop(context);
                          },
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 0.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset('assets/images/logo.png', height: 100), // Tinggi logo dikurangi
                    ),
                    const SizedBox(height: 30),
                    // Menggunakan RichText untuk "Buat akun Untuk Pengguna Baru"
                    Center( // Hapus const di sini karena RichText bukan const
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: 28, // Ganti TextStyle menjadi non-const
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          children: <TextSpan>[
                            TextSpan(text: "Buat akun\nUntuk Pengguna Baru"),
                            // Jika Anda ingin bagian "BolaSport" di sini juga, bisa ditambahkan:
                            // TextSpan(
                            //   text: '\nDi ',
                            //   style: TextStyle(color: Colors.black87),
                            // ),
                            // TextSpan(
                            //   text: 'Bola',
                            //   style: TextStyle(color: Colors.black87),
                            // ),
                            // TextSpan(
                            //   text: 'Sport',
                            //   style: TextStyle(color: Colors.green[700]),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email Field
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Masukkan email Anda',
                        prefixIcon: const Icon(Icons.email, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green[700]!,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Buat password Anda',
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green[700]!,
                            width: 2,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Confirm Password Field
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: !isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Konfirmasi password Anda',
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green[700]!,
                            width: 2,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Daftar Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        onPressed:
                            authProvider.isLoading ? null : _handleRegister,
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed:
                            authProvider.isLoading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                        child: Text(
                          "Sudah punya akun? Login",
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
