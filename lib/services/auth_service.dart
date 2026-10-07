import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fitstart_mobile_app/models/user_model.dart';
import 'package:fitstart_mobile_app/services/database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _userFromFirebaseUser(User? user, {String name = ""}) {
    return user != null
        ? UserModel(id: user.uid, name: name.isNotEmpty ? name : user.displayName ?? "User", email: user.email ?? "")
        : null;
  }

  UserModel? get currentUser {
    return _userFromFirebaseUser(_auth.currentUser);
  }

  // Register function using Firebase
  Future<UserModel?> registerWithEmailAndPassword(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      
      // Update the display name
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
      }
      
      return _userFromFirebaseUser(user, name: name);
    } catch (e) {
      print("Error in registerWithEmailAndPassword: $e");
      rethrow;
    }
  }

  // Login function using Firebase
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print("Error in signInWithEmailAndPassword: $e");
      rethrow;
    }
  }

  // Sign out using Firebase
  Future<void> signOut() async {
    try {
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (_) {}
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error in signOut: $e");
    }
  }

  // Helper to sync social sign-in user profile with Firestore
  Future<void> _syncSocialUserProfile(User user) async {
    try {
      final dbService = DatabaseService();
      final doc = await dbService.getUserProfile(user.uid);
      if (!doc.exists) {
        await dbService.createUserProfile(user.uid, {
          'email': user.email ?? '',
          'name': user.displayName ?? (user.email?.split('@').first ?? 'User'),
          'createdAt': FieldValue.serverTimestamp(),
          'goal': '',
          'height': 0.0,
          'weight': 0.0,
          'age': 0,
        });
      }
    } catch (dbError) {
      debugPrint("Error syncing social profile to Firestore: $dbError");
    }
  }

  // Sign in using Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final UserCredential userCredential;
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        try {
          userCredential = await _auth.signInWithPopup(googleProvider);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
            return null; // User simply closed the popup window
          }
          rethrow;
        }
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          return null; // User cancelled
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      final User? user = userCredential.user;
      if (user != null) {
        await _syncSocialUserProfile(user);
      }

      return _userFromFirebaseUser(user);
    } catch (e) {
      debugPrint("Error in signInWithGoogle: $e");
      rethrow;
    }
  }

  // Sign in using Apple
  Future<UserModel?> signInWithApple() async {
    try {
      final appleProvider = OAuthProvider('apple.com');
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      final UserCredential userCredential;
      try {
        userCredential = kIsWeb
            ? await _auth.signInWithPopup(appleProvider)
            : await _auth.signInWithProvider(appleProvider);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
          return null; // User simply closed the popup window
        }
        rethrow;
      }

      final User? user = userCredential.user;
      if (user != null) {
        await _syncSocialUserProfile(user);
      }

      return _userFromFirebaseUser(user);
    } catch (e) {
      debugPrint("Error in signInWithApple: $e");
      rethrow;
    }
  }

  // Check if an email is already registered in the system (Firestore)
  Future<bool> isEmailRegistered(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) return false;

    try {
      final firestore = FirebaseFirestore.instance;
      final lowerEmail = cleanEmail.toLowerCase();

      final queryLower = await firestore
          .collection('users')
          .where('email', isEqualTo: lowerEmail)
          .limit(1)
          .get();

      if (queryLower.docs.isNotEmpty) {
        debugPrint("User email found in Firestore: $lowerEmail");
        return true;
      }

      if (cleanEmail != lowerEmail) {
        final queryExact = await firestore
            .collection('users')
            .where('email', isEqualTo: cleanEmail)
            .limit(1)
            .get();
        if (queryExact.docs.isNotEmpty) {
          debugPrint("User email found in Firestore (case-sensitive): $cleanEmail");
          return true;
        }
      }
    } catch (e) {
      debugPrint("Firestore isEmailRegistered check error: $e");
    }

    return false;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim();
    debugPrint("Sending password reset email to: $cleanEmail");
    await _auth.sendPasswordResetEmail(email: cleanEmail);
    debugPrint("Password reset email sent to: $cleanEmail");
  }
}
