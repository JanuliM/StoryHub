import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/story.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/story_card.dart';
import 'story_detail_screen.dart';
import 'follow_list_screen.dart';

class AuthorProfileScreen extends StatefulWidget {
  final String authorId;

  const AuthorProfileScreen({super.key, required this.authorId});

  @override
  State<AuthorProfileScreen> createState() => _AuthorProfileScreenState();
}

class _AuthorProfileScreenState extends State<AuthorProfileScreen> {
  final ApiService _apiService = ApiService();
  late Future<User?> _profileFuture;
  late Future<List<Story>> _storiesFuture;

  bool _isFollowing = false;
  bool _isTogglingFollow = false;

  bool get _isSelf => widget.authorId == ApiService.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _profileFuture = _apiService.fetchAuthorProfile(widget.authorId);
      _storiesFuture = _apiService.fetchUserStories(authorId: widget.authorId);
    });
    if (!_isSelf) {
      _apiService.checkFollowStatus(widget.authorId).then((status) {
        if (mounted) setState(() => _isFollowing = status);
      });
    }
  }

  Future<void> _toggleFollow() async {
    setState(() {
      _isFollowing = !_isFollowing;
      _isTogglingFollow = true;
    });

    final result = await _apiService.toggleFollow(widget.authorId);

    if (!mounted) return;
    setState(() => _isTogglingFollow = false);

    if (result['success'] != true) {
      // Revert on failure
      setState(() => _isFollowing = !_isFollowing);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update follow status'), backgroundColor: Colors.redAccent),
      );
    } else {
      _loadData();
    }
  }

  Future<void> _openStoryDetail(Story story) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoryDetailScreen(story: story)),
    );
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
          'Author',
          style: TextStyle(fontFamily: 'Serif', fontSize: 20, fontWeight: FontWeight.bold, color: textColorDark),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<User?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primaryTerracotta));
            }

            final author = snapshot.data;
            if (author == null) {
              return Center(
                child: Text('Could not load this profile', style: TextStyle(color: textColorMuted)),
              );
            }

            final initial = author.username.isNotEmpty ? author.username[0].toUpperCase() : 'U';

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryTerracotta, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: primaryTerracotta.withValues(alpha: 0.12),
                      backgroundImage: author.profileImage.isNotEmpty ? MemoryImage(base64Decode(author.profileImage)) : null,
                      child: author.profileImage.isEmpty
                          ? Text(initial, style: const TextStyle(fontFamily: 'Serif', fontSize: 36, fontWeight: FontWeight.bold, color: primaryTerracotta))
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    author.username,
                    style: TextStyle(fontFamily: 'Serif', fontSize: 22, fontWeight: FontWeight.bold, color: textColorDark),
                  ),
                ),
                if (author.bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      author.bio,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: textColorMuted, height: 1.4),
                    ),
                  ),
                ],
                const SizedBox(height: 18),

                if (!_isSelf)
                  Center(
                    child: SizedBox(
                      width: 160,
                      child: _isFollowing
                          ? OutlinedButton.icon(
                              onPressed: _isTogglingFollow ? null : _toggleFollow,
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Following'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryTerracotta,
                                side: const BorderSide(color: primaryTerracotta),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: _isTogglingFollow ? null : _toggleFollow,
                              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                              label: const Text('Follow'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryTerracotta,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                    ),
                  ),
                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Stories', '${author.storiesCount}', null),
                      Container(width: 1, height: 28, color: borderColor),
                      _buildStatItem(
                        'Followers',
                        '${author.followersCount}',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FollowListScreen(userId: author.id, isFollowers: true)),
                        ),
                      ),
                      Container(width: 1, height: 28, color: borderColor),
                      _buildStatItem(
                        'Following',
                        '${author.followingCount}',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FollowListScreen(userId: author.id, isFollowers: false)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Stories',
                  style: TextStyle(fontFamily: 'Serif', fontSize: 18, fontWeight: FontWeight.bold, color: textColorDark),
                ),
                const SizedBox(height: 12),

                FutureBuilder<List<Story>>(
                  future: _storiesFuture,
                  builder: (context, storySnapshot) {
                    if (storySnapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(color: primaryTerracotta)),
                      );
                    }

                    final stories = storySnapshot.data ?? [];
                    if (stories.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text('No published stories yet', style: TextStyle(color: textColorMuted, fontSize: 13)),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: stories.length,
                      itemBuilder: (context, index) {
                        final story = stories[index];
                        return StoryCard(
                          story: story,
                          cardType: StoryCardType.recommendation,
                          onTap: () => _openStoryDetail(story),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, VoidCallback? onTap) {
    final content = Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontFamily: 'Serif', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFB83B00)),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF736860), fontWeight: FontWeight.w500),
        ),
      ],
    );

    if (onTap == null) return content;
    return InkWell(borderRadius: BorderRadius.circular(8), onTap: onTap, child: Padding(padding: const EdgeInsets.all(4.0), child: content));
  }
}
