import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import '../models/story.dart';
import '../models/user.dart';
import '../models/comment.dart';

class ApiService {
  static String? authToken;
  static User? currentUser;

  // In-memory store for created stories and comments when offline
  static final List<Story> _userCreatedStories = [];
  static final Map<String, List<Comment>> _localCommentsStore = {};

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000';
      }
    } catch (_) {}
    return 'http://localhost:5000';
  }

  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  // --- Auth: Register ---
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 3));

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        authToken = data['token'];
        if (data['user'] != null) {
          currentUser = User.fromJson(data['user']);
        }
        return {'success': true, 'token': authToken, 'user': currentUser};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      authToken = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      currentUser = User(
        id: 'user_offline_123',
        username: username.isNotEmpty ? username : 'Januli',
        email: email.isNotEmpty ? email : 'januli@gmail.com',
      );
      return {
        'success': true,
        'token': authToken,
        'user': currentUser,
        'isOffline': true,
      };
    }
  }

  // --- Auth: Login ---
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 3));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        authToken = data['token'];
        if (data['user'] != null) {
          currentUser = User.fromJson(data['user']);
        }
        return {'success': true, 'token': authToken, 'user': currentUser};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Invalid credentials'};
      }
    } catch (e) {
      authToken = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      currentUser = User(
        id: 'user_offline_123',
        username: email.split('@').first,
        email: email,
      );
      return {
        'success': true,
        'token': authToken,
        'user': currentUser,
        'isOffline': true,
      };
    }
  }

  // --- Fetch Stories ---
  Future<List<Story>> fetchStories() async {
    final url = Uri.parse('$baseUrl/stories');
    try {
      final response = await client.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final fetched = data.map((item) => Story.fromJson(item)).toList();
          return [..._userCreatedStories, ...fetched];
        }
      }
    } catch (_) {}

    return [..._userCreatedStories, ...getDummyStories()];
  }

  // --- Create / Publish Story API ---
  Future<Map<String, dynamic>> createStory({
    required String title,
    required String category,
    required String content,
  }) async {
    final url = Uri.parse('$baseUrl/stories');
    final authorName = currentUser?.username ?? 'Januli';

    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'title': title,
          'category': category,
          'content': content,
          'authorName': authorName,
        }),
      ).timeout(const Duration(seconds: 3));

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newStory = Story.fromJson(data);
        _userCreatedStories.insert(0, newStory);
        return {'success': true, 'story': newStory};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to publish story'};
      }
    } catch (e) {
      // Offline fallback story creation
      final wordsCount = content.trim().split(RegExp(r'\s+')).length;
      final estReadTime = '${(wordsCount / 150).ceil()} min read';

      final offlineStory = Story(
        id: 'created_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        category: category,
        content: content,
        authorName: authorName,
        likes: 1,
        rating: 5.0,
        chapters: 1,
        readsCount: '1 read',
        readTime: estReadTime,
        createdAt: DateTime.now(),
      );

      _userCreatedStories.insert(0, offlineStory);
      return {'success': true, 'story': offlineStory, 'isOffline': true};
    }
  }

  // --- Comments API ---
  Future<List<Comment>> fetchComments(String storyId) async {
    final url = Uri.parse('$baseUrl/comments/$storyId');
    try {
      final response = await client.get(url).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Comment.fromJson(item)).toList();
      }
    } catch (_) {}

    if (!_localCommentsStore.containsKey(storyId)) {
      _localCommentsStore[storyId] = [
        Comment(
          id: 'c1',
          storyId: storyId,
          userId: 'u101',
          userName: 'Elena Rostova',
          comment: 'This chapter was absolutely captivating! The atmosphere and descriptive imagery gave me goosebumps.',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Comment(
          id: 'c2',
          storyId: storyId,
          userId: 'u102',
          userName: 'Julian Vance',
          comment: 'I love how the plot unfolds. Can’t wait for the next chapter update!',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
    }

    return _localCommentsStore[storyId]!;
  }

  Future<Comment> postComment({required String storyId, required String text}) async {
    final username = currentUser?.username ?? 'Januli';
    final userId = currentUser?.id ?? 'user_123';

    final url = Uri.parse('$baseUrl/comments');
    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'storyId': storyId,
          'comment': text,
        }),
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Comment.fromJson(data);
      }
    } catch (_) {}

    final newComment = Comment(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      storyId: storyId,
      userId: userId,
      userName: username,
      comment: text,
      createdAt: DateTime.now(),
    );

    if (!_localCommentsStore.containsKey(storyId)) {
      _localCommentsStore[storyId] = [];
    }
    _localCommentsStore[storyId]!.insert(0, newComment);

    return newComment;
  }

  static List<Story> getDummyStories() {
    return [
      Story(
        id: '1',
        title: 'The Whispering Woods',
        category: 'Mystery',
        authorName: 'Elara Vance',
        likes: 342,
        rating: 4.8,
        chapters: 16,
        readsCount: '15k reads',
        readTime: '7 min read',
        content: '''The wind didn't just blow through the valley of Elara; it hummed. It was a low, resonant frequency that vibrated in the marrow of Silas's bones as he approached the edge of the forbidden grove. Before him stood the Willow, its branches draped like weeping silver lace against the twilight sky.

Legends said the tree breathed the secrets of the departed, but Silas only heard a quiet rustling, a sound like a thousand dry pages turning at once. He took a step forward, his boots sinking into the soft, moss-covered earth that felt more like a thick woolen rug than soil.

"You shouldn't be here," a voice whispered, though Silas saw no one. It wasn't a voice of sound, but of thought, blooming in his mind like a drop of ink in clear water. The air around the tree grew heavy, smelling of old parchment and cedarwood—the scent of a library that had stood for centuries.

He reached out, his fingers trembling. The bark was surprisingly warm, pulsating with a rhythm that matched his own heartbeat. As his skin made contact, the silver leaves flared with a sudden, soft radiance, illuminating the clearing in a wash of sunset orange.''',
      ),
      Story(
        id: '2',
        title: 'Stellar Horizons',
        category: 'Science Fiction',
        authorName: 'Julian Rossi',
        likes: 512,
        rating: 4.9,
        chapters: 28,
        readsCount: '22k reads',
        readTime: '12 min read',
        content: '''Beyond the Kuiper belt, the stars did not twinkle; they burned like steady diamonds against the abyssal velvet of deep space. Captain Vane adjusted the grav-dampeners as the *Aegis Prime* slipped into orbit around the unknown ringed world.

Signals had been emanating from the moon's dark side for three cycles—not static, but rhythmic, mathematical prime sequences.

"Prepare the landing module," Vane commanded quietly, staring into the bioluminescent fog blanketing the alien surface.''',
      ),
      Story(
        id: '3',
        title: 'Echoes of the Silent Peak',
        category: 'Adventure',
        authorName: 'Marcus Thorne',
        likes: 428,
        rating: 4.7,
        chapters: 24,
        readsCount: '12k reads',
        readTime: '9 min read',
        content: '''High above the clouds, where oxygen was thin and silence felt sacred, the monastery stood on the precipice of Mount Kaelen. For forty years, Brother Thomas had maintained the ancient sun dial, marking the passage of light across carved runes.

Today, however, the shadow did not move as expected. It bent backward, defying gravity, pointing toward the forgotten cavern beneath the western ridge.''',
      ),
      Story(
        id: '4',
        title: "The Sunflowers' Secret",
        category: 'Romance',
        authorName: 'Sienna Rivers',
        likes: 620,
        rating: 4.9,
        chapters: 18,
        readsCount: '8.5k reads',
        readTime: '6 min read',
        content: '''Every morning at sunrise, Clara found a fresh yellow sunflower tucked into the wrought-iron fence of her bakery. No note, no signature—just the bright petals glistening with morning dew.

Until the Tuesday when rain washed away the veil of anonymity, and a tall artist with paint-stained hands stood shivering under the awning across the cobblestone street.''',
      ),
      Story(
        id: '5',
        title: 'Risen from the Ashes',
        category: 'Fantasy',
        authorName: 'Aria Nightshade',
        likes: 890,
        rating: 4.6,
        chapters: 32,
        readsCount: '30k reads',
        readTime: '15 min read',
        content: '''The Ashen Crown was forged in dragonfire and quenched in dragonblood. For three centuries it sat dormant atop the Blackspire, awaiting the true heir who possessed the ember in their eyes.

Kaelen knew he was no prince—he was just a blacksmith's apprentice. But when he touched the cold iron of the throne, flames erupted from his palms.''',
      ),
      Story(
        id: '6',
        title: 'Shadows in the Manor',
        category: 'Horror',
        authorName: 'Damian Blackwood',
        likes: 380,
        rating: 4.8,
        chapters: 15,
        readsCount: '19k reads',
        readTime: '8 min read',
        content: '''The clock struck midnight as the footsteps echoed down the empty corridor of Ravenhurst Manor, though no shadow crossed the moonlit floor.''',
      ),
      Story(
        id: '7',
        title: 'The Great Coffee Heist',
        category: 'Comedy',
        authorName: 'Leo Sterling',
        likes: 490,
        rating: 4.7,
        chapters: 10,
        readsCount: '11k reads',
        readTime: '5 min read',
        content: '''Stealing the world's last tin of artisanal espresso seemed like a brilliant idea—until the chief of police turned out to be Leo's barista.''',
      ),
      Story(
        id: '8',
        title: 'Locked in Silence',
        category: 'Mystery',
        authorName: 'Gideon Graves',
        likes: 310,
        rating: 4.8,
        chapters: 20,
        readsCount: '14k reads',
        readTime: '10 min read',
        content: '''The keyhole in the old oak door of Room 404 was keyless. Detective Miller peered through it, expecting darkness, but saw a lit room with a typewriter typing by itself.

Each keystroke echoed through the empty hallway, spelling out Miller's own name and the secret he had buried ten years ago.''',
      ),
    ];
  }
}
