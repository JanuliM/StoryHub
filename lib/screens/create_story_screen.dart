import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../widgets/story_card.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _contentController = TextEditingController();
  final ApiService _apiService = ApiService();

  String _selectedCategory = 'Fantasy';
  bool _isPublishing = false;
  bool _isGeneratingAi = false;
  String? _base64CoverImage;

  final List<String> _categories = [
    'Fantasy',
    'Romance',
    'Horror',
    'Mystery',
    'Adventure',
    'Science Fiction',
    'Comedy',
    'Drama',
    'History',
    'Literary',
  ];

  // Preset sample cover images for convenience
  final Map<String, String> _sampleCovers = {
    'Fantasy Castle': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80',
    'Enchanted Forest': 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=600&q=80',
    'Sci-Fi Galaxy': 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=600&q=80',
    'Cozy Library': 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=600&q=80',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _coverUrlController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      setState(() {
        _base64CoverImage = 'data:image/jpeg;base64,$base64String';
      });
    }
  }

  Future<void> _requestAiHelp(String mode) async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write a bit of your story first, then ask for help.')),
      );
      return;
    }

    setState(() => _isGeneratingAi = true);

    final result = await _apiService.getAiSuggestion(
      content: content,
      category: _selectedCategory,
      mode: mode,
    );

    if (!mounted) return;
    setState(() => _isGeneratingAi = false);

    if (result['success'] == true) {
      _showAiSuggestionDialog(result['suggestion'] as String? ?? '', mode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Could not generate a suggestion'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _insertAiSuggestion(String suggestion) {
    final current = _contentController.text;
    final needsSeparator = current.trim().isNotEmpty;
    final separator = needsSeparator ? (current.endsWith('\n\n') ? '' : '\n\n') : '';
    _contentController.text = '$current$separator$suggestion';
    _contentController.selection = TextSelection.collapsed(offset: _contentController.text.length);
  }

  void _showAiSuggestionDialog(String suggestion, String mode) {
    final isBrainstorm = mode == 'brainstorm';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFBF9F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFFB83B00), size: 20),
            const SizedBox(width: 8),
            Text(
              isBrainstorm ? 'Plot Ideas' : 'AI Suggestion',
              style: const TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold, color: Color(0xFF1E1814)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            suggestion,
            style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF332B25)),
          ),
        ),
        actions: isBrainstorm
            ? [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it', style: TextStyle(color: Color(0xFFB83B00))),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF736860))),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _requestAiHelp('continue');
                  },
                  child: const Text('Try Again', style: TextStyle(color: Color(0xFFB83B00))),
                ),
                ElevatedButton(
                  onPressed: () {
                    _insertAiSuggestion(suggestion);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB83B00)),
                  child: const Text('Insert', style: TextStyle(color: Colors.white)),
                ),
              ],
      ),
    );
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPublishing = true);

    final String? finalCover = _base64CoverImage ?? 
        (_coverUrlController.text.trim().isNotEmpty ? _coverUrlController.text.trim() : null);

    final result = await _apiService.createStory(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      content: _contentController.text.trim(),
      coverUrl: finalCover,
    );

    setState(() => _isPublishing = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story published successfully! 🎉'),
          backgroundColor: Color(0xFFB83B00),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to publish story'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildAiHelperButton({required IconData icon, required String label, required String mode}) {
    return OutlinedButton.icon(
      onPressed: _isGeneratingAi ? null : () => _requestAiHelp(mode),
      icon: _isGeneratingAi
          ? const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B00))),
            )
          : Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFB83B00),
        side: const BorderSide(color: Color(0xFFB83B00)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
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
    final inputFillColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFAF7F2);

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColorDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Story',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColorDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: _isPublishing ? null : _handlePublish,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTerracotta,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isPublishing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Publish',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share your narrative with the world.',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColorMuted,
                  ),
                ),
                const SizedBox(height: 20),

                // Form Container Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. TITLE TEXT FIELD
                      Text(
                        'Story Title',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColorDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColorDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g., The Whispering Woods',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFFA0968E),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: primaryTerracotta, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a story title';
                          }
                          if (value.trim().length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // 2. CATEGORY DROPDOWN
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColorDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        style: TextStyle(fontSize: 14, color: textColorDark),
                        dropdownColor: cardColor,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: textColorMuted),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: primaryTerracotta, width: 1.5),
                          ),
                        ),
                        items: _categories.map((String cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: primaryTerracotta,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: textColorDark,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      // 3. COVER IMAGE UPLOAD (Device or URL)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cover Picture',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColorDark,
                            ),
                          ),
                          if (_base64CoverImage != null || _coverUrlController.text.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _base64CoverImage = null;
                                  _coverUrlController.clear();
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Clear', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      if (_base64CoverImage == null && _coverUrlController.text.isEmpty)
                        InkWell(
                          onTap: _pickCoverImage,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: inputFillColor,
                              border: Border.all(color: borderColor, style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, color: textColorMuted, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to upload cover photo',
                                  style: TextStyle(color: textColorMuted, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _base64CoverImage != null
                                ? Image.memory(
                                    base64Decode(_base64CoverImage!.split(',')[1]),
                                    width: 120,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  )
                                : SizedBox(
                                    width: 120,
                                    height: 160,
                                    child: BookCoverWidget(
                                      title: _titleController.text.isNotEmpty ? _titleController.text : 'Cover',
                                      author: 'Preview',
                                      category: _selectedCategory,
                                      coverUrl: _coverUrlController.text.trim(),
                                      height: 160,
                                    ),
                                  ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Or choose a sample cover photo:',
                          style: TextStyle(fontSize: 11, color: textColorMuted),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: _sampleCovers.entries.map((e) {
                            final isSelected = _coverUrlController.text == e.value && _base64CoverImage == null;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _base64CoverImage = null; // Clear picked image if preset is selected
                                  _coverUrlController.text = e.value;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? primaryTerracotta : inputFillColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? primaryTerracotta : borderColor,
                                  ),
                                ),
                                child: Text(
                                  e.key,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : textColorDark,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 18),



                      // 4. LARGE MULTI-LINE TEXT AREA FOR STORY CONTENT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Story Content',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColorDark,
                            ),
                          ),
                          Row(
                            children: [
                              _buildAiHelperButton(
                                icon: Icons.lightbulb_outline_rounded,
                                label: 'Ideas',
                                mode: 'brainstorm',
                              ),
                              const SizedBox(width: 6),
                              _buildAiHelperButton(
                                icon: Icons.auto_awesome_rounded,
                                label: 'Help Me Write',
                                mode: 'continue',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _contentController,
                        maxLines: 14,
                        minLines: 8,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 15,
                          height: 1.6,
                          color: textColorDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Once upon a time in a distant kingdom...',
                          hintStyle: const TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 14,
                            color: Color(0xFFA0968E),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: primaryTerracotta, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please write your story content';
                          }
                          if (value.trim().length < 20) {
                            return 'Story content should be at least 20 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 5. MAIN BOTTOM PUBLISH BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isPublishing ? null : _handlePublish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTerracotta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isPublishing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.publish_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Publish Story',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


