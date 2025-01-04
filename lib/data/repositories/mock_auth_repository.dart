import 'package:myapp/data/models/user_model.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser = UserModel(
    id: 'user1',  // Match the creatorId in mock projects
    email: 'test@example.com',
    username: 'Test User',
  );

  @override
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    // Simulate a successful sign-in
    _currentUser = UserModel(
      id: 'user1',
      email: email,
      username: 'Test User',
    );
    return _currentUser;
  }

  @override
  Future<UserModel?> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    // Simulate a successful sign-up
    _currentUser = UserModel(
      id: 'user1',
      email: email,
      username: username,
    );
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    // For development, keep the test user signed in
    _currentUser = UserModel(
      id: 'user1',
      email: 'test@example.com',
      username: 'Test User',
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Always return the test user for development
    return _currentUser;
  }
}
