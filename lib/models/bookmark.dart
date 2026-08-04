import 'story.dart';

class Bookmark {
  final String id;
  final String userId;
  final Story? story;
  final String storyId;
  final DateTime? createdAt;

  Bookmark({
    required this.id,
    required this.userId,
    this.story,
    required this.storyId,
    this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    Story? storyObj;
    String sId = '';

    if (json['storyId'] is Map<String, dynamic>) {
      storyObj = Story.fromJson(json['storyId'] as Map<String, dynamic>);
      sId = storyObj.id;
    } else if (json['storyId'] is String) {
      sId = json['storyId'] as String;
    }

    return Bookmark(
      id: (json['id'] ?? json['_id']) as String? ?? '',
      userId: (json['userId'] is Map
          ? (json['userId']['_id'] ?? json['userId']['id'])
          : json['userId']) as String? ?? '',
      story: storyObj,
      storyId: sId,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'storyId': story?.toJson() ?? storyId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
