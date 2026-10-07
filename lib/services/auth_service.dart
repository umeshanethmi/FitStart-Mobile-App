import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitstart_mobile_app/models/user_model.dart';

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
      await _auth.signOut();
    } catch (e) {
      print("Error in signOut: $e");
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
