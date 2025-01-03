import 'package:flutter/material.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/project_model.dart';
import '../../../widgets/post_creation/in_feed_post_creation.dart';
import '../../../widgets/post_creation/in_feed_post_creation_wrapper.dart';
import '../services/feed_item_service.dart';
import '../controllers/feed_controller.dart';
import 'feed_item.dart';

class FeedContent extends StatefulWidget {
  final ScrollController scrollController;
  final List<PostModel> posts;
  final List<ProjectModel> projects;
  final String currentUserId;
  final bool isCreatingPost;
  final GlobalKey<InFeedPostCreationState> postCreationKey;
  final VoidCallback onCancel;
  final Function(bool, ProjectModel?) onComplete;
  final double topPadding;
  final FeedController feedController;
  final GlobalKey? selectedItemKey;
  final String? selectedPostId;
  final String? selectedProjectId;

  const FeedContent({
    super.key,
    required this.scrollController,
    required this.posts,
    required this.projects,
    required this.currentUserId,
    required this.isCreatingPost,
    required this.postCreationKey,
    required this.onCancel,
    required this.onComplete,
    required this.topPadding,
    required this.feedController,
    this.selectedItemKey,
    this.selectedPostId,
    this.selectedProjectId,
  });

  @override
  State<FeedContent> createState() => _FeedContentState();
}

class _FeedContentState extends State<FeedContent> {
  bool _isScrollingPostCreation = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (_isScrollingPostCreation) {
      // Prevent scroll if it originated from post creation
      widget.scrollController.position.hold(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentService = widget.feedController.itemService;
    if (currentService.posts != widget.posts ||
        currentService.projects != widget.projects ||
        currentService.isCreatingPost != widget.isCreatingPost) {
      widget.feedController.updateItemService(FeedItemService(
        posts: widget.posts,
        projects: widget.projects,
        isCreatingPost: widget.isCreatingPost,
      ));
    }

    final itemService = widget.feedController.itemService;

    if (widget.posts.isEmpty && widget.projects.isEmpty && !widget.isCreatingPost) {
      return _buildEmptyState(context);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // When post creation is active, prevent scroll events from reaching the feed
        if (widget.isCreatingPost) {
          // Check if the scroll started from within the post creation widget
          final postCreationContext = widget.postCreationKey.currentContext;
          if (postCreationContext != null && notification.context != null) {
            final isChildOfPostCreation = notification.context!.findAncestorStateOfType<InFeedPostCreationState>() != null;
            _isScrollingPostCreation = isChildOfPostCreation;
            return isChildOfPostCreation;
          }
        }
        return false;
      },
      child: CustomScrollView(
        controller: widget.scrollController,
        physics: widget.isCreatingPost 
          ? const NeverScrollableScrollPhysics() 
          : const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: widget.topPadding),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == 0) {
                    return InFeedPostCreationWrapper(
                      key: ValueKey(widget.isCreatingPost),
                      postCreationKey: widget.postCreationKey,
                      onCancel: widget.onCancel,
                      onComplete: widget.onComplete,
                      isVisible: widget.isCreatingPost,
                    );
                  }

                  final adjustedIndex = index - 1;

                  final project = itemService.getProjectAtPosition(adjustedIndex);
                  if (project != null) {
                    final isSelected = project.id == widget.selectedProjectId;
                    final key = isSelected && widget.selectedItemKey != null
                        ? widget.selectedItemKey
                        : ValueKey(project.id);
                    return FeedItem(
                      key: key,
                      project: project,
                      feedController: widget.feedController,
                      isSelected: isSelected,
                    );
                  }

                  final post = itemService.getPostAtPosition(adjustedIndex);
                  if (post != null) {
                    final isSelected = post.id == widget.selectedPostId;
                    final key = isSelected && widget.selectedItemKey != null
                        ? widget.selectedItemKey
                        : ValueKey(post.id);
                    return FeedItem(
                      key: key,
                      post: post,
                      currentUserId: widget.currentUserId,
                      feedController: widget.feedController,
                      isSelected: isSelected,
                    );
                  }

                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                },
                childCount: itemService.totalItemCount,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.post_add,
            size: 64,
            color: Colors.white70,
          ),
          const SizedBox(height: 16),
          Text(
            'No content yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to create a post!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}
