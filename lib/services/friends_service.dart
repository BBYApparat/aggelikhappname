import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/friendship.dart';
import '../models/user.dart' as app_user;

class FriendsService extends ChangeNotifier {
  final String _baseUrl = 'https://api.realnow.com/v1';
  List<app_user.User> _friends = [];
  List<Friendship> _friendRequests = [];

  List<app_user.User> get friends => _friends;
  List<Friendship> get friendRequests => _friendRequests;

  Future<void> loadFriends() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/friends'),
        headers: {'Authorization': 'Bearer token'}, // TODO: Add real token
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final friendsData = data['friends'] as List;
        
        _friends = friendsData
            .map((friendJson) => app_user.User.fromJson(friendJson))
            .toList();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading friends: $e');
    }
  }

  Future<void> loadFriendRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/friends/requests'),
        headers: {'Authorization': 'Bearer token'}, // TODO: Add real token
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final requestsData = data['requests'] as List;
        
        _friendRequests = requestsData
            .map((requestJson) => Friendship.fromJson(requestJson))
            .toList();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading friend requests: $e');
    }
  }

  Future<bool> sendFriendRequest(String toUserId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/friends/requests'),
        headers: {
          'Authorization': 'Bearer token', // TODO: Add real token
          'Content-Type': 'application/json',
        },
        body: json.encode({'to_user': toUserId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadFriendRequests();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      return false;
    }
  }

  Future<bool> acceptFriendRequest(String requestId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/friends/requests/$requestId/accept'),
        headers: {'Authorization': 'Bearer token'}, // TODO: Add real token
      );

      if (response.statusCode == 200) {
        await Future.wait([
          loadFriends(),
          loadFriendRequests(),
        ]);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
      return false;
    }
  }

  Future<List<app_user.User>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/search?q=$query'),
        headers: {'Authorization': 'Bearer token'}, // TODO: Add real token
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final usersData = data['users'] as List;
        
        return usersData
            .map((userJson) => app_user.User.fromJson(userJson))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  Future<bool> removeFriend(String friendId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/friends/$friendId'),
        headers: {'Authorization': 'Bearer token'}, // TODO: Add real token
      );

      if (response.statusCode == 200) {
        await loadFriends();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error removing friend: $e');
      return false;
    }
  }
}