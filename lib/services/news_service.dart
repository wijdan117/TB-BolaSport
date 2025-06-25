// lib/services/news_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tb_project/models/news_model.dart';

class NewsService {
  // GANTI DENGAN BASE URL DAN API KEY ANDA YANG SEBENARNYA!
  final String _baseUrl = 'https://newsapi.org/v2';
  final String _apiKey = '4be0a49dccf440989043ce1a62dd2203 '; 

  // --- Data Simulasi Berita (Untuk CRUD) ---
  // Dalam aplikasi nyata, ini akan berinteraksi dengan database/backend
  static final List<NewsArticle> _newsData = [
    NewsArticle(
      id: '1',
      title: 'Lorem ipsum adalah contoh teks atau dummy dalam industri percetakan dan penataan huruf atau',
      imageUrl: 'https://placehold.co/600x400/CCCCCC/FFFFFF?text=Headline+Image+1',
      snippet: 'Ini adalah cuplikan singkat dari headline berita utama yang menarik perhatian pembaca.',
      content: 'Konten lengkap dari berita utama yang sangat penting dan mendalam. Ini mencakup semua detail yang relevan, analisis, dan kutipan dari narasumber. Dengan panjang yang memadai, pembaca dapat memahami keseluruhan cerita.',
      source: 'Sumber BolaSport Utama',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NewsArticle(
      id: '2',
      title: 'Judul Berita Terbaru Olahraga Dunia',
      imageUrl: 'https://placehold.co/300x200/BBBBBB/000000?text=News+Image+2',
      snippet: 'Berita singkat tentang topik menarik lainnya.',
      content: 'Ini adalah isi lengkap dari berita kedua. Sebuah artikel informatif yang membahas perkembangan terbaru dalam dunia olahraga, dilengkapi dengan data dan fakta yang relevan.',
      source: 'Sumber BolaSport News',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NewsArticle(
      id: '3',
      title: 'Trump’s trade war hits his second-favorite set of wheels, the golf cart',
      imageUrl: 'https://placehold.co/300x200/DDDDDD/333333?text=News+Image+3',
      snippet: 'Friction on March 20, 2025.',
      content: '''ACCRA—The first 100-days of his second term yet to do and done in the area of bolt heads. Donald J. Trump, an avid golfer, has often been on the course and photographed in a golf cart, typically a golf cart made by domestic companies Club Car or E-Z-GO. Across The Gulf, 100-days of his second term yet to do and done in the area of bolt heads. Donald J. Trump, an avid golfer, has often been on the course and photographed in a golf cart, typically a golf cart made by domestic companies Club Car or E-Z-GO. Across The Gulf, 100-days of his second term yet to do and done in the area of bolt heads. Donald J. Trump, an avid golfer, has often been on the course and photographed in a golf cart, typically a golf cart made by domestic companies Club Car or E-Z-GO.''',
      source: 'SOURCE NEWSCOM',
      publishedAt: DateTime(2025, 3, 20),
    ),
    NewsArticle(
      id: '4',
      title: 'Analisis Mendalam Liga Champions',
      imageUrl: 'https://placehold.co/300x200/EEEEEE/555555?text=News+Image+4',
      snippet: 'Cuplikan singkat berita ketiga.',
      content: 'Isi lengkap berita ketiga yang berisi informasi menarik seputar dunia olahraga, termasuk wawancara eksklusif dan prediksi pertandingan mendatang.',
      source: 'BolaSport Lainnya',
      publishedAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
  ];
  // --- Akhir Data Simulasi ---

  // Fungsi untuk mendapatkan semua berita (digunakan oleh admin)
  Future<List<NewsArticle>> fetchAllNews() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi jaringan
    return List.from(_newsData); // Mengembalikan salinan agar data asli tidak termodifikasi langsung
  }


  Future<List<NewsArticle>> fetchTopHeadlines() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/top-headlines?country=id&apiKey=$_apiKey'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['articles'] == null) {
            throw Exception('Struktur respons API tidak valid: Tidak ada kunci "articles".');
        }
        final List<dynamic> articlesJson = data['articles'];
        // Pastikan setiap artikel dari API memiliki ID (Anda bisa generate jika API tidak menyediakannya)
        return articlesJson.map((json) => NewsArticle.fromJson(json..['id'] = json['url'] ?? DateTime.now().millisecondsSinceEpoch.toString())).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Gagal memuat berita utama: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('Error fetching top headlines: $e');
      // Jika terjadi error API, fallback ke data simulasi untuk tampilan awal
      print('Fallback to simulated data for top headlines.');
      return [
        NewsArticle(
          id: 'fallback_1',
          title: 'Gagal memuat berita: Silakan periksa koneksi internet atau API Key.',
          imageUrl: 'https://placehold.co/600x400/FF0000/FFFFFF?text=Error+Loading',
          snippet: 'Telah terjadi kesalahan saat mengambil berita utama. Silakan coba lagi nanti.',
          content: 'Detail kesalahan: $e. Pastikan Anda telah mengganti "YOUR_NEWS_API_KEY_HERE" di NewsService.dart dengan API Key yang valid dan terdaftar.',
          source: 'System Error',
          publishedAt: DateTime.now(),
        ),
      ];
    }
  }

  Future<List<NewsArticle>> fetchRecentNews() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/everything?q=sport&sortBy=publishedAt&language=en&apiKey=$_apiKey'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['articles'] == null) {
            throw Exception('Struktur respons API tidak valid: Tidak ada kunci "articles".');
        }
        final List<dynamic> articlesJson = data['articles'];
        // Pastikan setiap artikel dari API memiliki ID
        return articlesJson.map((json) => NewsArticle.fromJson(json..['id'] = json['url'] ?? DateTime.now().millisecondsSinceEpoch.toString())).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Gagal memuat berita terbaru: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recent news: $e');
      // Jika terjadi error API, fallback ke data simulasi
      print('Fallback to simulated data for recent news.');
      return [
        NewsArticle(
          id: 'fallback_2',
          title: 'Gagal memuat berita: Periksa koneksi atau API.',
          imageUrl: 'https://placehold.co/300x200/FF0000/FFFFFF?text=Error+Loading',
          snippet: 'Telah terjadi kesalahan saat mengambil berita terbaru.',
          content: 'Detail kesalahan: $e. Pastikan Anda telah mengganti "YOUR_NEWS_API_KEY_HERE" di NewsService.dart dengan API Key yang valid dan terdaftar.',
          source: 'System Error',
          publishedAt: DateTime.now(),
        ),
      ];
    }
  }

  // --- Fungsi CRUD Simulasi ---

  // Menambah berita baru
  Future<NewsArticle> addNewsArticle(NewsArticle article) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi jaringan
    final newArticle = NewsArticle(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate ID baru
      title: article.title,
      imageUrl: article.imageUrl,
      snippet: article.snippet,
      content: article.content,
      source: article.source,
      publishedAt: article.publishedAt ?? DateTime.now(),
    );
    _newsData.add(newArticle);
    print('Berita ditambahkan: ${newArticle.title}');
    return newArticle;
  }

  // Memperbarui berita yang sudah ada
  Future<NewsArticle> updateNewsArticle(NewsArticle article) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi jaringan
    final index = _newsData.indexWhere((element) => element.id == article.id);
    if (index != -1) {
      _newsData[index] = article;
      print('Berita diperbarui: ${article.title}');
      return article;
    } else {
      throw Exception('Berita dengan ID ${article.id} tidak ditemukan.');
    }
  }

  // Menghapus berita
  Future<void> deleteNewsArticle(String id) async {
    await Future.delayed(const Duration(seconds: 0)); // Simulasi jaringan cepat
    _newsData.removeWhere((article) => article.id == id);
    print('Berita dengan ID $id dihapus.');
  }
}
