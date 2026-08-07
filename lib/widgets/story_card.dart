import 'package:flutter/material.dart';
import '../models/story.dart';
import 'book_cover.dart';

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
    const primaryTerracotta = Color(0xFFB83B00);
    const textColorDark = Color(0xFF1E1814);
    const textColorMuted = Color(0xFF736860);
    const borderColor = Color(0xFFEBE4DC);

    // 1. CONTINUE READING CARD (Horizontal Carousel)
    if (cardType == StoryCardType.continueReading) {
      return Container(
        width: 210,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
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
                  height: 165,
                ),
                const SizedBox(height: 10),

                // Progress Indicator Line (matching mockup red/grey bar)
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
                  style: const TextStyle(
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
                  style: const TextStyle(
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
                      style: const TextStyle(
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
          color: Colors.white,
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
                      // Rank Badge + Category Tag Row
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

                      // Title
                      Text(
                        story.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColorDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Author & Reads Count
                      Text(
                        '${story.authorName} • ${story.readsCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: textColorMuted,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rating & Chapters
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD69E2E)),
                          const SizedBox(width: 3),
                          Text(
                            '${story.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColorDark,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '${story.chapters} chapters',
                            style: const TextStyle(
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

    // 3. RECOMMENDATIONS CARD (2-Column Grid Item matching bottom of mockup)
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                  height: double.infinity,
                ),
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                story.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColorDark,
                ),
              ),
              const SizedBox(height: 2),

              // Author
              Text(
                story.authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: textColorMuted,
                ),
              ),
              const SizedBox(height: 6),

              // Bottom Row: Rating & Category Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD69E2E)),
                      const SizedBox(width: 3),
                      Text(
                        '${story.rating}',
                        style: const TextStyle(
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
