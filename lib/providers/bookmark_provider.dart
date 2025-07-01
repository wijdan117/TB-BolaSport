// lib/providers/bookmark_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tb_project/models/article_model.dart'; // Menggunakan model Article

class BookmarkProvider extends ChangeNotifier {
  List<Article> _bookmarkedArticles = [];
  bool _isLoading = false;

  List<Article> get bookmarkedArticles => _bookmarkedArticles;
  bool get isLoading => _isLoading;

  BookmarkProvider() {
    _loadBookmarks(); // Muat bookmark saat provider dibuat
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Muat bookmark dari penyimpanan lokal
  Future<void> _loadBookmarks() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? bookmarksJson = prefs.getString('bookmarked_articles');
      if (bookmarksJson != null) {
        final List<dynamic> decodedList = json.decode(bookmarksJson);
        _bookmarkedArticles = decodedList.map((json) => Article.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      _bookmarkedArticles = []; // Kosongkan jika ada error loading
    } finally {
      _setLoading(false);
    }
  }

  // Simpan bookmark ke penyimpanan lokal
  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedList = json.encode(_bookmarkedArticles.map((article) => article.toJson()).toList());
      await prefs.setString('bookmarked_articles', encodedList);
    } catch (e) {
      debugPrint('Error saving bookmarks: $e');
    }
  }

  // Tambah artikel ke bookmark
  Future<void> addBookmark(Article article) async {
    if (!_bookmarkedArticles.any((a) => a.id == article.id)) {
      _bookmarkedArticles.add(article);
      await _saveBookmarks();
      notifyListeners();
      debugPrint('Artikel ${article.title} ditambahkan ke bookmark.');
    }
  }

  // Hapus artikel dari bookmark
  Future<void> removeBookmark(String articleId) async {
    _bookmarkedArticles.removeWhere((article) => article.id == articleId);
    await _saveBookmarks();
    notifyListeners();
    debugPrint('Artikel dengan ID $articleId dihapus dari bookmark.');
  }

  // Cek apakah artikel sudah di-bookmark
  bool isBookmarked(String articleId) {
    return _bookmarkedArticles.any((article) => article.id == articleId);
  }
}
