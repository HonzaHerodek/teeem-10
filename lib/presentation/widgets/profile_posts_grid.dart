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

class ProfilePostsGrid extends StatelessWidget {
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

  Widget _buildPostRow(
    BuildContext context, {
    required String title,
    required List<PostModel> posts,
    IconData? backgroundIcon,
    bool showHeartButton = false,
  }) {
    if (posts.isEmpty) return const SizedBox.shrink();

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
          child: NotificationListener<ScrollNotification>(
            // Prevent horizontal scroll events from bubbling up
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                return true; // Stop notification propagation
              }
              return false;
            },
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                // Lazy load posts as they come into view
                if (index >= posts.length) {
                  return const SizedBox(width: postSize);
                }

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
        ),
      ],
    );
  }

  List<PostModel> _getPostsForSection(String section) {
    final int pageSize = 5; // Limit number of posts per section

    switch (section) {
      case 'active':
        return posts
            .where((post) => post.status == PostStatus.active)
            .take(pageSize)
            .toList();
      case 'draft':
        return posts
            .where((post) => post.status == PostStatus.draft)
            .take(pageSize)
            .toList();
      case 'created':
        return posts
            .where((post) => post.userId == currentUserId)
            .take(pageSize)
            .toList();
      case 'published':
        return posts
            .where((post) => post.status == PostStatus.published)
            .take(pageSize)
            .toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lazy load sections only when they have posts
    final sections = [
      {
        'title': 'Active',
        'posts': _getPostsForSection('active'),
        'icon': Icons.play_circle_rounded,
        'showHeart': false,
      },
      {
        'title': 'Drafts',
        'posts': _getPostsForSection('draft'),
        'icon': Icons.pending_rounded,
        'showHeart': false,
      },
      {
        'title': 'Created',
        'posts': _getPostsForSection('created'),
        'icon': Icons.add_circle_rounded,
        'showHeart': false,
      },
      {
        'title': 'Published',
        'posts': _getPostsForSection('published'),
        'icon': Icons.check_circle_rounded,
        'showHeart': false,
      },
    ].where((section) => (section['posts'] as List).isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) {
        return Column(
          children: [
            _buildPostRow(
              context,
              title: section['title'] as String,
              posts: section['posts'] as List<PostModel>,
              backgroundIcon: section['icon'] as IconData,
              showHeartButton: section['showHeart'] as bool,
            ),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }
}
