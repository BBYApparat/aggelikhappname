import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'dart:convert';
import '../models/reaction.dart';

class ReactionService extends ChangeNotifier {
  final String _baseUrl = 'https://api.realnow.com/v1';
  final Map<String, List<Reaction>> _postReactions = {};

  List<Reaction> getReactionsForPost(String postId) {
    return _postReactions[postId] ?? [];
  }

  Future<void> loadReactionsForPost(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/$postId/reactions'),
        headers: {'Authorization': 'Bearer token'}, // TODO: Add real token
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reactionsData = data['reactions'] as List;
        
        _postReactions[postId] = reactionsData
            .map((reactionJson) => Reaction.fromJson(reactionJson))
            .toList();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading reactions: $e');
    }
  }

  Future<bool> addRealMoji(String postId, XFile selfieImage) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/posts/$postId/reactions'),
      );

      request.headers['Authorization'] = 'Bearer token'; // TODO: Add real token
      request.fields['type'] = 'realmoji';
      
      request.files.add(
        await http.MultipartFile.fromPath('selfie', selfieImage.path),
      );

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadReactionsForPost(postId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding RealMoji: $e');
      return false;
    }
  }

  Future<bool> addComment(String postId, String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/posts/$postId/reactions'),
        headers: {
          'Authorization': 'Bearer token', // TODO: Add real token
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'type': 'comment',
          'text': text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadReactionsForPost(postId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return false;
    }
  }

  Future<bool> deleteReaction(String reactionId, String postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/reactions/$reactionId'),
        headers: {'Authorization': 'Bearer token'}, // TODO: Add real token
      );

      if (response.statusCode == 200) {
        await loadReactionsForPost(postId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting reaction: $e');
      return false;
    }
  }
}