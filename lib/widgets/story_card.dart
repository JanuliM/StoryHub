import 'package:flutter/material.dart';
import '../models/story.dart';

class BookCoverWidget extends StatelessWidget {
  final String title;
  final String author;
  final String category;
  final String? coverUrl;
  final double height;
  final double width;

  const BookCoverWidget({
    super.key,
    required this.title,
    required this.author,
    required this.category,
    this.coverUrl,
    this.height = 160,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height.isInfinite ? null : height;
    final effectiveWidth = width.isInfinite ? null : width;

    if (coverUrl != null && coverUrl!.trim().isNotEmpty) {
      return Container(
        height: effectiveHeight,
        width: effectiveWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            coverUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildIllustrationCover(),
          ),
        ),
      );
    }

    return _buildIllustrationCover();
  }

  Widget _buildIllustrationCover() {
    Color bgStart;
    Color bgEnd;
    IconData centerIcon;
    Color accentColor;

    final catUpper = category.toUpperCase();

    if (catUpper.contains('MYSTERY')) {
      bgStart = const Color(0xFFF7F1E5);
      bgEnd = const Color(0xFFEBE0CE);
      centerIcon = Icons.landscape_rounded;
      accentColor = const Color(0xFFC05A2B);
    } else if (catUpper.contains('SCI') || catUpper.contains('SCIENCE')) {
      bgStart = const Color(0xFFEBF3F5);
      bgEnd = const Color(0xFFD6E6EB);
      centerIcon = Icons.blur_on_rounded;
      accentColor = const Color(0xFF2C7A7B);
    } else if (catUpper.contains('LITERARY')) {
      bgStart = const Color(0xFFF2F4F8);
      bgEnd = const Color(0xFFE2E7F0);
      centerIcon = Icons.filter_hdr_rounded;
      accentColor = const Color(0xFF4A5568);
    } else if (catUpper.contains('ROMANCE')) {
      bgStart = const Color(0xFFFAF3F0);
      bgEnd = const Color(0xFFF0E4DF);
      centerIcon = Icons.local_florist_rounded;
      accentColor = const Color(0xFFDD6B20);
    } else if (catUpper.contains('FANTASY')) {
      bgStart = const Color(0xFF1A202C);
      bgEnd = const Color(0xFF2D3748);
      centerIcon = Icons.local_fire_department_rounded;
      accentColor = const Color(0xFFD69E2E);
    } else if (catUpper.contains('THRILLER') || catUpper.contains('HORROR')) {
      bgStart = const Color(0xFF2D3748);
      bgEnd = const Color(0xFF1A202C);
      centerIcon = Icons.vpn_key_rounded;
      accentColor = const Color(0xFFE53E3E);
    } else if (catUpper.contains('ADVENTURE')) {
      bgStart = const Color(0xFFF0FDF4);
      bgEnd = const Color(0xFFDCFCE7);
      centerIcon = Icons.explore_rounded;
      accentColor = const Color(0xFF15803D);
    } else if (catUpper.contains('COMEDY')) {
      bgStart = const Color(0xFFFEF9C3);
      bgEnd = const Color(0xFFFEF08A);
      centerIcon = Icons.sentiment_very_satisfied_rounded;
      accentColor = const Color(0xFFA16207);
    } else if (catUpper.contains('DRAMA')) {
      bgStart = const Color(0xFFFFFAF0);
      bgEnd = const Color(0xFFFEEBC8);
      centerIcon = Icons.coffee_rounded;
      accentColor = const Color(0xFFC05A2B);
    } else {
      bgStart = const Color(0xFFF7F1E5);
      bgEnd = const Color(0xFFEBE0CE);
      centerIcon = Icons.menu_book_rounded;
      accentColor = const Color(0xFFB83B00);
    }

    final isDark = catUpper.contains('FANTASY') || catUpper.contains('THRILLER') || catUpper.contains('HORROR');
    final textColor = isDark ? Colors.white : const Color(0xFF2D241E);
    final subtextColor = isDark ? Colors.grey[400] : const Color(0xFF736860);

    return Container(
      height: height.isInfinite ? null : height,
      width: width.isInfinite ? null : width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgStart, bgEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : const Color(0xFFE5DFD5),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(height > 120 ? 12.0 : 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  centerIcon,
                  size: height > 120 ? 38 : (height > 80 ? 26 : 18),
                  color: accentColor,
                ),
                SizedBox(height: height > 120 ? 8 : 4),
                Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: height > 80 ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: height > 120 ? 12 : 9,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                if (height > 100) ...[
                  const SizedBox(height: 4),
                  Text(
                    'By $author',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontStyle: FontStyle.italic,
                      fontSize: 10,
                      color: subtextColor,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum StoryCardType { continueReading, trending, recommendation }

class StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback? onTap;
  final StoryCardType cardType;
  final int? trendingRank;

  const StoryCard({
    super.key,
    required this.story,
    this.onTap,
    this.cardType = StoryCardType.recommendation,
    this.trendingRank,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryTerracotta = Color(0xFFB83B00);
    final textColorDark = isDark ? Colors.white : const Color(0xFF1E1814);
    final textColorMuted = isDark ? Colors.white70 : const Color(0xFF736860);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFEBE4DC);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // 1. CONTINUE READING CARD (Horizontal Carousel)
    if (cardType == StoryCardType.continueReading) {
      return Container(
        width: 210,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover
                BookCoverWidget(
                  title: story.title,
                  author: story.authorName,
                  category: story.category,
                  coverUrl: story.coverUrl,
                  height: 165,
                ),
                const SizedBox(height: 10),

                // Progress Indicator Line
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: primaryTerracotta,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5DFD7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Category Tag
                Text(
                  story.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryTerracotta,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),

                // Title
                Text(
                  story.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColorDark,
                  ),
                ),
                const SizedBox(height: 2),

                // Author
                Text(
                  'by ${story.authorName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColorMuted,
                  ),
                ),
                const SizedBox(height: 6),

                // Rating
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD69E2E)),
                    const SizedBox(width: 4),
                    Text(
                      '${story.rating}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColorDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. TRENDING CARD (Wide Vertical List Card)
    if (cardType == StoryCardType.trending) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                // Book Cover Graphic on Left
                SizedBox(
                  width: 78,
                  height: 105,
                  child: BookCoverWidget(
                    title: story.title,
                    author: story.authorName,
                    category: story.category,
                    coverUrl: story.coverUrl,
                    height: 105,
                    width: 78,
                  ),
                ),
                const SizedBox(width: 12),

                // Content Details on Right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (trendingRank != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECE7E2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#$trendingRank TRENDING',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6E645D),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            story.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C7A7B),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Text(
                        story.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColorDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        '${story.authorName} • ${story.readsCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColorMuted,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD69E2E)),
                          const SizedBox(width: 3),
                          Text(
                            '${story.rating}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textColorDark,
                              ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '${story.chapters} chapters',
                              style: TextStyle(
                                fontSize: 12,
                                color: textColorMuted,
                              ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3. RECOMMENDATIONS CARD (2-Column Grid Item)
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover
              Expanded(
                child: BookCoverWidget(
                  title: story.title,
                  author: story.authorName,
                  category: story.category,
                  coverUrl: story.coverUrl,
                  height: double.infinity,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                story.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColorDark,
                ),
              ),
              const SizedBox(height: 2),

              Text(
                story.authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: textColorMuted,
                ),
              ),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD69E2E)),
                      const SizedBox(width: 3),
                      Text(
                        '${story.rating}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textColorDark,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    story.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: primaryTerracotta,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
