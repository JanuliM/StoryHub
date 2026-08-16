import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import '../models/story.dart';
import '../models/user.dart';
import '../models/comment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String? authToken;
  static User? currentUser;

  // In-memory store for comments queued while offline
  static final Map<String, List<Comment>> _localCommentsStore = {};

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    // Updated to the computer's WiFi IP so your physical device can connect
    return 'http://10.10.26.189:5000';
  }

  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  // --- Initialize Persistent Auth ---
  Future<void> initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    
    final userJsonStr = prefs.getString('current_user');
    if (userJsonStr != null) {
      try {
        final userData = json.decode(userJsonStr);
        currentUser = User.fromJson(userData);
      } catch (_) {}
    }
  }

  Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('current_user', json.encode(userData));
  }
  
  Future<void> logout() async {
    authToken = null;
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
  }

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
          await _saveAuthData(authToken!, data['user']);
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
          await _saveAuthData(authToken!, data['user']);
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

  // --- Auth: Update Profile Image ---
  Future<bool> uploadProfileImage(String base64Image) async {
    if (currentUser == null) return false;

    final url = Uri.parse('$baseUrl/profile-image');
    try {
      final response = await client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': currentUser!.id,
          'base64Image': base64Image,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['user'] != null) {
          currentUser = User.fromJson(data['user']);
          if (authToken != null) {
            await _saveAuthData(authToken!, data['user']);
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  // --- Auth: Update Profile (username/bio) ---
  Future<Map<String, dynamic>> updateProfile({String? username, String? bio}) async {
    if (currentUser == null) return {'success': false, 'message': 'Not logged in'};

    final url = Uri.parse('$baseUrl/users/me');
    try {
      final response = await client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          if (username != null) 'username': username,
          if (bio != null) 'bio': bio,
        }),
      ).timeout(const Duration(seconds: 5));

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['user'] != null) {
        currentUser = User.fromJson(data['user']);
        if (authToken != null) {
          await _saveAuthData(authToken!, data['user']);
        }
        return {'success': true, 'user': currentUser};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to update profile'};
    } catch (_) {
      return {'success': false, 'message': 'Could not reach the server'};
    }
  }

  // --- Fetch a public author profile with stats ---
  Future<User?> fetchAuthorProfile(String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId');
    try {
      final response = await client.get(url).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      }
    } catch (_) {}
    return null;
  }

  // --- Follow / Unfollow an author ---
  Future<Map<String, dynamic>> toggleFollow(String authorId) async {
    final url = Uri.parse('$baseUrl/follow/$authorId');
    try {
      final response = await client.post(
        url,
        headers: {
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      }
    } catch (_) {}
    return {'success': false};
  }

  Future<bool> checkFollowStatus(String authorId) async {
    final url = Uri.parse('$baseUrl/follow/status/$authorId');
    try {
      final response = await client.get(
        url,
        headers: {
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['following'] ?? false;
      }
    } catch (_) {}
    return false;
  }

  Future<List<User>> fetchFollowers(String userId) async {
    final url = Uri.parse('$baseUrl/follow/followers/$userId');
    try {
      final response = await client.get(url).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => User.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<User>> fetchFollowing(String userId) async {
    final url = Uri.parse('$baseUrl/follow/following/$userId');
    try {
      final response = await client.get(url).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => User.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  // --- Fetch Stories ---
  Future<List<Story>> fetchStories() async {
    final url = Uri.parse('$baseUrl/stories');
    try {
      final response = await client.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Story.fromJson(item)).toList();
      }
    } catch (_) {}

    return [];
  }

  // --- Fetch Trending Stories ---
  Future<List<Story>> fetchTrendingStories() async {
    final url = Uri.parse('$baseUrl/stories/trending');
    try {
      final response = await client.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Story.fromJson(item)).toList();
      }
    } catch (_) {}

    return [];
  }

  // --- Increment Reads Count ---
  Future<void> incrementStoryReads(String storyId) async {
    final url = Uri.parse('$baseUrl/stories/$storyId/read');
    try {
      await client.put(url).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }


  // --- Delete Story API ---
  Future<Map<String, dynamic>> deleteStory(String storyId) async {
    final url = Uri.parse('$baseUrl/stories/$storyId');
    try {
      final response = await client.delete(
        url,
        headers: {
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return {'success': true};
      }

      final data = json.decode(response.body);
      return {'success': false, 'message': data['message'] ?? 'Failed to delete story'};
    } catch (_) {
      return {'success': false, 'message': 'Could not reach the server'};
    }
  }

  // --- User Profile & Library Data ---
  // Fetches published stories for a given author (defaults to the logged-in user)
  // filtered server-side by author ID, so two users sharing a display name don't collide.
  Future<List<Story>> fetchUserStories({String? authorId}) async {
    final id = authorId ?? currentUser?.id;
    if (id == null || id.isEmpty) return [];

    final url = Uri.parse('$baseUrl/stories?author=$id');
    try {
      final response = await client.get(url).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Story.fromJson(item)).toList();
      }
    } catch (_) {}

    return [];
  }

  // Liking isn't tracked per-user on the backend yet, so there's nothing real to show here.
  Future<List<Story>> fetchLikedStories() async {
    return [];
  }

  Future<List<Story>> fetchBookmarkedStories() async {
    final url = Uri.parse('$baseUrl/bookmark');
    try {
      final response = await client.get(
        url,
        headers: {
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          // The backend returns an array of Bookmarks. Each bookmark has a populated 'storyId' field
          return data
              .where((item) => item['storyId'] != null)
              .map((item) => Story.fromJson(item['storyId']))
              .toList();
        }
        return [];
      }
    } catch (_) {}

    return [];
  }

  // --- Check Bookmark Status API ---
  Future<bool> checkBookmarkStatus(String storyId) async {
    final url = Uri.parse('$baseUrl/bookmark/check/$storyId');
    try {
      final response = await client.get(
        url,
        headers: {
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['bookmarked'] ?? false;
      }
    } catch (_) {}
    return false;
  }

  // --- Toggle Bookmark API ---
  Future<Map<String, dynamic>> toggleBookmark(String storyId) async {
    final url = Uri.parse('$baseUrl/bookmark');
    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'storyId': storyId}),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      }
    } catch (_) {}
    return {'success': false};
  }

  // --- Create / Publish Story API ---
  Future<Map<String, dynamic>> createStory({
    required String title,
    required String category,
    required String content,
    String? coverUrl,
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
          if (coverUrl != null && coverUrl.isNotEmpty) 'coverUrl': coverUrl,
        }),
      ).timeout(const Duration(seconds: 3));

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newStory = Story.fromJson(data);
        return {'success': true, 'story': newStory};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to publish story'};
      }
    } catch (_) {
      return {'success': false, 'message': 'Could not reach the server. Please try again.'};
    }
  }

  // --- AI Story Assistant ---
  Future<Map<String, dynamic>> getAiSuggestion({
    required String content,
    required String category,
    String mode = 'continue',
  }) async {
    final url = Uri.parse('$baseUrl/stories/ai-continue');
    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'content': content,
          'category': category,
          'mode': mode,
        }),
      ).timeout(const Duration(seconds: 20));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'suggestion': data['suggestion']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to generate suggestion'};
    } catch (_) {
      return {'success': false, 'message': 'Could not reach the server'};
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

    // Offline: only real, locally-queued comments (if any) — no placeholder content.
    return _localCommentsStore[storyId] ?? [];
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

  // --- Delete Comment API ---
  Future<Map<String, dynamic>> deleteComment({required String commentId, required String storyId}) async {
    final url = Uri.parse('$baseUrl/comments/$commentId');
    try {
      final response = await client.delete(
        url,
        headers: {
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        if (_localCommentsStore.containsKey(storyId)) {
          _localCommentsStore[storyId]!.removeWhere((c) => c.id == commentId);
        }
        return {'success': true};
      }
    } catch (_) {}

    // Offline fallback comment deletion
    if (_localCommentsStore.containsKey(storyId)) {
      _localCommentsStore[storyId]!.removeWhere((c) => c.id == commentId);
    }
    return {'success': true, 'isOffline': true};
  }
}

