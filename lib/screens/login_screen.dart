import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tb_project/screens/register_screen.dart';
import 'package:tb_project/screens/home_screen.dart';
import 'package:tb_project/providers/auth_provider.dart';
// <<<--- Import ApiService

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  // GlobalKey untuk ScaffoldMessengerState
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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

  Future<void> _handleLogin() async {
    // Pastikan widget masih mounted sebelum menggunakan context
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Email dan password tidak boleh kosong.");
      return;
    }

    try {
      // Panggil fungsi login dari AuthProvider, yang akan menggunakan ApiService
      final success = await authProvider.login(email, password);
      
      if (!mounted) return; // Pastikan widget masih mounted setelah await

      if (success) {
        _showSnackBar("Login berhasil!", color: Colors.green);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Ini mungkin tidak akan terpanggil jika error dilempar oleh AuthProvider
        _showSnackBar("Login gagal. Periksa kredensial Anda.");
      }
    } catch (e) {
      if (!mounted) return; // Pastikan widget masih mounted setelah await
      _showSnackBar("Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger( // Bungkus dengan ScaffoldMessenger
      key: _scaffoldMessengerKey, // Gunakan key yang telah dibuat
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset('assets/images/logo.png', height: 100), // <<<--- Tinggi logo dikurangi
                ),
                const SizedBox(height: 40),
                // Menggunakan RichText untuk seluruh teks "Selamat Datang Di BolaSport"
                Center(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Selamat Datang\nDi ',
                          style: TextStyle(color: Colors.black87),
                        ),
                        TextSpan(
                          text: 'Bola',
                          style: TextStyle(color: Colors.black87),
                        ),
                        TextSpan(
                          text: 'Sport',
                          style: TextStyle(color: Colors.green[700]), // <<<--- Warna hijau
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
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
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Masukkan password Anda',
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
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Consumer<AuthProvider>( // Menggunakan Consumer untuk status loading
                  builder: (context, authProvider, child) {
                    return SizedBox(
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
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Belum punya akun? Daftar",
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
  }
}
