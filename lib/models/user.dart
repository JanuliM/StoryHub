class User {
  final String id;
  final String username;
  final String email;
  final String profileImage;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImage = '',
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? json['_id']) as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
