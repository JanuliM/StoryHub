import 'user.dart';
class Story {
  final String id;
  final String title;
  final String category;
  final String content;
  final User? author;
  final String authorName;
  final String readTime;
  final int likes;
  final double rating;
  final String readsCount;
  final int reads;
  final String? coverUrl;
  final DateTime? createdAt;
  Story({
    required this.id,
    required this.title,
    this.category = 'Fantasy',
    required this.content,
    this.author,
    required this.authorName,
    this.readTime = '5 min read',
    this.likes = 0,
    this.rating = 4.8,
    this.readsCount = '0 reads',
    this.reads = 0,
    this.coverUrl,
    this.createdAt,
  });
  // Wattpad-style reader count, formatted from the real `reads` value.
  String get displayReads {
    if (reads <= 0) return readsCount;
    if (reads >= 1000000) return '${(reads / 1000000).toStringAsFixed(1)}M reads';
    if (reads >= 1000) return '${(reads / 1000).toStringAsFixed(1)}k reads';
    return '$reads reads';
  }
  factory Story.fromJson(Map<String, dynamic> json) {
    User? authorObj;
    String name = 'Anonymous';
    if (json['author'] is Map<String, dynamic>) {
      authorObj = User.fromJson(json['author'] as Map<String, dynamic>);
      name = authorObj.username;
    } else if (json['authorName'] != null) {
      name = json['authorName'] as String;
    } else if (json['author'] is String) {
      name = json['author'] as String;
    }
    return Story(
      id: (json['id'] ?? json['_id']) as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Fantasy',
      content: json['content'] as String? ?? '',
      author: authorObj,
      authorName: name,
      readTime: json['readTime'] as String? ?? '5 min read',
      likes: (json['likes'] is num) ? (json['likes'] as num).toInt() : 0,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.8,
      readsCount: json['reads'] != null
          ? '${json['reads']} reads'
          : (json['readsCount'] as String? ?? '0 reads'),
      reads: (json['reads'] is num) ? (json['reads'] as num).toInt() : 0,
      coverUrl: json['coverUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content,
      'author': author?.toJson(),
      'authorName': authorName,
      'readTime': readTime,
      'likes': likes,
      'rating': rating,
      'readsCount': readsCount,
      'coverUrl': coverUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
