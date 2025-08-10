import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import '../models/user.dart' as app_user;

class AuthService extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  app_user.User? _currentUser;

  app_user.User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(firebase_auth.User? user) {
    if (user != null) {
      _loadUserProfile(user);
    } else {
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile(firebase_auth.User user) async {
    try {
      _currentUser = app_user.User(
        id: user.uid,
        handle: user.displayName ?? '',
        displayName: user.displayName ?? '',
        avatarUrl: user.photoURL,
        phoneOrEmail: user.email,
        country: 'US',
        timezone: 'UTC',
        settings: app_user.UserSettings(
          locationOptIn: false,
          whoCanFriend: 'everyone',
        ),
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  Future<bool> registerWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await credential.user?.updateDisplayName(displayName);
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
      await _loadUserProfile(user);
    }
  }
}