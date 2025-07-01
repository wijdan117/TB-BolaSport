// lib/screens/add_edit_news_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:tb_project/models/article_model.dart'; // Updated path
import 'package:tb_project/services/api_service.dart'; // Updated path
import 'package:intl/intl.dart'; // For date formatting
import 'package:provider/provider.dart'; // For Provider
import 'package:tb_project/providers/auth_provider.dart'; // For AuthProvider

// Color constants (consistent green theme)
const Color appColorGreen = Color(0xFF4CAF50); // Green (Colors.green[700] can be used directly)
const Color appColorTextBlack = Color(0xFF0D0D0D);
const Color appColorTextSlightlyLighterBlack = Color(0xFF333333);

// Enum for publishing status
enum PublishingStatus { draft, published }

class AddEditNewsScreen extends StatefulWidget {
  final Article? article;
  const AddEditNewsScreen({super.key, this.article});

  @override
  State<AddEditNewsScreen> createState() => _AddEditNewsScreenState();
}

class _AddEditNewsScreenState extends State<AddEditNewsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  String? _authToken; // Token from AuthProvider

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _summaryController;
  late TextEditingController _imageUrlController;
  late TextEditingController _categoryController;
  late TextEditingController _tagsController;
  late TextEditingController _publishedAtController;
  
  String? _selectedCategory;
  final List<String> _categories = const [
    'Politik', 'Hukum & Kriminal', 'Internasional', 'Peristiwa', 'Ekonomi',
    'Bisnis', 'Teknologi', 'Otomotif', 'Gaya Hidup', 'Kesehatan',
    'Pendidikan', 'Kuliner', 'Liburan', 'Hiburan', 'Kisah Inspiratif',
    'Sains', 'Lingkungan', 'Olahraga'
  ];

  PublishingStatus _status = PublishingStatus.published;
  bool _isLoading = false;
  bool get _isEditMode => widget.article != null;

  final FocusNode _imageUrlFocusNode = FocusNode();
  String _imageUrlForPreview = '';

  @override
  void initState() {
    super.initState();
    _authToken = Provider.of<AuthProvider>(context, listen: false).authToken;

    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _contentController = TextEditingController(text: widget.article?.content ?? '');
    _summaryController = TextEditingController(text: widget.article?.summary ?? '');
    _imageUrlController = TextEditingController(text: widget.article?.featuredImageUrl ?? '');
    _categoryController = TextEditingController(text: widget.article?.category ?? '');
    _tagsController = TextEditingController(text: widget.article?.tags.join(', ') ?? '');
    _status = (widget.article?.isPublished ?? true) ? PublishingStatus.published : PublishingStatus.draft;

    if (_isEditMode) {
      if (widget.article?.category != null && _categories.contains(widget.article!.category)) {
        _selectedCategory = widget.article!.category;
      }
      _imageUrlForPreview = widget.article?.featuredImageUrl ?? '';
    }

    _imageUrlFocusNode.addListener(() {
      if (!_imageUrlFocusNode.hasFocus && _imageUrlController.text.isNotEmpty) {
        setState(() {
          _imageUrlForPreview = _imageUrlController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _summaryController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    _publishedAtController.dispose();
    _imageUrlFocusNode.removeListener(() {});
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _imageUrlController.text = data.text!;
        _imageUrlForPreview = data.text!;
      });
    }
  }

  Future<void> _handleSaveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_authToken == null || _authToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda tidak terautentikasi. Silakan login ulang.'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    final List<String> tagsList = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    try {
      final articleData = Article(
        id: _isEditMode ? widget.article!.id : '',
        slug: _isEditMode ? widget.article!.slug : 'temp-slug-${DateTime.now().millisecondsSinceEpoch}',
        authorName: _isEditMode ? widget.article!.authorName : 'Unknown Author',

        title: _titleController.text,
        content: _contentController.text,
        summary: _summaryController.text.isEmpty ? '' : _summaryController.text, // <<<--- Perbaikan: Kirim "" jika kosong
        featuredImageUrl: _imageUrlController.text.isEmpty ? '' : _imageUrlController.text, // <<<--- Perbaikan: Kirim "" jika kosong
        category: _selectedCategory ?? '', // <<<--- Perbaikan: Kirim "" jika null
        tags: tagsList,
        isPublished: _status == PublishingStatus.published,
        
        publishedAt: _isEditMode ? widget.article!.publishedAt : DateTime.now(),
        createdAt: _isEditMode ? widget.article!.createdAt : DateTime.now(),
        updatedAt: _isEditMode ? widget.article!.updatedAt : DateTime.now(),
        viewCount: _isEditMode ? widget.article!.viewCount : 0,
      );

      if (_isEditMode) {
        await _apiService.updateArticle(_authToken!, articleData.id, articleData);
      } else {
        await _apiService.createArticle(_authToken!, articleData);
      }
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artikel berhasil disimpan!'), backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan artikel: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red));
      }
    } finally {
      if(mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article == null ? 'Tambah Berita Baru' : 'Edit Berita', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white)))
          else
            TextButton(
              onPressed: _handleSaveChanges,
              style: TextButton.styleFrom(backgroundColor: Colors.green[700]),
              child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _imageUrlController,
                focusNode: _imageUrlFocusNode,
                decoration: InputDecoration(
                  labelText: 'URL Gambar',
                  hintText: 'https://...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(icon: const Icon(Icons.paste), tooltip: 'Tempel dari Clipboard', onPressed: _pasteFromClipboard),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.green[700]!, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              _buildImagePreview(),
              const SizedBox(height: 24),
              
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Judul Berita', border: OutlineInputBorder()), validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _contentController, decoration: const InputDecoration(labelText: 'Isi Konten Berita', border: OutlineInputBorder(), alignLabelWithHint: true), maxLines: 10, validator: (value) => (value == null || value.length < 10) ? 'Konten minimal 10 karakter' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _summaryController, decoration: const InputDecoration(labelText: 'Ringkasan (Summary)', border: OutlineInputBorder(), alignLabelWithHint: true), maxLines: 3),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (pisahkan dengan koma)',
                  border: OutlineInputBorder(),
                  hintText: 'contoh: teknologi, flutter, berita',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tags tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.green[700]!, width: 2.0),
                  ),
                ),
                hint: const Text('Pilih Kategori'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Kategori harus dipilih' : null,
              ),
            
              const SizedBox(height: 24),
              const Text('Status Publikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
              const SizedBox(height: 8),
              SegmentedButton<PublishingStatus>(
                segments: const <ButtonSegment<PublishingStatus>>[
                  ButtonSegment<PublishingStatus>(value: PublishingStatus.draft, label: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('Draft')), icon: Icon(Icons.edit_note)),
                  ButtonSegment<PublishingStatus>(value: PublishingStatus.published, label: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('Diterbitkan')), icon: Icon(Icons.public)),
                ],
                selected: <PublishingStatus>{_status},
                onSelectionChanged: (Set<PublishingStatus> newSelection) {
                  setState(() {
                    _status = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  selectedBackgroundColor: Colors.green[700],
                  selectedForegroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator(color: Colors.green[700])
                  : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSaveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _isEditMode ? 'Simpan Perubahan' : 'Tambah Berita',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildImagePreview() {
    if (_imageUrlForPreview.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preview Gambar:', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter')),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              _imageUrlForPreview,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(height: 200, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator()));
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 40),
                        SizedBox(height: 8),
                        Text('Gagal memuat gambar dari URL', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
