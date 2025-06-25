import 'package:flutter/material.dart';
import 'package:tb_project/services/auth_service.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Uncomment jika ingin menyimpan token

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  String? _authToken;
  String? _userEmail;
  String? _userName;
  String _userRole = 'viewer'; // Default role sebelum login
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get authToken => _authToken;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String get userRole => _userRole; // Getter untuk peran pengguna
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _authService.login(email, password);
      if (response['success']) {
        _isLoggedIn = true;
        _authToken = response['token'];
        _userEmail = response['user']['email'];
        _userName = response['user']['username'];
        // Setelah login berhasil, set role ke 'admin' agar bisa akses CRUD
        _userRole = 'admin'; // <--- Perubahan di sini!
        
        // Simpan token ke Shared Preferences jika diaktifkan
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('authToken', _authToken!);
        // await prefs.setString('userRole', _userRole);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Error during login: $e");
      _isLoggedIn = false;
      _authToken = null;
      _userEmail = null;
      _userName = null;
      _userRole = 'viewer'; // Reset peran jika login gagal
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _authService.register(email, password);
      if (response['success']) {
        _isLoggedIn = true;
        _authToken = response['token'];
        _userEmail = email;
        _userName = response['user']['username'] ?? 'Pengguna Baru';
        // Setelah register berhasil, set role ke 'admin' agar bisa akses CRUD
        _userRole = 'admin'; // <--- Perubahan di sini!
        
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('authToken', _authToken!);
        // await prefs.setString('userRole', _userRole);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Error during registration: $e");
      _isLoggedIn = false;
      _authToken = null;
      _userEmail = null;
      _userName = null;
      _userRole = 'viewer';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _isLoggedIn = false;
      _authToken = null;
      _userEmail = null;
      _userName = null;
      _userRole = 'viewer'; // Reset role saat logout
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.remove('authToken');
      // await prefs.remove('userRole');
      notifyListeners();
    } catch (e) {
      print("Error during logout: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkLoginStatus() async {
    // Implementasi untuk mengambil token/role dari penyimpanan lokal
  }
}
