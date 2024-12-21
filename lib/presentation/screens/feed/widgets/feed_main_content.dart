import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../data/models/project_model.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/post_creation/in_feed_post_creation.dart';
import '../feed_bloc/feed_bloc.dart';
import '../feed_bloc/feed_event.dart';
import '../feed_bloc/feed_state.dart';
import '../services/feed_item_service.dart';
import '../controllers/feed_controller.dart';
import 'feed_content.dart';

class FeedMainContent extends StatelessWidget {
  final ScrollController scrollController;
  final FeedController feedController;
  final bool isCreatingPost;
  final GlobalKey<InFeedPostCreationState> postCreationKey;
  final VoidCallback onCancel;
  final Function(bool, ProjectModel?) onComplete;
  final double topPadding;
  final GlobalKey? selectedItemKey;
  final NotificationModel? selectedNotification;

  const FeedMainContent({
    super.key,
    required this.scrollController,
    required this.feedController,
    required this.isCreatingPost,
    required this.postCreationKey,
    required this.onCancel,
    required this.onComplete,
    required this.topPadding,
    this.selectedItemKey,
    this.selectedNotification,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        if (state is FeedInitial || state is FeedLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (state is FeedFailure) {
          return ErrorView(
            message: state.error,
            onRetry: () {
              context.read<FeedBloc>().add(const FeedStarted());
            },
          );
        }

        if (state is FeedSuccess) {
          return KeyedSubtree(
            key: ValueKey(selectedNotification?.id),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: FeedContent(
                scrollController: scrollController,
                posts: state.posts,
                projects: state.projects,
                currentUserId: state.currentUserId,
                isCreatingPost: isCreatingPost,
                postCreationKey: postCreationKey,
                onCancel: onCancel,
                onComplete: onComplete,
                topPadding: topPadding,
                feedController: feedController,
                selectedItemKey: selectedItemKey,
                selectedPostId: selectedNotification?.type == NotificationType.post
                    ? selectedNotification?.postId
                    : null,
                selectedProjectId: selectedNotification?.type == NotificationType.project
                    ? selectedNotification?.projectId
                    : null,
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
