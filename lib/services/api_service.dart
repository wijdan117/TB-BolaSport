import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tb_project/models/article_model.dart'; // Path diperbarui
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class ApiService {
  // Alamat dasar dari server API Anda
  static const String _baseUrl = 'http://45.149.187.204:3000/api';

  // Helper untuk mengurai pesan error dari respons API
  String _parseErrorMessage(http.Response response) {
    String errorMessage = 'Terjadi kesalahan tidak diketahui.';
    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      errorMessage = errorData['body']?['message'] ?? errorData['message'] ?? errorData['error'] ?? errorMessage;
    } catch (_) {
      errorMessage = response.reasonPhrase ?? errorMessage;
    }
    return errorMessage;
  }

  // Fungsi Login
  Future<String> login(String email, String password) async {
    final Uri loginUrl = Uri.parse('$_baseUrl/auth/login');

    try {
      final response = await http.post(
        loginUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      debugPrint('Login Response Status: ${response.statusCode}');
      debugPrint('Login Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('body') &&
            responseData['body'] is Map &&
            responseData['body'].containsKey('data') &&
            responseData['body']['data'] is Map &&
            responseData['body']['data'].containsKey('token')) {
          
          final String token = responseData['body']['data']['token'];
          
          if (token.isNotEmpty) {
            return token;
          }
        }
        
        throw Exception('Format token dari server tidak dikenali. Respons: ${response.body}');

      } else {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      debugPrint('Error di fungsi login: $e');
      throw Exception('Gagal terhubung ke server. Periksa koneksi internet Anda. Error: $e');
    }
  }

  // Fungsi Register
  Future<String> register(String email, String password) async {
    final Uri registerUrl = Uri.parse('$_baseUrl/auth/register');

    try {
      final response = await http.post(
        registerUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      debugPrint('Register Response Status: ${response.statusCode}');
      debugPrint('Register Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('body') &&
            responseData['body'] is Map &&
            responseData['body'].containsKey('data') &&
            responseData['body']['data'] is Map &&
            responseData['body']['data'].containsKey('token')) {
          
          final String token = responseData['body']['data']['token'];
          
          if (token.isNotEmpty) {
            return token;
          }
        }
        
        throw Exception('Registrasi berhasil, tetapi token tidak ditemukan dalam respons. Respons: ${response.body}');

      } else {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      debugPrint('Error di fungsi register: $e');
      throw Exception('Gagal terhubung ke server untuk registrasi. Error: $e');
    }
  }

  // Fungsi untuk mendapatkan berita publik dengan kategori (GET /api/news)
  Future<List<Article>> getPublicNews({String? category}) async {
    final Map<String, String> queryParameters = {};

    if (category != null && category.toLowerCase() != 'semua') {
      queryParameters['category'] = category;
    }

    final Uri newsUrl = Uri.http(
      '45.149.187.204:3000',
      '/api/news',
      queryParameters.isEmpty ? null : queryParameters,
    );
    
    debugPrint('Fetching public news from: $newsUrl');

    try {
      final response = await http.get(newsUrl);
      
      debugPrint('Get Public News Response Status: ${response.statusCode}');
      debugPrint('Get Public News Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData.containsKey('body') &&
            responseData['body'] is Map &&
            responseData['body'].containsKey('data') &&
            responseData['body']['data'] is List) {
                  
          final List<dynamic> articlesJson = responseData['body']['data'];
          
          List<Article> articles = articlesJson
              .map((jsonItem) => Article.fromJson(jsonItem))
              .toList();
                  
          return articles;
        } else {
          throw Exception("Format data berita dari server tidak dikenali. Respons: ${response.body}");
        }
      } else {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      debugPrint('Error di getPublicNews: $e');
      throw Exception('Gagal terhubung ke server berita. Error: $e');
    }
  }

  // Fungsi untuk mengambil satu berita berdasarkan slug (GET /api/news/{slug})
  Future<Article> getNewsBySlug(String slug) async {
    final Uri newsUrl = Uri.parse('$_baseUrl/news/$slug');

    try {
      final response = await http.get(newsUrl);

      debugPrint('Get News By Slug Response Status: ${response.statusCode}');
      debugPrint('Get News By Slug Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('body') &&
            responseData['body'] is Map &&
            responseData['body'].containsKey('data') &&
            responseData['body']['data'] is Map) {
          return Article.fromJson(responseData['body']['data']);
        } else {
          throw Exception("Format data detail berita tidak sesuai. Respons: ${response.body}");
        }
      } else {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      debugPrint('Error di getNewsBySlug: $e');
      throw Exception('Gagal terhubung ke server untuk detail berita. Error: $e');
    }
  }

  // FUNGSI CRUD: GET MY ARTICLES (memerlukan token) (GET /api/author/news)
  Future<List<Article>> getMyArticles(String token) async {
    final Uri url = Uri.parse('$_baseUrl/author/news');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint('Get My Articles Response Status: ${response.statusCode}');
      debugPrint('Get My Articles Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('body') && responseData['body'] is Map && responseData['body'].containsKey('success') && responseData['body'].containsKey('data')) {
            if (responseData['body']['success'] == true) {
                final List<dynamic> articlesJson = responseData['body']['data'];
                return articlesJson.map((json) => Article.fromJson(json)).toList();
            } else {
                throw Exception(responseData['body']['message'] ?? 'Gagal memuat artikel saya.');
            }
        } else {
             throw Exception("Format data artikel saya dari server tidak dikenali. Respons: ${response.body}");
        }
      } else {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      debugPrint('Error di getMyArticles: $e');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // FUNGSI CRUD: CREATE (memerlukan token) (POST /api/author/news)
  Future<void> createArticle(String token, Article article) async {
    final Uri url = Uri.parse('$_baseUrl/author/news');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(article.toJson()), // Menggunakan toJson() dari Article
      );
      debugPrint('Create Article Request URL: $url');
      debugPrint('Create Article Request Body: ${jsonEncode(article.toJson())}');
      debugPrint('Create Article Response Status: ${response.statusCode}');
      debugPrint('Create Article Response Body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('Artikel berhasil dibuat!');
      } else {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      debugPrint('Error di createArticle: $e');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // FUNGSI CRUD: UPDATE (memerlukan token) (PUT /api/author/news/{id})
  Future<void> updateArticle(String token, String articleId, Article article) async {
    final Uri url = Uri.parse('$_baseUrl/author/news/$articleId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(article.toJson()), // Menggunakan toJson() dari Article
      );
      debugPrint('Update Article Request URL: $url');
      debugPrint('Update Article Request Body: ${jsonEncode(article.toJson())}');
      debugPrint('Update Article Response Status: ${response.statusCode}');
      debugPrint('Update Article Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Artikel berhasil diperbarui!');
      } else {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      debugPrint('Error di updateArticle: $e');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // FUNGSI CRUD: DELETE (memerlukan token) (DELETE /api/author/news/{id})
  Future<void> deleteArticle(String token, String articleId) async {
    final Uri url = Uri.parse('$_baseUrl/author/news/$articleId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint('Delete Article Request URL: $url');
      debugPrint('Delete Article Response Status: ${response.statusCode}');
      debugPrint('Delete Article Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Artikel berhasil dihapus!');
      } else {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      debugPrint('Error di deleteArticle: $e');
      throw Exception('Error: ${e.toString()}');
    }
  }
}
