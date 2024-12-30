import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/post_model.dart';
import '../screens/profile/profile_bloc/profile_bloc.dart';
import '../screens/profile/profile_bloc/profile_event.dart';
import 'compact_post_card.dart';

class PostRowHeader extends StatelessWidget {
  final String title;
  final IconData? backgroundIcon;

  const PostRowHeader({
    super.key,
    required this.title,
    this.backgroundIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w100,
                letterSpacing: 1.2,
                height: 1.2,
              ),
            ),
          ),
          if (backgroundIcon != null)
            Positioned(
              left: 24 + title.length * 20 + 8,
              top: 24,
              child: SizedBox(
                width: 72,
                height: 72,
                child: Icon(
                  backgroundIcon!,
                  size: 72,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProfilePostsGrid extends StatefulWidget {
  final List<PostModel> posts;
  final String currentUserId;
  final Function(PostModel) onLike;
  final Function(PostModel) onComment;
  final Function(PostModel) onShare;
  final Function(double, PostModel) onRate;

  const ProfilePostsGrid({
    super.key,
    required this.posts,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onRate,
  });

  @override
  State<ProfilePostsGrid> createState() => _ProfilePostsGridState();
}

class _ProfilePostsGridState extends State<ProfilePostsGrid> {
  final List<ScrollController> _scrollControllers = [];
  static const int _numberOfRows = 4; // Saved, Unfinished, Created, Completed

  @override
  void initState() {
    super.initState();
    // Create a controller for each horizontal list
    for (int i = 0; i < _numberOfRows; i++) {
      _scrollControllers.add(ScrollController());
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildPostRow(
    BuildContext context, {
    required String title,
    required List<PostModel> posts,
    required int index,
    IconData? backgroundIcon,
    bool showHeartButton = false,
  }) {
    const double postSize = 140.0;
    const double rowHeight = 140.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostRowHeader(
          title: title,
          backgroundIcon: backgroundIcon,
        ),
        SizedBox(
          height: rowHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            controller: _scrollControllers[index],
            physics: const ClampingScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CompactPostCard(
                  post: post,
                  width: postSize,
                  height: postSize,
                  circular: true,
                  showHeartButton: showHeartButton,
                  onUnsave: showHeartButton
                      ? () {
                          context
                              .read<ProfileBloc>()
                              .add(ProfilePostUnsaved(post.id));
                        }
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedPosts = widget.posts.take(3).toList();
    final unfinishedPosts = widget.posts.skip(3).take(3).toList();
    final createdPosts = widget.posts.skip(1).take(3).toList();
    final completedPosts = widget.posts.skip(2).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPostRow(
          context,
          title: 'Saved',
          posts: savedPosts,
          index: 0,
          backgroundIcon: Icons.favorite_rounded,
          showHeartButton: true,
        ),
        const SizedBox(height: 24),
        _buildPostRow(
          context,
          title: 'Unfinished',
          posts: unfinishedPosts,
          index: 1,
          backgroundIcon: Icons.pending_rounded,
        ),
        const SizedBox(height: 24),
        _buildPostRow(
          context,
          title: 'Created',
          posts: createdPosts,
          index: 2,
          backgroundIcon: Icons.add_circle_rounded,
        ),
        const SizedBox(height: 24),
        _buildPostRow(
          context,
          title: 'Completed',
          posts: completedPosts,
          index: 3,
          backgroundIcon: Icons.check_circle_rounded,
        ),
      ],
    );
  }
}
