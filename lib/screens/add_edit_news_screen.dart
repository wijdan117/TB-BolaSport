// lib/screens/add_edit_news_screen.dart

import 'package:flutter/material.dart';
import 'package:tb_project/models/news_model.dart';
import 'package:tb_project/services/news_service.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class AddEditNewsScreen extends StatefulWidget {
  final NewsArticle? article; // Null jika menambah, ada jika mengedit

  const AddEditNewsScreen({super.key, this.article});

  @override
  State<AddEditNewsScreen> createState() => _AddEditNewsScreenState();
}

class _AddEditNewsScreenState extends State<AddEditNewsScreen> {
  final _formKey = GlobalKey<FormState>(); // Untuk validasi form
  final NewsService _newsService = NewsService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _snippetController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _publishedAtController = TextEditingController();

  DateTime? _selectedPublishedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      // Jika mode edit, isi controller dengan data berita yang ada
      _titleController.text = widget.article!.title;
      _imageUrlController.text = widget.article!.imageUrl ?? '';
      _snippetController.text = widget.article!.snippet ?? '';
      _contentController.text = widget.article!.content ?? '';
      _sourceController.text = widget.article!.source ?? '';
      _selectedPublishedDate = widget.article!.publishedAt;
      _publishedAtController.text = _selectedPublishedDate != null
          ? DateFormat('dd MMMM yyyy HH:mm').format(_selectedPublishedDate!)
          : '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _snippetController.dispose();
    _contentController.dispose();
    _sourceController.dispose();
    _publishedAtController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPublishedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedPublishedDate) {
      setState(() {
        _selectedPublishedDate = picked;
        _publishedAtController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
      _selectTime(context); // Lanjutkan untuk memilih waktu
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedPublishedDate ?? DateTime.now()),
    );
    if (picked != null) {
      setState(() {
        _selectedPublishedDate = DateTime(
          _selectedPublishedDate!.year,
          _selectedPublishedDate!.month,
          _selectedPublishedDate!.day,
          picked.hour,
          picked.minute,
        );
        _publishedAtController.text = DateFormat('dd MMMM yyyy HH:mm').format(_selectedPublishedDate!);
      });
    }
  }


  Future<void> _saveNews() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newArticle = NewsArticle(
        id: widget.article?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), // Gunakan ID lama atau generate baru
        title: _titleController.text,
        imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
        snippet: _snippetController.text.isEmpty ? null : _snippetController.text,
        content: _contentController.text.isEmpty ? null : _contentController.text,
        source: _sourceController.text.isEmpty ? null : _sourceController.text,
        publishedAt: _selectedPublishedDate,
      );

      try {
        if (widget.article == null) {
          // Tambah berita baru
          await _newsService.addNewsArticle(newArticle);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berita berhasil ditambahkan.'), backgroundColor: Colors.green),
          );
        } else {
          // Edit berita yang sudah ada
          await _newsService.updateNewsArticle(newArticle);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berita berhasil diperbarui.'), backgroundColor: Colors.green),
          );
        }
        Navigator.pop(context); // Kembali ke AdminHomeScreen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan berita: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
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
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Judul Berita', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul berita tidak boleh kosong.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL Gambar (Opsional)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _snippetController,
                  decoration: const InputDecoration(labelText: 'Cuplikan Berita (Opsional)', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Konten Berita', border: OutlineInputBorder()),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konten berita tidak boleh kosong.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sourceController,
                  decoration: const InputDecoration(labelText: 'Sumber Berita (Opsional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _publishedAtController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Publikasi (Opsional)',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  readOnly: true, // Tidak bisa diketik langsung
                  onTap: () => _selectDate(context), // Membuka date picker saat diklik
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? CircularProgressIndicator(color: Colors.green[700])
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveNews,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            widget.article == null ? 'Tambah Berita' : 'Simpan Perubahan',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
