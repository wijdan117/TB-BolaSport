// lib/models/news_model.dart

class NewsArticle {
  final String id; // ID unik untuk setiap berita (penting untuk CRUD)
  final String title;
  final String? imageUrl;
  final String? snippet;
  final String? content;
  final String? source;
  final DateTime? publishedAt;

  NewsArticle({
    required this.id, // ID sekarang wajib
    required this.title,
    this.imageUrl,
    this.snippet,
    this.content,
    this.source,
    this.publishedAt,
  });

  // Factory constructor untuk membuat objek NewsArticle dari JSON (News API contoh)
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(), // Gunakan ID dari API, atau buat ID sementara jika tidak ada
      title: json['title'] ?? 'Judul Tidak Tersedia',
      imageUrl: json['urlToImage'] ?? json['imageUrl'], // Kompatibilitas dengan simulasi sebelumnya
      snippet: json['description'] ?? json['snippet'],
      content: json['content'],
      source: json['source'] != null && json['source'] is Map ? json['source']['name'] : json['source'] ?? 'Tidak Diketahui',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'].toString()) // Handle string dan DateTime
          : null,
    );
  }

  // Metode untuk mengkonversi objek NewsArticle ke JSON (untuk dikirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'snippet': snippet,
      'content': content,
      'source': source,
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }
}
