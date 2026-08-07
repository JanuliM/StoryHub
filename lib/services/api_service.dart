import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import '../models/story.dart';
import '../models/user.dart';

class ApiService {
  static String? authToken;
  static User? currentUser;

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
      // Fallback offline mock registration if backend server is not running
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
      // Fallback offline mock login if backend server is not running
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

  // --- Fetch Stories (with Dummy Fallback) ---
  Future<List<Story>> fetchStories() async {
    final url = Uri.parse('$baseUrl/stories');
    try {
      final response = await client.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data.map((item) => Story.fromJson(item)).toList();
        }
      }
    } catch (_) {
      // Fallback to dummy curated stories matching mockups
    }

    return getDummyStories();
  }

  static List<Story> getDummyStories() {
    return [
      Story(
        id: '1',
        title: 'The Whispering Woods',
        category: 'MYSTERY',
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
        category: 'SCI-FI',
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
        category: 'LITERARY',
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
        category: 'ROMANCE',
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
        category: 'FANTASY',
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
        title: 'Locked in Silence',
        category: 'THRILLER',
        authorName: 'Gideon Graves',
        likes: 310,
        rating: 4.8,
        chapters: 20,
        readsCount: '14k reads',
        readTime: '10 min read',
        content: '''The keyhole in the old oak door of Room 404 was keyless. Detective Miller peered through it, expecting darkness, but saw a lit room with a typewriter typing by itself.

Each keystroke echoed through the empty hallway, spelling out Miller's own name and the secret he had buried ten years ago.''',
      ),
      Story(
        id: '7',
        title: "Mornings at May's",
        category: 'DRAMA',
        authorName: 'Clara Bloom',
        likes: 275,
        rating: 4.5,
        chapters: 14,
        readsCount: '9k reads',
        readTime: '5 min read',
        content: '''May's Diner had served cinnamon rolls and hot coffee since 1978. It was the heart of Millfield, where strangers became confidants over steaming mugs and quiet morning conversations.''',
      ),
      Story(
        id: '8',
        title: 'The Inkwell Veil',
        category: 'HISTORY',
        authorName: 'Arthur Penhallgon',
        likes: 540,
        rating: 4.9,
        chapters: 22,
        readsCount: '18k reads',
        readTime: '11 min read',
        content: '''In the archives of Venice during the Renaissance, scribes wrote encoded letters to protect royal manuscripts from thieves. A single drops of indigo ink hid entire maps across empires.''',
      ),
    ];
  }
}
