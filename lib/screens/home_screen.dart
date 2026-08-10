import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/api_service.dart';
import '../widgets/story_card.dart';
import 'story_detail_screen.dart';
import 'create_story_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  late Future<List<Story>> _storiesFuture;
  int _currentBottomNavIndex = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Fantasy',
    'Romance',
    'Horror',
    'Mystery',
    'Adventure',
    'Science Fiction',
    'Comedy',
  ];

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      _loadStories();
    }
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  List<Story> _filterStories(List<Story> stories) {
    return stories.where((story) {
      // Category filter matching
      bool categoryMatch = true;
      if (_selectedCategory != 'All') {
        final catClean = _selectedCategory.toLowerCase();
        final storyCatClean = story.category.toLowerCase();
        if (catClean == 'science fiction' || catClean == 'sci-fi') {
          categoryMatch = storyCatClean.contains('sci');
        } else {
          categoryMatch = storyCatClean.contains(catClean);
        }
      }

      // Search query matching
      bool queryMatch = true;
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        queryMatch = story.title.toLowerCase().contains(q) ||
            story.authorName.toLowerCase().contains(q) ||
            story.category.toLowerCase().contains(q) ||
            story.content.toLowerCase().contains(q);
      }

      return categoryMatch && queryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const primaryTerracotta = Color(0xFFB83B00);
    const backgroundColor = Color(0xFFFBF9F5);
    const textColorDark = Color(0xFF1E1814);
    const textColorMuted = Color(0xFF736860);
    const borderColor = Color(0xFFEBE4DC);

    return Scaffold(
      backgroundColor: backgroundColor,

      // Top App Bar
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
            icon: const Icon(Icons.notifications_none_outlined, color: primaryTerracotta, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: textColorDark, size: 24),
            onPressed: _openProfile,
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

              final allStories = snapshot.data ?? ApiService.getDummyStories();
              final filteredStories = _filterStories(allStories);
              final isFilteringActive = _selectedCategory != 'All' || _searchQuery.isNotEmpty;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. SEARCH BAR COMPONENT ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: textColorMuted, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(fontSize: 14, color: textColorDark),
                              decoration: const InputDecoration(
                                hintText: 'Search stories by title, author, or keyword...',
                                hintStyle: TextStyle(fontSize: 13, color: Color(0xFFA0968E)),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: const Icon(Icons.close, color: textColorMuted, size: 18),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // --- 2. HORIZONTAL CATEGORY SELECTOR BAR ---
                    SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategory == category;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              selectedColor: primaryTerracotta,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSelected ? primaryTerracotta : borderColor,
                                width: 1,
                              ),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : textColorDark,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- IF FILTERING IS ACTIVE (SEARCH OR CATEGORY SELECTED) ---
                    if (isFilteringActive) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Results (${filteredStories.length})',
                            style: const TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColorDark,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _selectedCategory = 'All';
                                _searchQuery = '';
                              });
                            },
                            child: const Text(
                              'Clear Filters',
                              style: TextStyle(fontSize: 12, color: primaryTerracotta, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (filteredStories.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                          alignment: Alignment.center,
                          child: const Column(
                            children: [
                              Text('📖', style: TextStyle(fontSize: 48)),
                              SizedBox(height: 12),
                              Text(
                                'No stories found',
                                style: TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColorDark,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Try adjusting your search terms or category filter.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: textColorMuted),
                              ),
                            ],
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredStories.length,
                          itemBuilder: (context, index) {
                            final story = filteredStories[index];
                            return StoryCard(
                              story: story,
                              cardType: StoryCardType.recommendation,
                              onTap: () => _openStoryReader(story),
                            );
                          },
                        ),
                    ] else ...[
                      // --- DEFAULT MOCKUP LAYOUT (WHEN NO FILTER ACTIVE) ---

                      // Continue Reading
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
                      SizedBox(
                        height: 310,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: allStories.take(2).length,
                          itemBuilder: (context, index) {
                            final story = allStories[index];
                            return StoryCard(
                              story: story,
                              cardType: StoryCardType.continueReading,
                              onTap: () => _openStoryReader(story),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Trending Stories
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
                      ...allStories.skip(2).take(2).toList().asMap().entries.map((entry) {
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

                      // Recommendations for You
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

                      Builder(
                        builder: (context) {
                          final recStories = allStories.length > 4 ? allStories.skip(4).toList() : allStories;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: recStories.length,
                            itemBuilder: (context, index) {
                              final story = recStories[index];
                              return StoryCard(
                                story: story,
                                cardType: StoryCardType.recommendation,
                                onTap: () => _openStoryReader(story),
                              );
                            },
                          );
                        },
                      ),
                    ],
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
        onPressed: _openCreateStory,
        backgroundColor: const Color(0xFFFF5722),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.edit_rounded, size: 24),
      ),

      // Bottom Navigation Bar
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
          if (index == 2) {
            _openCreateStory();
          } else if (index == 3) {
            _openProfile();
          } else {
            setState(() => _currentBottomNavIndex = index);
          }
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
