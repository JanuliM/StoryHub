import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/api_service.dart';
import '../widgets/story_card.dart';
import 'story_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Story>> _bookmarkedStoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _bookmarkedStoriesFuture = _apiService.fetchBookmarkedStories();
    });
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryTerracotta = Color(0xFFB83B00);
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFBF9F5);
    final textColorDark = isDark ? Colors.white : const Color(0xFF1E1814);
    final textColorMuted = isDark ? Colors.white70 : const Color(0xFF736860);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'My Library',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColorDark,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryTerracotta,
          onRefresh: () async => _loadData(),
          child: FutureBuilder<List<Story>>(
            future: _bookmarkedStoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryTerracotta),
                );
              }

              final stories = snapshot.data ?? [];

              if (stories.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    const Center(child: Text('🔖', style: TextStyle(fontSize: 48))),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'No saved stories yet',
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColorDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Tap the bookmark icon on a story to save it here for later.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: textColorMuted),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return StoryCard(
                    story: story,
                    cardType: StoryCardType.trending,
                    onTap: () => _openStoryDetail(story),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
