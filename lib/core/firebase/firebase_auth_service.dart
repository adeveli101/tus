import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:tus/core/firebase/firebase_config.dart';

class FirebaseAuthService {
  late final FirebaseAuth _auth;

  FirebaseAuthService() {
    try {
      _auth = FirebaseAuth.instance;
    } catch (e) {
      if (kDebugMode) {
        print('FirebaseAuth initialization error: $e');
      }
      // Initialize with a default instance if needed
      _auth = FirebaseAuth.instance;
    }
  }

  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        print('Anonim giriş hatası: $e');
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
} 