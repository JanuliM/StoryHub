import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/api_service.dart';
import 'author_profile_screen.dart';

class FollowListScreen extends StatefulWidget {
  final String userId;
  final bool isFollowers;

  const FollowListScreen({super.key, required this.userId, required this.isFollowers});

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = widget.isFollowers
        ? _apiService.fetchFollowers(widget.userId)
        : _apiService.fetchFollowing(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryTerracotta = Color(0xFFB83B00);
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFBF9F5);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColorDark = isDark ? Colors.white : const Color(0xFF1E1814);
    final textColorMuted = isDark ? Colors.white70 : const Color(0xFF736860);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFEBE4DC);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColorDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isFollowers ? 'Followers' : 'Following',
          style: TextStyle(fontFamily: 'Serif', fontSize: 20, fontWeight: FontWeight.bold, color: textColorDark),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<User>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primaryTerracotta));
            }

            final users = snapshot.data ?? [];

            if (users.isEmpty) {
              return Center(
                child: Text(
                  widget.isFollowers ? 'No followers yet' : 'Not following anyone yet',
                  style: TextStyle(color: textColorMuted, fontSize: 14),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final user = users[index];
                final initial = user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U';

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthorProfileScreen(authorId: user.id)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: primaryTerracotta.withValues(alpha: 0.12),
                          backgroundImage: user.profileImage.isNotEmpty ? MemoryImage(base64Decode(user.profileImage)) : null,
                          child: user.profileImage.isEmpty
                              ? Text(initial, style: const TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold, color: primaryTerracotta))
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.username, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColorDark)),
                              if (user.bio.isNotEmpty)
                                Text(
                                  user.bio,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: textColorMuted),
                                ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: textColorMuted),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
