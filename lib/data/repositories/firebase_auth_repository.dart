// Firebase imports commented out for development
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  // Firebase instances commented out for development
  // final FirebaseAuth _auth;
  // final FirebaseFirestore _firestore;

  FirebaseAuthRepository();

  @override
  Future<UserModel?> getCurrentUser() async {
    // Using mock data for development
    return null;
  }

  @override
  Future<void> signOut() async {
    // Mock implementation
    return;
  }

  @override
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    // Mock implementation
    throw UnimplementedError('Using mock repository instead');
  }

  @override
  Future<UserModel?> signUpWithEmailAndPassword(String email, String password, String username) async {
    // Mock implementation
    throw UnimplementedError('Using mock repository instead');
  }
}
