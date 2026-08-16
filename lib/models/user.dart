class User {
  final String id;
  final String username;
  final String email;
  final String profileImage;
  final String bio;
  final DateTime? createdAt;
  final int storiesCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImage = '',
    this.bio = '',
    this.createdAt,
    this.storiesCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? json['_id']) as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      storiesCount: (json['storiesCount'] is num) ? (json['storiesCount'] as num).toInt() : 0,
      followersCount: (json['followersCount'] is num) ? (json['followersCount'] as num).toInt() : 0,
      followingCount: (json['followingCount'] is num) ? (json['followingCount'] as num).toInt() : 0,
      isFollowing: json['isFollowing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImage': profileImage,
      'bio': bio,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
