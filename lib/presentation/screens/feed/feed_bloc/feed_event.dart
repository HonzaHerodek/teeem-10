import 'package:myapp/data/models/project_model.dart';

abstract class FeedEvent {
  const FeedEvent();
}

class FeedStarted extends FeedEvent {
  const FeedStarted();
}

class FeedRefreshed extends FeedEvent {
  const FeedRefreshed();
}

class FeedLoadMore extends FeedEvent {
  const FeedLoadMore();
}

class FeedPostLiked extends FeedEvent {
  final String postId;
  const FeedPostLiked(this.postId);
}

class FeedPostUnliked extends FeedEvent {
  final String postId;
  const FeedPostUnliked(this.postId);
}

class FeedPostRated extends FeedEvent {
  final String postId;
  final double rating;
  const FeedPostRated(this.postId, this.rating);
}

class FeedPostDeleted extends FeedEvent {
  final String postId;
  const FeedPostDeleted(this.postId);
}

class FeedPostHidden extends FeedEvent {
  final String postId;
  const FeedPostHidden(this.postId);
}

class FeedPostSaved extends FeedEvent {
  final String postId;
  const FeedPostSaved(this.postId);
}

class FeedPostUnsaved extends FeedEvent {
  final String postId;
  const FeedPostUnsaved(this.postId);
}

class FeedPostReported extends FeedEvent {
  final String postId;
  final String reason;
  const FeedPostReported(this.postId, this.reason);
}

class FeedProjectSelected extends FeedEvent {
  final String projectId;
  const FeedProjectSelected(this.projectId);
}

class FeedProjectLiked extends FeedEvent {
  final String projectId;
  const FeedProjectLiked(this.projectId);
}

class FeedProjectUnliked extends FeedEvent {
  final String projectId;
  const FeedProjectUnliked(this.projectId);
}

class FeedPostAddedToProject extends FeedEvent {
  final String projectId;
  final String postId;
  const FeedPostAddedToProject({required this.projectId, required this.postId});
}

class FeedRemovePostFromProject extends FeedEvent {
  final String projectId;
  final String postId;
  const FeedRemovePostFromProject({required this.projectId, required this.postId});
}

class FeedBatchAddPostsToProject extends FeedEvent {
  final String projectId;
  final List<String> postIds;
  const FeedBatchAddPostsToProject({required this.projectId, required this.postIds});
}

class FeedBatchRemovePostsFromProject extends FeedEvent {
  final String projectId;
  final List<String> postIds;
  const FeedBatchRemovePostsFromProject({required this.projectId, required this.postIds});
}

class FeedBatchOperations extends FeedEvent {
  final String projectId;
  final List<String> postsToRemove;
  final List<String> postsToAdd;
  const FeedBatchOperations({
    required this.projectId,
    required this.postsToRemove,
    required this.postsToAdd,
  });
}

class FeedSubProjectCreated extends FeedEvent {
  final String parentId;
  final ProjectModel project;
  const FeedSubProjectCreated({
    required this.parentId,
    required this.project,
  });
}

class FeedFilterChanged extends FeedEvent {
  final String filterType;
  final String filter;
  const FeedFilterChanged({required this.filterType, required this.filter});
}

class FeedSearchChanged extends FeedEvent {
  final String query;
  const FeedSearchChanged(this.query);
}
