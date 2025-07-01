// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tb_project/providers/auth_provider.dart';
import 'package:tb_project/providers/bookmark_provider.dart';
import 'package:tb_project/screens/login_screen.dart';
import 'package:tb_project/screens/news_detail_screen.dart';
// import 'package:tb_project/screens/add_edit_news_screen.dart'; // Tidak diperlukan lagi di sini
import 'package:tb_project/services/api_service.dart';
import 'package:tb_project/models/article_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tb_project/screens/profile_screen.dart';
// import 'package:tb_project/screens/manage_news_screen.dart'; // Tidak diperlukan lagi di sini

class HomeScreen extends StatefulWidget {
  final String userRole;

  const HomeScreen({super.key, this.userRole = 'viewer'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late ApiService _apiService;
  late Future<List<Article>> _topHeadlines;
  late Future<List<Article>> _recentNews; // Untuk tab Home

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _fetchNewsContent();
  }

  void _fetchNewsContent() {
    setState(() {
      _topHeadlines = _apiService.getPublicNews();
      _recentNews = _apiService.getPublicNews();
    });
  }

  // Fungsi untuk mengkonfirmasi dan menghapus bookmark (tetap ada untuk tab Bookmark)
  Future<void> _confirmAndDeleteBookmark(BuildContext context, String articleId, String articleTitle) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Konfirmasi Hapus Bookmark'),
          content: Text('Apakah Anda yakin ingin menghapus bookmark "$articleTitle"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        Provider.of<BookmarkProvider>(context, listen: false).removeBookmark(articleId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark berhasil dihapus.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus bookmark: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Widget untuk halaman Home (tab pertama) - Tanpa CRUD
  Widget _buildHomePage() {
    return SingleChildScrollView( // Tidak perlu Stack lagi karena tidak ada FAB
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Headline',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Article>>(
            future: _topHeadlines,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Colors.green[700]));
              } else if (snapshot.hasError) {
                return Center(child: Text('Gagal memuat headline: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Tidak ada headline tersedia.'));
              } else {
                final headline = snapshot.data![0];
                return Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  elevation: 4,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailScreen(article: headline),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (headline.featuredImageUrl.isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: headline.featuredImageUrl,
                                placeholder: (context, url) => Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: CircularProgressIndicator(color: Colors.green[700]),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                ),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                headline.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                headline.summary,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tombol Bookmark untuk Top Headline (tetap ada)
                      Consumer<BookmarkProvider>(
                        builder: (context, bookmarkProvider, child) {
                          final bool isBookmarked = bookmarkProvider.isBookmarked(headline.id);
                          return Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: Icon(
                                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: isBookmarked ? Colors.green[700] : Colors.grey,
                                size: 24,
                              ),
                              onPressed: () {
                                if (isBookmarked) {
                                  bookmarkProvider.removeBookmark(headline.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Bookmark dihapus!')),
                                  );
                                } else {
                                  bookmarkProvider.addBookmark(headline);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Artikel ditambahkan ke bookmark!')),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 20),

          const Text(
            'Headline',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Article>>(
            future: _recentNews,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Colors.green[700]));
              } else if (snapshot.hasError) {
                return Center(child: Text('Gagal memuat berita terbaru: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Tidak ada berita terbaru tersedia.'));
              } else {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final article = snapshot.data![index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.0),
                      ),
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsDetailScreen(article: article),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (article.featuredImageUrl.isNotEmpty)
                                  CachedNetworkImage(
                                    imageUrl: article.featuredImageUrl,
                                    placeholder: (context, url) => Container(
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: Center(
                                        child: CircularProgressIndicator(color: Colors.green[700]),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      height: 100,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                                    ),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 100,
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    article.title,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tombol Bookmark untuk berita di grid (tetap ada)
                          Consumer<BookmarkProvider>(
                            builder: (context, bookmarkProvider, child) {
                              final bool isBookmarked = bookmarkProvider.isBookmarked(article.id);
                              return Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  icon: Icon(
                                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    color: isBookmarked ? Colors.green[700] : Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (isBookmarked) {
                                      bookmarkProvider.removeBookmark(article.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Bookmark dihapus!')),
                                      );
                                    } else {
                                      bookmarkProvider.addBookmark(article);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Artikel ditambahkan ke bookmark!')),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk halaman Bookmark Berita (tab kedua)
  Widget _buildBookmarkPage() {
    return Consumer<BookmarkProvider>(
      builder: (context, bookmarkProvider, child) {
        if (bookmarkProvider.isLoading) {
          return Center(child: CircularProgressIndicator(color: Colors.green[700]));
        } else if (bookmarkProvider.bookmarkedArticles.isEmpty) {
          return const Center(child: Text('Belum ada berita yang di-bookmark.'));
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bookmarkProvider.bookmarkedArticles.length,
            itemBuilder: (context, index) {
              final article = bookmarkProvider.bookmarkedArticles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailScreen(article: article),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.featuredImageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: article.featuredImageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green[700])),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                article.summary,
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  icon: const Icon(Icons.bookmark_remove, color: Colors.red, size: 24),
                                  onPressed: () {
                                    _confirmAndDeleteBookmark(context, article.id, article.title);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  // List of pages for BottomNavigationBar
  List<Widget> _pages() {
    return [
      _buildHomePage(),
      _buildBookmarkPage(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: (_selectedIndex == 0)
            ? RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Bola',
                      style: TextStyle(color: Colors.black87),
                    ),
                    TextSpan(
                      text: 'Sport',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ],
                ),
              )
            : (_selectedIndex == 1)
                ? const Text('Bookmark Berita', style: TextStyle(fontWeight: FontWeight.bold))
                : const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark Berita',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            _fetchNewsContent();
          }
        },
      ),
      // FAB untuk menambah berita baru (dipindahkan ke _buildHomePage)
      // floatingActionButton: ... (dihapus dari Scaffold level)
    );
  }
}
