import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/api_service.dart';
import '../widgets/story_card.dart';
import 'story_reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Story>> _storiesFuture;
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  void _loadStories() {
    setState(() {
      _storiesFuture = _apiService.fetchStories();
    });
  }

  Future<void> _handleRefresh() async {
    _loadStories();
    await _storiesFuture.catchError((_) => <Story>[]);
  }

  void _openStoryReader(Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryReaderScreen(story: story),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryTerracotta = Color(0xFFB83B00);
    const backgroundColor = Color(0xFFFBF9F5);
    const textColorDark = Color(0xFF1E1814);
    const textColorMuted = Color(0xFF736860);

    return Scaffold(
      backgroundColor: backgroundColor,

      // Top App Bar matching mockup 1
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: primaryTerracotta, size: 24),
          onPressed: () {},
        ),
        titleSpacing: 0,
        title: const Text(
          'StoryHub',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryTerracotta,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: textColorDark, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: primaryTerracotta, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          color: primaryTerracotta,
          backgroundColor: Colors.white,
          onRefresh: _handleRefresh,
          child: FutureBuilder<List<Story>>(
            future: _storiesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryTerracotta,
                  ),
                );
              }

              final stories = snapshot.data ?? ApiService.getDummyStories();
              final continueStories = stories.take(2).toList();
              final trendingStories = stories.skip(2).take(2).toList();
              final recommendationStories = stories.skip(4).take(4).toList();

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SECTION 1: Continue Reading ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Continue Reading',
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColorDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'VIEW ALL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryTerracotta,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Horizontal Scrollable Cards
                    SizedBox(
                      height: 310,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: continueStories.length,
                        itemBuilder: (context, index) {
                          final story = continueStories[index];
                          return StoryCard(
                            story: story,
                            cardType: StoryCardType.continueReading,
                            onTap: () => _openStoryReader(story),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- SECTION 2: Trending Stories ---
                    const Text(
                      'Trending Stories',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColorDark,
                      ),
                    ),
                    const SizedBox(height: 14),

                    ...trendingStories.asMap().entries.map((entry) {
                      final rank = entry.key + 1;
                      final story = entry.value;

                      return StoryCard(
                        story: story,
                        cardType: StoryCardType.trending,
                        trendingRank: rank,
                        onTap: () => _openStoryReader(story),
                      );
                    }),
                    const SizedBox(height: 28),

                    // --- SECTION 3: Recommendations for You ---
                    const Text(
                      'Recommendations for You',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColorDark,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2-Column Grid for Recommendations matching mockup 1
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: recommendationStories.length,
                      itemBuilder: (context, index) {
                        final story = recommendationStories[index];
                        return StoryCard(
                          story: story,
                          cardType: StoryCardType.recommendation,
                          onTap: () => _openStoryReader(story),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create a new Story')),
          );
        },
        backgroundColor: const Color(0xFFFF5722),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.edit_rounded, size: 24),
      ),

      // Bottom Navigation Bar matching mockup
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        selectedItemColor: primaryTerracotta,
        unselectedItemColor: textColorMuted,
        backgroundColor: const Color(0xFFFAF7F2),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_outlined),
            activeIcon: Icon(Icons.edit_note_rounded),
            label: 'Write',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined),
            activeIcon: Icon(Icons.auto_stories_rounded),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
