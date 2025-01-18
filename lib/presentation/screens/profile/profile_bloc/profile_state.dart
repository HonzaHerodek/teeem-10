import 'package:flutter/foundation.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/rating_model.dart';

enum ProfileLoadingStage {
  initial,
  userData,
  posts,
  ratings,
  traits,
  complete,
}

@immutable
class ProfileState {
  final bool isLoading;
  final UserModel? user;
  final List<PostModel> userPosts;
  final RatingStats? ratingStats;
  final String? error;
  final ProfileLoadingStage loadingStage;

  const ProfileState({
    this.isLoading = false,
    this.user,
    this.userPosts = const [],
    this.ratingStats,
    this.error,
    this.loadingStage = ProfileLoadingStage.initial,
  });

  bool get hasError => error != null;

  ProfileState copyWith({
    bool? isLoading,
    UserModel? user,
    List<PostModel>? userPosts,
    RatingStats? ratingStats,
    String? error,
    ProfileLoadingStage? loadingStage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      userPosts: userPosts ?? this.userPosts,
      ratingStats: ratingStats ?? this.ratingStats,
      error: error,
      loadingStage: loadingStage ?? this.loadingStage,
    );
  }
}
