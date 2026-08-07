import 'package:flutter/material.dart';
import '../models/story.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../widgets/book_cover.dart';

class StoryDetailScreen extends StatefulWidget {
  final Story story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late bool _isLiked;
  late int _likeCount;
  bool _isBookmarked = false;
  double _userStarRating = 4.8;
  bool _isPostingComment = false;

  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.story.likes;
    _isLiked = false;
    _userStarRating = widget.story.rating;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadComments() {
    setState(() {
      _commentsFuture = _apiService.fetchComments(widget.story.id);
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isLiked ? 'Added to liked stories! ❤️' : 'Unliked story'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Saved to your Bookmarks 🔖' : 'Removed from Bookmarks'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _handlePostComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPostingComment = true);

    await _apiService.postComment(
      storyId: widget.story.id,
      text: text,
    );

    _commentController.clear();
    setState(() => _isPostingComment = false);

    _loadComments();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment posted successfully!'),
        backgroundColor: Color(0xFFB83B00),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryTerracotta = Color(0xFFB83B00);
    const backgroundColor = Color(0xFFFBF9F5);
    const cardColor = Colors.white;
    const textColorDark = Color(0xFF1E1814);
    const textColorMuted = Color(0xFF736860);
    const borderColor = Color(0xFFEBE4DC);

    return Scaffold(
      backgroundColor: backgroundColor,

      // App Bar with Bookmark Toggle Icon
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColorDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.story.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Serif',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColorDark,
          ),
        ),
        actions: [
          // Bookmark Toggle Icon
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isBookmarked ? primaryTerracotta : textColorDark,
              size: 24,
            ),
            onPressed: _toggleBookmark,
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Story Details & Comments Body
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover Banner
                    BookCoverWidget(
                      title: widget.story.title,
                      author: widget.story.authorName,
                      category: widget.story.category,
                      height: 180,
                    ),
                    const SizedBox(height: 20),

                    // Category Tag & Read Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8ECE4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.story.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryTerracotta,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: textColorMuted),
                            const SizedBox(width: 4),
                            Text(
                              widget.story.readTime,
                              style: const TextStyle(fontSize: 12, color: textColorMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      widget.story.title,
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColorDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Author Name
                    Text(
                      'By ${widget.story.authorName}',
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: textColorMuted,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rating & Actions Row (Star Ratings + Like Button)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Star Ratings
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  final starValue = index + 1;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _userStarRating = starValue.toDouble();
                                      });
                                    },
                                    child: Icon(
                                      starValue <= _userStarRating.floor()
                                          ? Icons.star_rounded
                                          : (starValue - 0.5 <= _userStarRating
                                              ? Icons.star_half_rounded
                                              : Icons.star_outline_rounded),
                                      color: const Color(0xFFD69E2E),
                                      size: 20,
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_userStarRating.toStringAsFixed(1)} / 5.0',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: textColorDark,
                                ),
                              ),
                            ],
                          ),

                          // Like Button Toggle
                          InkWell(
                            onTap: _toggleLike,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _isLiked ? const Color(0xFFFDE8E8) : const Color(0xFFF5F0E9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                    color: _isLiked ? Colors.redAccent : textColorMuted,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$_likeCount',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: _isLiked ? Colors.redAccent : textColorDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Full Story Content
                    SelectableText(
                      widget.story.content,
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 15,
                        height: 1.8,
                        color: Color(0xFF2D241E),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(color: borderColor, thickness: 1),
                    const SizedBox(height: 20),

                    // --- SCROLLABLE COMMENTS SECTION ---
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments',
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColorDark,
                          ),
                        ),
                        Icon(Icons.chat_bubble_outline_rounded, size: 20, color: textColorMuted),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Comments List
                    FutureBuilder<List<Comment>>(
                      future: _commentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(color: primaryTerracotta),
                            ),
                          );
                        }

                        final comments = snapshot.data ?? [];

                        if (comments.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: const Text(
                              'No comments yet. Be the first to share your thoughts!',
                              style: TextStyle(fontSize: 13, color: textColorMuted),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final c = comments[index];
                            final initial = c.userName.isNotEmpty ? c.userName[0].toUpperCase() : 'U';

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: primaryTerracotta.withValues(alpha: 0.12),
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: primaryTerracotta,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              c.userName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: textColorDark,
                                              ),
                                            ),
                                            Text(
                                              'Just now',
                                              style: TextStyle(fontSize: 11, color: textColorMuted.withValues(alpha: 0.8)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          c.comment,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF332B25),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // --- INPUT FIELD TO POST A NEW COMMENT ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(fontSize: 14, color: textColorDark),
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFA0968E)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          filled: true,
                          fillColor: const Color(0xFFF6F2EC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _handlePostComment(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _isPostingComment ? null : _handlePostComment,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: primaryTerracotta,
                          shape: BoxShape.circle,
                        ),
                        child: _isPostingComment
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
