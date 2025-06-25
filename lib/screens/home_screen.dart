// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Pastikan baris ini TIDAK DIKOMENTARI
import 'package:tb_project/providers/auth_provider.dart'; // Pastikan baris ini TIDAK DIKOMENTARI
import 'package:tb_project/screens/login_screen.dart';
import 'package:tb_project/screens/news_detail_screen.dart';
import 'package:tb_project/screens/add_edit_news_screen.dart'; // Import AddEditNewsScreen
import 'package:tb_project/services/news_service.dart';
import 'package:tb_project/models/news_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:tb_project/screens/profile_screen.dart'; // Import ProfileScreen

class HomeScreen extends StatefulWidget {
  final String userRole; // Menerima peran pengguna dari main.dart

  const HomeScreen({super.key, this.userRole = 'viewer'}); // Default viewer jika tidak ada peran

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Index untuk BottomNavigationBar
  final NewsService _newsService = NewsService();

  late Future<List<NewsArticle>> _topHeadlines;
  late Future<List<NewsArticle>> _allNewsForManage; // Digunakan untuk tab "Daftar Berita"
  late Future<List<NewsArticle>> _recentNews; // Untuk tab Home

  @override
  void initState() {
    super.initState();
    _fetchNewsContent();
  }

  // Fungsi untuk memuat ulang semua konten berita
  void _fetchNewsContent() {
    setState(() {
      _topHeadlines = _newsService.fetchTopHeadlines();
      _recentNews = _newsService.fetchRecentNews(); // Digunakan untuk tampilan grid di Home
      _allNewsForManage = _newsService.fetchAllNews(); // Digunakan untuk tampilan daftar di Manage
    });
  }

  // Fungsi untuk mengkonfirmasi dan menghapus berita
  Future<void> _confirmAndDeleteNews(BuildContext context, String newsId, String newsTitle) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus berita "$newsTitle"?'),
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
        await _newsService.deleteNewsArticle(newsId);
        _fetchNewsContent(); // Muat ulang berita setelah penghapusan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berita berhasil dihapus.'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus berita: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Widget untuk halaman Home (tab pertama)
  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Top Headline
          const Text(
            'Top Headline',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<NewsArticle>>(
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
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailScreen(article: headline),
                      ),
                    );
                  },
                  child: Card(
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
                        if (headline.imageUrl != null)
                          CachedNetworkImage(
                            imageUrl: headline.imageUrl!,
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
                            headline.snippet ?? 'Tidak ada cuplikan tersedia.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 20),

          // Bagian Berita Terbaru (GridView)
          const Text(
            'Headline',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<NewsArticle>>(
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
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsDetailScreen(article: article),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300, width: 1.0),
                        ),
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (article.imageUrl != null)
                              CachedNetworkImage(
                                imageUrl: article.imageUrl!,
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

  // Widget untuk halaman Daftar Berita (tab kedua) - Ini adalah Admin View
  Widget _buildManageNewsPage() {
    return Stack( // Gunakan Stack untuk FAB
      children: [
        FutureBuilder<List<NewsArticle>>(
          future: _allNewsForManage,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.green[700]));
            } else if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat berita: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Tidak ada berita untuk dikelola.'));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final article = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: InkWell( // Menggunakan InkWell agar bisa diklik dan ada ripple effect
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
                            if (article.imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: article.imageUrl!,
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
                                    article.snippet ?? '',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Aksi CRUD (Edit & Delete) - Sekarang selalu tampil karena semua user bisa edit
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                          onPressed: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AddEditNewsScreen(article: article),
                                              ),
                                            );
                                            _fetchNewsContent(); // Muat ulang setelah edit
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                          onPressed: () {
                                            _confirmAndDeleteNews(context, article.id, article.title);
                                          },
                                        ),
                                      ],
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
        ),
        // Floating Action Button untuk menambah berita (sekarang selalu tampil)
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditNewsScreen(),
                ),
              );
              _fetchNewsContent(); // Muat ulang setelah menambah
            },
            backgroundColor: Colors.green[700],
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // List of pages for BottomNavigationBar
  List<Widget> _pages() {
    return [
      _buildHomePage(),
      _buildManageNewsPage(),
      // Halaman untuk "Profile"
      const ProfileScreen(), // Menggunakan ProfileScreen yang baru dibuat
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Karena kita mengembalikan import provider di atas, kita bisa menggunakan Provider.of di sini
    final authProvider = Provider.of<AuthProvider>(context); // <<<--- AKTIFKAN KEMBALI BARIS INI

    return Scaffold(
      appBar: AppBar(
        title: (_selectedIndex == 0)
            ? RichText( // Menggunakan RichText untuk judul BolaSport
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
                ? const Text('Daftar News', style: TextStyle(fontWeight: FontWeight.bold))
                : const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Tombol "Manage" di AppBar, hanya tampil di tab "Daftar Berita"
          if (_selectedIndex == 1) // Tampilkan hanya jika di tab "Daftar Berita"
            Padding(
              padding: const EdgeInsets.only(right: 16.0), // Beri padding kanan
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditNewsScreen(),
                    ),
                  );
                  _fetchNewsContent(); // Muat ulang setelah menambah
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Bentuk oval/bulat
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Manage', style: TextStyle(fontSize: 14)),
              ),
            ),
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout(); // Sekarang bisa memanggil logout dari AuthProvider
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
            icon: Icon(Icons.list_alt),
            label: 'Daftar Berita',
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
          // Hanya panggil _fetchNewsContent jika berpindah ke tab yang membutuhkan refresh data
          if (index == 0 || index == 1) { // Jika Home atau Daftar Berita
            _fetchNewsContent();
          }
        },
      ),
    );
  }
}
