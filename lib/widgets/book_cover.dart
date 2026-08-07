import 'package:flutter/material.dart';

class BookCoverWidget extends StatelessWidget {
  final String title;
  final String author;
  final String category;
  final double height;
  final double width;

  const BookCoverWidget({
    super.key,
    required this.title,
    required this.author,
    required this.category,
    this.height = 160,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
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
    final subtextColor = isDark ? Colors.grey[400] : const Color(0xFF756C65);

    return Container(
      height: height,
      width: width,
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
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  centerIcon,
                  size: height > 120 ? 38 : 26,
                  color: accentColor,
                ),
                const SizedBox(height: 8),
                Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: height > 120 ? 12 : 10,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'By $author',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontStyle: FontStyle.italic,
                    fontSize: height > 120 ? 10 : 8,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
