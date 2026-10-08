import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitstart_mobile_app/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _userFromFirebaseUser(User? user, {String name = ""}) {
    return user != null
        ? UserModel(
            id: user.uid,
            name: name.isNotEmpty ? name : user.displayName ?? "User",
            email: user.email ?? "",
          )
        : null;
  }

  UserModel? get currentUser {
    return _userFromFirebaseUser(_auth.currentUser);
  }

  // Register function using Firebase
  Future<UserModel?> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
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
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
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
    await _auth.signOut();
  }
}
