// lib/screens/news_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:tb_project/models/article_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tb_project/providers/bookmark_provider.dart';

class NewsDetailScreen extends StatelessWidget {
  final Article article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final String formattedDate = article.publishedAt != null
        ? DateFormat('EEEE, dd MMMM HH:mm', 'id_ID').format(article.publishedAt)
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
            Navigator.pop(context);
          },
        ),
        actions: [
          Consumer<BookmarkProvider>(
            builder: (context, bookmarkProvider, child) {
              final bool isBookmarked = bookmarkProvider.isBookmarked(article.id);
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.green[700] : Colors.grey,
                  size: 28,
                ),
                onPressed: () {
                  if (isBookmarked) {
                    bookmarkProvider.removeBookmark(article.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bookmark dihapus dari detail!')),
                    );
                  } else {
                    bookmarkProvider.addBookmark(article);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Artikel ditambahkan ke bookmark dari detail!')),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.featuredImageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: article.featuredImageUrl,
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
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dipublikasikan pada: $formattedDate oleh ${article.authorName}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                article.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
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
