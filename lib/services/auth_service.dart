// Pastikan ini diimpor jika digunakan di NewsService

class AuthService {
  // Ganti dengan base URL API Anda yang sebenarnya jika sudah ada backend
  // const String _baseUrl = 'https://your-api-base-url.com';

  // Simulasi endpoint login
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulasi penundaan jaringan
    await Future.delayed(const Duration(seconds: 2));

    // --- LOGIKA SIMULASI LOGIN ---
    // Pastikan ini cocok dengan kredensial yang Anda gunakan untuk admin
    if (email == "admin@example.com" && password == "admin123") {
      return {
        'success': true,
        'message': 'Login berhasil sebagai Admin!',
        'token': 'fake_jwt_token_admin',
        'user': {'email': email, 'username': 'Admin BolaSport'}
      };
    } else if (email == "test@example.com" && password == "password123") {
      return {
        'success': true,
        'message': 'Login berhasil sebagai Pengguna!',
        'token': 'fake_jwt_token_user',
        'user': {'email': email, 'username': 'Pengguna Test'}
      };
    } else {
      // Jika email/password tidak cocok dengan simulasi di atas
      throw Exception('Email atau password salah.)');
    }
  }

  // Simulasi endpoint register
  Future<Map<String, dynamic>> register(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email.contains('@') && password.length >= 6) {
      return {
        'success': true,
        'message': 'Registrasi berhasil!',
        'token': 'fake_jwt_token_register',
        'user': {'email': email, 'username': 'Pengguna Baru'}
      };
    } else {
      throw Exception('Registrasi gagal. Pastikan email valid dan password minimal 6 karakter. (Simulasi)');
    }
  }

  // Contoh fungsi untuk logout (menghapus token lokal)
  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    print('Token otentikasi dihapus. Logout berhasil.');
  }
}
