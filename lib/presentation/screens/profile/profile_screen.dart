import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/services/rating_service.dart';
import 'profile_bloc/profile_bloc.dart';
import 'profile_bloc/profile_event.dart';
import 'widgets/profile_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        userRepository: getIt<UserRepository>(),
        postRepository: getIt<PostRepository>(),
        ratingService: getIt<RatingService>(),
      )..add(const ProfileStarted()),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.75),
              Colors.black.withOpacity(0.65),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: const SafeArea(
              child: ProfileView(),
            ),
          ),
        ),
      ),
    );
  }
}
