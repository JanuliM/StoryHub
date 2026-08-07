import 'package:flutter/material.dart';
import '../models/story.dart';

class StoryReaderScreen extends StatefulWidget {
  final Story story;

  const StoryReaderScreen({super.key, required this.story});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  double _fontSize = 15.0;

  void _showFontSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFBF9F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reader Settings',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1814),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Font Size',
                        style: TextStyle(fontSize: 14, color: Color(0xFF736860)),
                      ),
                      Text(
                        '${_fontSize.toInt()}pt',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB83B00),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _fontSize,
                    min: 12.0,
                    max: 24.0,
                    activeColor: const Color(0xFFB83B00),
                    onChanged: (val) {
                      setModalState(() => _fontSize = val);
                      setState(() => _fontSize = val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
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
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColorDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'CHAPTER 1',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: primaryTerracotta,
              ),
            ),
            Text(
              widget.story.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Serif',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColorDark,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, color: textColorDark),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to Bookmarks!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner / Book Cover Graphic
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF2EA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEBE2D8)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📖', style: TextStyle(fontSize: 54)),
                      const SizedBox(height: 8),
                      Text(
                        widget.story.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColorDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Category Tag
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8ECE4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.story.category} NOVEL'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryTerracotta,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Center(
                child: Text(
                  widget.story.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColorDark,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Author
              Center(
                child: Text(
                  'By ${widget.story.authorName}',
                  style: const TextStyle(
                    fontFamily: 'Serif',
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    color: textColorMuted,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Story Content Body
              SelectableText(
                widget.story.content,
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: _fontSize,
                  height: 1.8,
                  color: const Color(0xFF2C241E),
                ),
              ),
              const SizedBox(height: 32),

              // Section Separator
              const Center(
                child: Text(
                  '•  •  •',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFBDB2A8),
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Chapter Navigation
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PREVIOUS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textColorMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'The Silent Stream',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryTerracotta,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'NEXT CHAPTER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textColorMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Echoes in the Glass',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryTerracotta,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFontSettings,
        backgroundColor: primaryTerracotta,
        foregroundColor: Colors.white,
        child: const Icon(Icons.settings),
      ),
    );
  }
}
