import 'package:flutter/material.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/project_model.dart';
import '../../../widgets/post_card.dart';
import '../../../widgets/project_card.dart';
import '../../../widgets/post_creation/in_feed_post_creation.dart';
import '../../../widgets/post_creation/in_feed_post_creation_wrapper.dart';
import '../controllers/feed_controller.dart';

class FeedItem extends StatelessWidget {
  final PostModel? post;
  final ProjectModel? project;
  final String? currentUserId;
  final bool isCreatingPost;
  final GlobalKey<InFeedPostCreationState>? postCreationKey;
  final VoidCallback? onCancel;
  final Function(bool, ProjectModel?)? onComplete;
  final FeedController feedController;
  final bool isSelected;

  const FeedItem({
    super.key,
    this.post,
    this.project,
    this.currentUserId,
    this.isCreatingPost = false,
    this.postCreationKey,
    this.onCancel,
    this.onComplete,
    required this.feedController,
    this.isSelected = false,
  }) : assert(
          post != null || project != null || isCreatingPost,
          'Either post, project, or isCreatingPost must be provided',
        );

  @override
  Widget build(BuildContext context) {
    if (isCreatingPost) {
      return InFeedPostCreationWrapper(
        postCreationKey: postCreationKey,
        onCancel: onCancel ?? () {},
        onComplete: (success, project) {
          if (success && project != null) {
            feedController.addPostToProject(
              projectId: project.id,
              postId: post?.id ?? '',
            );
          }
          onComplete?.call(success, project);
        },
        isVisible: isCreatingPost,
      );
    }

    if (project != null) {
      return RepaintBoundary(
        child: Container(
          key: key,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(
              color: Colors.blue.withOpacity(0.5),
              width: 2,
            ) : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ProjectCard(
              project: project!,
              onTap: () => feedController.selectProject(project!.id),
            ),
          ),
        ),
      );
    }

    if (post != null && currentUserId != null) {
      return RepaintBoundary(
        child: Container(
          key: key,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(
              color: Colors.blue.withOpacity(0.5),
              width: 2,
            ) : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PostCard(
              post: post!,
              currentUserId: currentUserId!,
              onLike: () => feedController.likePost(post!.id),
              onComment: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comments coming soon!')),
                );
              },
              onShare: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon!')),
                );
              },
              onRate: (rating) => feedController.ratePost(post!.id, rating),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
