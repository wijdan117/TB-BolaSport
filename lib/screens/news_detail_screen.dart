// lib/screens/news_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:tb_project/models/news_model.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Untuk caching gambar
import 'package:intl/intl.dart'; // Untuk format tanggal (tambahkan ke pubspec.yaml jika belum ada)

class NewsDetailScreen extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // Format tanggal jika tersedia
    final String formattedDate = article.publishedAt != null
        ? DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID').format(article.publishedAt!) // Format Indonesia
        : 'Tanggal tidak tersedia';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Berita
              if (article.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12), // Sudut membulat pada gambar
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    placeholder: (context, url) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.green[700]),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 70, color: Colors.grey),
                    ),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                  ),
                ),
              const SizedBox(height: 16),
              // Judul Berita
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              // Informasi Publikasi (Tanggal dan Sumber)
              Text(
                'Dipublikasikan pada: $formattedDate oleh ${article.source ?? "Tidak diketahui"}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              // Konten Berita
              Text(
                article.content ?? 'Konten berita tidak tersedia.',
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5, // Spasi antar baris
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
