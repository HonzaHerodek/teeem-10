import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../profile_bloc/profile_bloc.dart';
import '../profile_bloc/profile_event.dart';
import '../profile_bloc/profile_state.dart';
import '../../../widgets/profile_posts_grid.dart';

class ProfilePostsSection extends StatelessWidget {
  final ProfileState state;

  const ProfilePostsSection({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state.user == null || state.userPosts.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'No posts yet',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          ProfilePostsGrid(
            posts: state.userPosts,
            currentUserId: state.user!.id,
            onLike: (post) {},
            onComment: (post) {},
            onShare: (post) {},
            onRate: (rating, post) {
              context.read<ProfileBloc>().add(
                    ProfileRatingReceived(
                      rating,
                      state.user!.id,
                      userId: state.user!.id,
                    ),
                  );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
