import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tb_project/models/article_model.dart';
import 'package:tb_project/services/api_service.dart';
import 'package:tb_project/screens/add_edit_news_screen.dart';
import 'package:provider/provider.dart';
import 'package:tb_project/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

const Color appColorPrimary = Color(0xFF4CAF50);
const String appFontFamily = 'Inter';

class ManageNewsScreen extends StatefulWidget {
  const ManageNewsScreen({super.key});

  @override
  State<ManageNewsScreen> createState() => _ManageNewsScreenState();
}

class _ManageNewsScreenState extends State<ManageNewsScreen> {
  final ApiService _apiService = ApiService();
  Future<List<Article>>? _myArticlesFuture;
  final Set<String> _deletingArticleIds = {};

  @override
  void initState() {
    super.initState();
    _loadMyArticles();
  }

  Future<void> _loadMyArticles() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.authToken == null || authProvider.authToken!.isEmpty) {
      setState(() {
        _myArticlesFuture = Future.error('Anda tidak terautentikasi untuk melihat artikel Anda.');
      });
      return;
    }
    setState(() {
      _myArticlesFuture = _fetchArticles(authProvider.authToken!);
    });
  }

  Future<List<Article>> _fetchArticles(String token) async {
    final articles = await _apiService.getMyArticles(token);
    articles.sort((a, b) => (b.createdAt).compareTo(a.createdAt));
    return articles;
  }

  void _navigateToForm({Article? article}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditNewsScreen(article: article)),
    );
    if (result == true) {
      _loadMyArticles();
    }
  }

  Future<void> _handleDelete(String articleId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.authToken == null || authProvider.authToken!.isEmpty) {
        throw Exception('Token tidak ditemukan');
      }

      setState(() {
        _deletingArticleIds.add(articleId);
      });

      await _apiService.deleteArticle(authProvider.authToken!, articleId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil dihapus'), backgroundColor: Colors.green),
        );
      }
      _loadMyArticles();
    } catch (e) {
      if (mounted) {
        setState(() {
          _deletingArticleIds.remove(articleId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus artikel: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, Article article) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus artikel "${article.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleDelete(article.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, Article article) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Artikel'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToForm(article: article);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Artikel', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context, article);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) return '${difference.inDays} hari lalu';
    if (difference.inHours > 0) return '${difference.inHours} jam lalu';
    if (difference.inMinutes > 0) return '${difference.inMinutes} menit lalu';
    return 'Baru saja';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel Saya'),
        backgroundColor: appColorPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Article>>(
        future: _myArticlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: appColorPrimary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final myArticles = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _loadMyArticles,
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: myArticles.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildArticleCard(myArticles[index]),
              ),
            );
          }
          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: appColorPrimary,
        tooltip: 'Tulis Artikel Baru',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    final isDeleting = _deletingArticleIds.contains(article.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isDeleting ? null : () => _navigateToForm(article: article),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.featuredImageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: article.featuredImageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDeleting ? Colors.grey : Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.summary,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDeleting ? Colors.grey[400] : Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                article.isPublished ?? false ? 'Diterbitkan' : 'Draft',
                                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: (article.isPublished ?? false) ? Colors.green[600] : Colors.orange[600],
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 8),
                            if (article.category != null && article.category!.isNotEmpty)
                              Chip(
                                label: Text(
                                  article.category!,
                                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: Colors.blue[600],
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('d MMM yy', 'id_ID').format(article.createdAt),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                tooltip: 'Edit Artikel',
                onPressed: isDeleting ? null : () => _navigateToForm(article: article),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                tooltip: 'Hapus Artikel',
                onPressed: isDeleting ? null : () => _showDeleteDialog(context, article),
              ),
            ],
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_add_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Anda belum menulis artikel',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: appFontFamily),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tekan tombol + di pojok kanan bawah untuk membuat artikel pertama Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], height: 1.5, fontFamily: appFontFamily),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
