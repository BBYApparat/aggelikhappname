import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post.dart';

class PostService extends ChangeNotifier {
  final String _baseUrl = 'https://api.realnow.com/v1';
  List<Post> _todaysPosts = [];
  List<Post> _archivePosts = [];
  bool _hasPostedToday = false;

  List<Post> get todaysPosts => _todaysPosts;
  List<Post> get archivePosts => _archivePosts;
  bool get hasPostedToday => _hasPostedToday;

  Future<bool> checkHasPostedToday() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me/posts/today'),
        headers: {'Authorization': 'Bearer token'}, // TODO: Add real token
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _hasPostedToday = data['has_posted'] ?? false;
        notifyListeners();
        return _hasPostedToday;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking today\'s post: $e');
      return false;
    }
  }

  Future<void> createPost({
    required XFile rearImage,
    required XFile frontImage,
    String? caption,
    bool locationEnabled = false,
    int retakeCount = 0,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/posts'),
      );

      request.headers['Authorization'] = 'Bearer token'; // TODO: Add real token
      
      request.files.add(
        await http.MultipartFile.fromPath('rear', rearImage.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('front', frontImage.path),
      );

      request.fields['retake_idx'] = retakeCount.toString();
      if (caption != null && caption.isNotEmpty) {
        request.fields['caption'] = caption;
      }
      request.fields['location_opt_in'] = locationEnabled.toString();

      final response = await request.send();
      await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        _hasPostedToday = true;
        notifyListeners();
        await loadTodaysFeed();
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  Future<void> loadTodaysFeed() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/feed/today'),
        headers: {'Authorization': 'Bearer token'}, // TODO: Add real token
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final postsData = data['posts'] as List;
        
        _todaysPosts = postsData
            .map((postJson) => Post.fromJson(postJson))
            .toList();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading feed: $e');
    }
  }

  Future<void> loadUserArchive() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me/archive'),
        headers: {'Authorization': 'Bearer token'}, // TODO: Add real token
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final postsData = data['posts'] as List;
        
        _archivePosts = postsData
            .map((postJson) => Post.fromJson(postJson))
            .toList();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading archive: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/posts/$postId'),
        headers: {'Authorization': 'Bearer token'}, // TODO: Add real token
      );

      if (response.statusCode == 200) {
        _todaysPosts.removeWhere((post) => post.id == postId);
        _archivePosts.removeWhere((post) => post.id == postId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting post: $e');
    }
  }
}