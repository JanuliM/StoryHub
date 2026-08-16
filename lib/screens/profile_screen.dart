import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../models/story.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/story_card.dart';
import 'story_detail_screen.dart';
import 'create_story_screen.dart';
import 'edit_profile_screen.dart';
import 'follow_list_screen.dart';
import 'author_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();

  late Future<List<User>> _followersFuture;
  late Future<List<Story>> _myStoriesFuture;
  late Future<User?> _profileStatsFuture;

  int _storyCount = 0;
  String _selectedStoryCategory = 'All';

  final List<String> _storyCategories = const [
    'All',
    'Fantasy',
    'Romance',
    'Horror',
    'Mystery',
    'Adventure',
    'Sci-Fi',
    'Comedy',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      final userId = ApiService.currentUser?.id;
      _followersFuture = userId != null ? _apiService.fetchFollowers(userId) : Future.value(<User>[]);
      _myStoriesFuture = _apiService.fetchUserStories().then((stories) {
        if (mounted) {
          setState(() => _storyCount = stories.length);
        }
        return stories;
      });
      _profileStatsFuture = userId != null ? _apiService.fetchAuthorProfile(userId) : Future.value(null);
    });
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _openStoryDetail(Story story) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryDetailScreen(story: story),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _openCreateStory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateStoryScreen(),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _confirmDeleteStory(Story story) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFBF9F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Story',
          style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to delete "${story.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF736860))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete Story', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _apiService.deleteStory(story.id);
      if (!mounted) return;

      if (result['success'] == true) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete story'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    
    if (pickedFile != null) {
      setState(() {
        // Show loading state if needed, here we just eagerly upload
      });
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      
      final success = await _apiService.uploadProfileImage(base64String);
      if (success && mounted) {
        setState(() {}); // Refresh UI with new image
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated'), backgroundColor: Color(0xFFB83B00)),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update picture'), backgroundColor: Colors.redAccent),
        );
      }
    }
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

    final username = ApiService.currentUser?.username ?? 'Januli';
    final email = ApiService.currentUser?.email ?? 'januli@gmail.com';
    final userInitial = username.isNotEmpty ? username[0].toUpperCase() : 'J';
    final profileImageBase64 = ApiService.currentUser?.profileImage ?? '';

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
          'Profile',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColorDark,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textColorDark),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings opened')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () async {
              await ApiService().logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                  child: Column(
                    children: [
                      // --- USER AVATAR & HEADER ---
                      Center(
                        child: GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryTerracotta, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 42,
                                  backgroundColor: primaryTerracotta.withValues(alpha: 0.12),
                                  backgroundImage: profileImageBase64.isNotEmpty
                                      ? MemoryImage(base64Decode(profileImageBase64))
                                      : null,
                                  child: profileImageBase64.isEmpty
                                      ? Text(
                                          userInitial,
                                          style: const TextStyle(
                                            fontFamily: 'Serif',
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: primaryTerracotta,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: primaryTerracotta,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // User Display Name & Handle
                      Text(
                        username,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColorDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${username.toLowerCase()} • $email',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColorMuted,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // User Bio
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          (ApiService.currentUser?.bio.isNotEmpty ?? false)
                              ? ApiService.currentUser!.bio
                              : 'No bio yet — tap Edit Profile to add one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: textColorMuted,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- USER STATS ROW ---
                      FutureBuilder<User?>(
                        future: _profileStatsFuture,
                        builder: (context, statsSnapshot) {
                          final stats = statsSnapshot.data;
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('Stories', '$_storyCount', null),
                                Container(width: 1, height: 28, color: borderColor),
                                _buildStatItem(
                                  'Followers',
                                  '${stats?.followersCount ?? 0}',
                                  stats != null
                                      ? () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => FollowListScreen(userId: stats.id, isFollowers: true),
                                            ),
                                          )
                                      : null,
                                ),
                                Container(width: 1, height: 28, color: borderColor),
                                _buildStatItem(
                                  'Following',
                                  '${stats?.followingCount ?? 0}',
                                  stats != null
                                      ? () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => FollowListScreen(userId: stats.id, isFollowers: false),
                                            ),
                                          )
                                      : null,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      OutlinedButton.icon(
                        onPressed: _openEditProfile,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit Profile'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryTerracotta,
                          side: const BorderSide(color: primaryTerracotta),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ];
          },
          // --- PROFILE TAB VIEW ---
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // TabBar
                Container(
                  color: backgroundColor,
                  child: TabBar(
                    indicatorColor: primaryTerracotta,
                    indicatorWeight: 2.5,
                    labelColor: primaryTerracotta,
                    unselectedLabelColor: textColorMuted,
                    labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: TextStyle(fontSize: 13),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.people_alt_rounded, size: 18),
                        text: 'Followers',
                      ),
                      Tab(
                        icon: Icon(Icons.auto_stories_rounded, size: 18),
                        text: 'My Stories',
                      ),
                    ],
                  ),
                ),

                // TabBarView Content
                Expanded(
                  child: TabBarView(
                    children: [
                      // 1. Followers Tab
                      _buildFollowersTab(),

                      // 2. My Stories Tab (grouped by category)
                      _buildMyStoriesTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, VoidCallback? onTap) {
    final content = _statColumn(label, value);
    if (onTap == null) return content;
    return InkWell(borderRadius: BorderRadius.circular(8), onTap: onTap, child: Padding(padding: const EdgeInsets.all(4.0), child: content));
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFB83B00),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF736860),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFollowersTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryTerracotta = Color(0xFFB83B00);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColorDark = isDark ? Colors.white : const Color(0xFF1E1814);
    final textColorMuted = isDark ? Colors.white70 : const Color(0xFF736860);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFEBE4DC);

    return FutureBuilder<List<User>>(
      future: _followersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB83B00)),
          );
        }

        final followers = snapshot.data ?? [];

        if (followers.isEmpty) {
          return Center(
            child: Text(
              'No followers yet',
              style: const TextStyle(color: Color(0xFF736860), fontSize: 14),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: followers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final follower = followers[index];
            final initial = follower.username.isNotEmpty ? follower.username[0].toUpperCase() : 'U';

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthorProfileScreen(authorId: follower.id)),
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
                      backgroundImage: follower.profileImage.isNotEmpty ? MemoryImage(base64Decode(follower.profileImage)) : null,
                      child: follower.profileImage.isEmpty
                          ? Text(initial, style: const TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold, color: primaryTerracotta))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(follower.username, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColorDark)),
                          if (follower.bio.isNotEmpty)
                            Text(
                              follower.bio,
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
    );
  }

  Widget _buildMyStoriesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryTerracotta = Color(0xFFB83B00);
    final textColorDark = isDark ? Colors.white : const Color(0xFF1E1814);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFEBE4DC);

    return FutureBuilder<List<Story>>(
      future: _myStoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB83B00)),
          );
        }

        final stories = snapshot.data ?? [];

        if (stories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✍️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                const Text(
                  'You haven\'t published any stories yet',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1814),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _openCreateStory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB83B00),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Write Your First Story'),
                ),
              ],
            ),
          );
        }

        final filteredStories = _selectedStoryCategory == 'All'
            ? stories
            : stories.where((s) => s.category.toLowerCase() == _selectedStoryCategory.toLowerCase()).toList();

        return Column(
          children: [
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _storyCategories.length,
                itemBuilder: (context, index) {
                  final category = _storyCategories[index];
                  final isSelected = _selectedStoryCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: primaryTerracotta,
                      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      side: BorderSide(color: isSelected ? primaryTerracotta : borderColor),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : textColorDark,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedStoryCategory = category);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredStories.length,
                itemBuilder: (context, index) {
                  final story = filteredStories[index];
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      StoryCard(
                        story: story,
                        cardType: StoryCardType.trending,
                        onTap: () => _openStoryDetail(story),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          tooltip: 'Delete Story',
                          onPressed: () => _confirmDeleteStory(story),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
