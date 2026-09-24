import 'package:fitstart_mobile_app/models/user_model.dart';

class AuthService {
  // A simple mockup state to simulate an active user session.
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  // Mock register function
  Future<UserModel?> registerWithEmailAndPassword(String name, String email, String password) async {
    // In a real app, you would integrate Firebase or your own backend here.
    // For now, simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Create a mock user
    _currentUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      name: name, 
      email: email
    );
    
    return _currentUser;
  }

  // Mock login function
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Allow any email/password combo for mock purposes
    _currentUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      name: "Mock User", 
      email: email
    );
    
    return _currentUser;
  }

  // Mock sign out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }
}
