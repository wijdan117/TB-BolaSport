import 'package:flutter/material.dart';
import 'package:tb_project/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoggedIn = false;
  String? _authToken;
  String? _userEmail;
  String? _userName;
  String _userRole = 'viewer';
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get authToken => _authToken;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String get userRole => _userRole;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadAuthToken();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    _userEmail = prefs.getString('user_email');
    _userName = prefs.getString('user_name');
    _userRole = prefs.getString('user_role') ?? 'viewer';

    if (_authToken != null && _authToken!.isNotEmpty) {
      _isLoggedIn = true;
      debugPrint('Token dimuat dari SharedPreferences: $_authToken');
    } else {
      _isLoggedIn = false;
      debugPrint('Tidak ada token di SharedPreferences.');
    }
    notifyListeners();
  }

  Future<void> _saveAuthToken(String token, String email, String username, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_email', email);
    await prefs.setString('user_name', username);
    await prefs.setString('user_role', role);
    debugPrint('Token disimpan ke SharedPreferences.');
  }

  Future<void> _clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    debugPrint('Token dihapus dari SharedPreferences.');
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final String token = await _apiService.login(email, password);
      
      _isLoggedIn = true;
      _authToken = token;
      _userEmail = email;
      _userName = 'Pengguna';
      _userRole = 'admin';

      await _saveAuthToken(token, email, _userName!, _userRole);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error during login (AuthProvider): $e");
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

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));

      debugPrint('Simulasi Register Berhasil!');
      _isLoggedIn = true;
      _authToken = 'simulated_token_for_new_user_${DateTime.now().millisecondsSinceEpoch}';
      _userEmail = email;
      _userName = 'Pengguna Baru';
      _userRole = 'admin';

      await _saveAuthToken(_authToken!, email, _userName!, _userRole);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error during registration (AuthProvider): $e");
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
      await _clearAuthToken();
      _isLoggedIn = false;
      _authToken = null;
      _userEmail = null;
      _userName = null;
      _userRole = 'viewer';
      notifyListeners();
      debugPrint('Proses logout di sisi klien selesai. Token dihapus dari AuthProvider.');
    } catch (e) {
      debugPrint("Error during logout (AuthProvider): $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
