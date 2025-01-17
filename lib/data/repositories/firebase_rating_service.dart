// Firebase imports commented out for development
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/rating_service.dart';
import '../../core/services/logger_service.dart';
import '../models/rating_model.dart';

class FirebaseRatingService extends RatingService {
  // Firebase instance commented out for development
  // final FirebaseFirestore _firestore;

  FirebaseRatingService({LoggerService? logger}) : super(logger: logger);

  @override
  Future<void> ratePost(String postId, String userId, double rating) async {
    // Mock implementation
    throw UnimplementedError('Using mock service instead');
  }

  @override
  Future<void> rateUser(String targetUserId, String ratingUserId, double rating) async {
    // Mock implementation
    throw UnimplementedError('Using mock service instead');
  }

  @override
  Future<RatingStats> getPostRatingStats(String postId) async {
    // Mock implementation
    throw UnimplementedError('Using mock service instead');
  }

  @override
  Future<RatingStats> getUserRatingStats(String userId) async {
    // Mock implementation
    throw UnimplementedError('Using mock service instead');
  }
}
