import 'package:flutter/material.dart';
import '../models/story.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../widgets/book_cover.dart';
import 'author_profile_screen.dart';

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
  bool _bookmarkChanged = false;
  bool _isPostingComment = false;
  bool _isFollowingAuthor = false;
  bool _isTogglingFollow = false;

  late Future<List<Comment>> _commentsFuture;

  String? get _authorId => widget.story.author?.id.isNotEmpty == true ? widget.story.author!.id : null;

  bool get _isViewingOwnStory => _authorId != null && _authorId == ApiService.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.story.likes;
    _isLiked = false;
    _loadComments();
    _incrementReads();
    _checkIfBookmarked();
    _checkIfFollowingAuthor();
  }

  void _checkIfFollowingAuthor() async {
    final authorId = _authorId;
    if (authorId == null || _isViewingOwnStory) return;
    final status = await _apiService.checkFollowStatus(authorId);
    if (mounted) {
      setState(() {
        _isFollowingAuthor = status;
      });
    }
  }

  Future<void> _toggleFollowAuthor() async {
    final authorId = _authorId;
    if (authorId == null) return;

    setState(() {
      _isFollowingAuthor = !_isFollowingAuthor;
      _isTogglingFollow = true;
    });

    final result = await _apiService.toggleFollow(authorId);

    if (!mounted) return;
    setState(() => _isTogglingFollow = false);

    if (result['success'] != true) {
      setState(() => _isFollowingAuthor = !_isFollowingAuthor);
    }
  }

  void _openAuthorProfile() {
    final authorId = _authorId;
    if (authorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Author profile unavailable for this story')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AuthorProfileScreen(authorId: authorId)),
    );
  }

  void _checkIfBookmarked() async {
    final status = await _apiService.checkBookmarkStatus(widget.story.id);
    if (mounted) {
      setState(() {
        _isBookmarked = status;
      });
    }
  }

  void _incrementReads() {
    _apiService.incrementStoryReads(widget.story.id);
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

  void _toggleBookmark() async {
    final previousState = _isBookmarked;
    setState(() {
      _isBookmarked = !_isBookmarked;
      _bookmarkChanged = true;
    });

    final result = await _apiService.toggleBookmark(widget.story.id);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'Saved to your Bookmarks 🔖' : 'Removed from Bookmarks'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      setState(() => _isBookmarked = previousState);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update bookmark. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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

  // --- DELETE COMMENT HANDLER ---
  Future<void> _confirmDeleteComment(Comment comment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFBF9F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Comment',
          style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF736860))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _apiService.deleteComment(commentId: comment.id, storyId: widget.story.id);
      _loadComments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted')),
      );
    }
  }

  // --- DELETE STORY HANDLER ---
  Future<void> _confirmDeleteStory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFBF9F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Story',
          style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to delete "${widget.story.title}"? This action cannot be undone.'),
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
      final result = await _apiService.deleteStory(widget.story.id);
      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story deleted successfully')),
        );
        Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryTerracotta = Color(0xFFB83B00);
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFBF9F5);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColorDark = isDark ? Colors.white : const Color(0xFF1E1814);
    final textColorMuted = isDark ? Colors.white70 : const Color(0xFF736860);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFEBE4DC);

    final currentUsername = ApiService.currentUser?.username ?? 'Januli';
    final isStoryAuthor = widget.story.authorName.toLowerCase() == currentUsername.toLowerCase() ||
        widget.story.authorName == 'Januli' ||
        widget.story.id.startsWith('my_') ||
        widget.story.id.startsWith('created_');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pop(context, _bookmarkChanged);
      },
      child: Scaffold(
        backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColorDark),
          onPressed: () => Navigator.pop(context, _bookmarkChanged),
        ),
        title: Text(
          widget.story.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
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
          // Delete Story Button (if Author)
          if (isStoryAuthor)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
              tooltip: 'Delete Story',
              onPressed: _confirmDeleteStory,
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
                            Icon(Icons.access_time_rounded, size: 14, color: textColorMuted),
                            const SizedBox(width: 4),
                            Text(
                              widget.story.readTime,
                              style: TextStyle(fontSize: 12, color: textColorMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      widget.story.title,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColorDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Author Name & Follow Button
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _openAuthorProfile,
                            child: Text(
                              'By ${widget.story.authorName}',
                              style: TextStyle(
                                fontFamily: 'Serif',
                                fontStyle: FontStyle.italic,
                                fontSize: 15,
                                color: _authorId != null ? primaryTerracotta : textColorMuted,
                                decoration: _authorId != null ? TextDecoration.underline : TextDecoration.none,
                                decorationColor: primaryTerracotta,
                              ),
                            ),
                          ),
                        ),
                        if (_authorId != null && !_isViewingOwnStory)
                          GestureDetector(
                            onTap: _isTogglingFollow ? null : _toggleFollowAuthor,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _isFollowingAuthor ? Colors.transparent : primaryTerracotta,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: primaryTerracotta),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isFollowingAuthor ? Icons.check_rounded : Icons.add_rounded,
                                    size: 14,
                                    color: _isFollowingAuthor ? primaryTerracotta : Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isFollowingAuthor ? 'Following' : 'Follow',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _isFollowingAuthor ? primaryTerracotta : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Actions Row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                    Divider(color: borderColor, thickness: 1),
                    const SizedBox(height: 20),

                    // --- SCROLLABLE COMMENTS SECTION ---
                    Row(
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
                            child: Text(
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
                            final isCommentAuthor = c.userName.toLowerCase() == currentUsername.toLowerCase() ||
                                c.userName == 'Januli' ||
                                c.id.startsWith('c_');

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
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: textColorDark,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Just now',
                                                  style: TextStyle(fontSize: 11, color: textColorMuted.withValues(alpha: 0.8)),
                                                ),
                                                if (isCommentAuthor) ...[
                                                  const SizedBox(width: 6),
                                                  GestureDetector(
                                                    onTap: () => _confirmDeleteComment(c),
                                                    child: const Icon(
                                                      Icons.delete_outline_rounded,
                                                      size: 16,
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                                ],
                                              ],
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
                        style: TextStyle(fontSize: 14, color: textColorDark),
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
      ),
    );
  }
}

