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
  final int chapters;
  final String readsCount;
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
    this.likes = 120,
    this.rating = 4.8,
    this.chapters = 12,
    this.readsCount = '10k reads',
    this.coverUrl,
    this.createdAt,
  });

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
      likes: (json['likes'] is num) ? (json['likes'] as num).toInt() : 120,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.8,
      chapters: (json['chapters'] is num) ? (json['chapters'] as num).toInt() : 12,
      readsCount: json['reads'] != null 
          ? '${json['reads']} reads'
          : (json['readsCount'] as String? ?? '10k reads'),
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
      'chapters': chapters,
      'readsCount': readsCount,
      'coverUrl': coverUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
