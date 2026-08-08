import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/api_service.dart';
import '../widgets/story_card.dart';
import 'story_detail_screen.dart';
import 'create_story_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();

  late Future<List<Story>> _likedStoriesFuture;
  late Future<List<Story>> _bookmarkedStoriesFuture;
  late Future<List<Story>> _myStoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _likedStoriesFuture = _apiService.fetchLikedStories();
      _bookmarkedStoriesFuture = _apiService.fetchBookmarkedStories();
      _myStoriesFuture = _apiService.fetchUserStories();
    });
  }

  void _openStoryDetail(Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryDetailScreen(story: story),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    const primaryTerracotta = Color(0xFFB83B00);
    const backgroundColor = Color(0xFFFBF9F5);
    const cardColor = Colors.white;
    const textColorDark = Color(0xFF1E1814);
    const textColorMuted = Color(0xFF736860);
    const borderColor = Color(0xFFEBE4DC);

    final username = ApiService.currentUser?.username ?? 'Januli';
    final email = ApiService.currentUser?.email ?? 'januli@gmail.com';
    final userInitial = username.isNotEmpty ? username[0].toUpperCase() : 'J';

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColorDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile & Library',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColorDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: textColorDark),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings opened')),
              );
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
                                child: Text(
                                  userInitial,
                                  style: const TextStyle(
                                    fontFamily: 'Serif',
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: primaryTerracotta,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: primaryTerracotta,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // User Display Name & Handle
                      Text(
                        username,
                        style: const TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColorDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${username.toLowerCase()} • $email',
                        style: const TextStyle(
                          fontSize: 13,
                          color: textColorMuted,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // User Bio
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Avid reader, aspiring fantasy author, and coffee lover ☕📖',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A4139),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- USER STATS ROW ---
                      Container(
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
                            _buildStatItem('Stories', '12'),
                            Container(width: 1, height: 28, color: borderColor),
                            _buildStatItem('Followers', '1.4k'),
                            Container(width: 1, height: 28, color: borderColor),
                            _buildStatItem('Likes Received', '3.8k'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ];
          },
          // --- MY LIBRARY TAB VIEW ---
          body: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                // TabBar
                Container(
                  color: backgroundColor,
                  child: const TabBar(
                    indicatorColor: primaryTerracotta,
                    indicatorWeight: 2.5,
                    labelColor: primaryTerracotta,
                    unselectedLabelColor: textColorMuted,
                    labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: TextStyle(fontSize: 13),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.favorite_rounded, size: 18),
                        text: 'Liked',
                      ),
                      Tab(
                        icon: Icon(Icons.bookmark_rounded, size: 18),
                        text: 'Bookmarks',
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
                      // 1. Liked Stories Tab
                      _buildStoryListTab(_likedStoriesFuture, 'No liked stories yet'),

                      // 2. Saved Bookmarks Tab
                      _buildStoryListTab(_bookmarkedStoriesFuture, 'No saved bookmarks yet'),

                      // 3. My Stories Tab
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

  Widget _buildStatItem(String label, String value) {
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

  Widget _buildStoryListTab(Future<List<Story>> storiesFuture, String emptyMessage) {
    return FutureBuilder<List<Story>>(
      future: storiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB83B00)),
          );
        }

        final stories = snapshot.data ?? [];

        if (stories.isEmpty) {
          return Center(
            child: Text(
              emptyMessage,
              style: const TextStyle(color: Color(0xFF736860), fontSize: 14),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildMyStoriesTab() {
    return FutureBuilder<List<Story>>(
      future: _myStoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB83B00)),
          );
        }

        final stories = snapshot.data ?? [];

        return Stack(
          children: [
            if (stories.isEmpty)
              Center(
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
              )
            else
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return StoryCard(
                    story: story,
                    cardType: StoryCardType.recommendation,
                    onTap: () => _openStoryDetail(story),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
