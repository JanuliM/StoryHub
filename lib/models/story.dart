class Story {
  final String id;
  final String title;
  final String author;
  final String content;
  final String readTime;
  final String? coverImageUrl;

  Story({
    required this.id,
    required this.title,
    required this.author,
    required this.content,
    required this.readTime,
    this.coverImageUrl,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: (json['id'] ?? json['_id']) as String? ?? '',
      title: json['title'] as String? ?? '',
      author: (json['authorName'] ?? json['author'] ?? 'Anonymous') as String? ?? '',
      content: json['content'] as String? ?? '',
      readTime: json['readTime'] as String? ?? '5 min read',
      coverImageUrl: json['coverImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'content': content,
      'readTime': readTime,
      'coverImageUrl': coverImageUrl,
    };
  }
}
