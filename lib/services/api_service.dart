import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:story_hub/models/story.dart';

class ApiService {
  // Configures base URL dynamically depending on platform/environment
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

  Future<List<Story>> fetchStories() async {
    final url = Uri.parse('$baseUrl/stories');
    
    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Story.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stories: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load stories: $e');
    }
  }
}
