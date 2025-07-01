class Article {
  final String id;
  final String title;
  final String slug;
  final String summary;
  final String content;
  final String featuredImageUrl;
  final String? category;
  final List<String> tags;
  final String authorName;
  final String? authorBio;
  final String? authorAvatar;
  final DateTime publishedAt;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool? isPublished;

  Article({
    required this.id,
    required this.title,
    required this.slug,
    required this.summary,
    required this.content,
    required this.featuredImageUrl,
    this.category,
    this.tags = const [],
    required this.authorName,
    this.authorBio,
    this.authorAvatar,
    required this.publishedAt,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String? ?? '',
      featuredImageUrl: json['featured_image_url'] as String? ?? '',
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      authorName: json['author_name'] as String? ?? '',
      authorBio: json['author_bio'] as String?,
      authorAvatar: json['author_avatar'] as String?,
      publishedAt: DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
      viewCount: json['view_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isPublished: json['isPublished'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'featuredImageUrl': featuredImageUrl,
      'category': category ?? '',
      'tags': tags,
      'isPublished': isPublished ?? true,
    };
  }
}
