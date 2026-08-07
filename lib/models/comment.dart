import 'user.dart';

class Comment {
  final String id;
  final String storyId;
  final User? user;
  final String userId;
  final String userName;
  final String comment;
  final DateTime? createdAt;

  Comment({
    required this.id,
    required this.storyId,
    this.user,
    required this.userId,
    this.userName = 'Reader',
    required this.comment,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    User? userObj;
    String uId = '';
    String uName = 'Reader';

    if (json['userId'] is Map<String, dynamic>) {
      userObj = User.fromJson(json['userId'] as Map<String, dynamic>);
      uId = userObj.id;
      uName = userObj.username;
    } else if (json['userName'] != null) {
      uName = json['userName'] as String;
    } else if (json['userId'] is String) {
      uId = json['userId'] as String;
    }

    return Comment(
      id: (json['id'] ?? json['_id']) as String? ?? '',
      storyId: (json['storyId'] is Map
          ? (json['storyId']['_id'] ?? json['storyId']['id'])
          : json['storyId']) as String? ?? '',
      user: userObj,
      userId: uId,
      userName: uName,
      comment: json['comment'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyId': storyId,
      'userId': user?.toJson() ?? userId,
      'userName': userName,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
