import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/project_model.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../screens/feed/feed_bloc/feed_bloc.dart';
import '../../screens/feed/feed_bloc/feed_state.dart';
import 'selectable_compact_post_card.dart';
import 'selectable_compact_project_card.dart';
import 'project_post_selection_service.dart';

class ProjectContent extends StatelessWidget {
  final String projectId;
  final String name;
  final String description;
  final List<PostModel> posts;
  final List<PostModel> availablePosts;
  final bool isLoading;
  final String errorMessage;

  const ProjectContent({
    super.key,
    required this.projectId,
    required this.name,
    required this.description,
    required this.posts,
    required this.availablePosts,
    required this.isLoading,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProjectPostSelectionService(
        postRepository: context.read<PostRepository>(),
        projectId: projectId,
        projectName: name,
        initialPostIds: posts.map((p) => p.id).toList(),
      ),
      child: BlocConsumer<FeedBloc, FeedState>(
        listenWhen: (previous, current) {
          if (previous is! FeedSuccess || current is! FeedSuccess) {
            return false;
          }

          // Get current project from both states
          final prevProject = previous.projects.firstWhere(
            (p) => p.id == projectId,
            orElse: () => ProjectModel(
              id: projectId,
              name: name,
              description: description,
              creatorId: '',
              postIds: const [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          final currentProject = current.projects.firstWhere(
            (p) => p.id == projectId,
            orElse: () => ProjectModel(
              id: projectId,
              name: name,
              description: description,
              creatorId: '',
              postIds: const [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          // Listen for changes in:
          // 1. Current project's childrenIds
          if (prevProject.childrenIds != currentProject.childrenIds) {
            return true;
          }

          // 2. Any project's parentId
          for (final project in current.projects) {
            final prevProject = previous.projects.firstWhere(
              (p) => p.id == project.id,
              orElse: () => project,
            );
            if (project.parentId != prevProject.parentId) {
              return true;
            }
          }

          return false;
        },
        listener: (context, state) {
          if (state is FeedSuccess) {
            // Update service state when projects change
            final service = context.read<ProjectPostSelectionService>();
            service.updateSubProjects(state.projects);

            // Get current project to update posts
            final currentProject = state.projects.firstWhere(
              (p) => p.id == projectId,
              orElse: () => ProjectModel(
                id: projectId,
                name: name,
                description: description,
                creatorId: '',
                postIds: const [],
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
            service.updatePostIds(currentProject.postIds);
          }
        },
        builder: (context, state) {
          if (state is! FeedSuccess) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          // Get current project's posts from state
          final currentProject = state.projects.firstWhere(
            (p) => p.id == projectId,
            orElse: () => ProjectModel(
              id: projectId,
              name: name,
              description: description,
              creatorId: '',
              postIds: const [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          // Get available posts (posts not in current project)
          final currentPosts = state.posts
              .where((post) => currentProject.postIds.contains(post.id))
              .toList();
          final availablePosts = state.posts
              .where((post) => !currentProject.postIds.contains(post.id))
              .toList();

          return _ProjectContentBody(
            name: name,
            description: description,
            posts: currentPosts,
            availablePosts: availablePosts,
            isLoading: isLoading,
            errorMessage: errorMessage,
            currentProject: currentProject,
          );
        },
      ),
    );
  }
}

class _ProjectContentBody extends StatelessWidget {
  final String name;
  final String description;
  final List<PostModel> posts;
  final List<PostModel> availablePosts;
  final bool isLoading;
  final String errorMessage;

  final ProjectModel currentProject;

  const _ProjectContentBody({
    required this.name,
    required this.description,
    required this.posts,
    required this.availablePosts,
    required this.isLoading,
    required this.errorMessage,
    required this.currentProject,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Consumer<ProjectPostSelectionService>(
                    builder: (context, service, child) {
                      if (service.isSelectionMode) {
                        return Row(
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.white),
                              onPressed: () =>
                                  service.handleSelectionConfirmed(context),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () => service.exitSelectionMode(),
                            ),
                          ],
                        );
                      } else {
                        return IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            if (context.mounted) {
                              final state = context.read<FeedBloc>().state;
                              if (state is FeedSuccess) {
                                service.enterSelectionMode(
                                    availablePosts, state.projects);
                              }
                            }
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _buildContent(context),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          errorMessage,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
      );
    }

    return Consumer<ProjectPostSelectionService>(
      builder: (context, service, child) {
        final itemSize = 140.0;

        // Create lists with proper typing
        final List<_ProjectItem> projectItems = [];
        // Add posts from service
        for (final post in service.projectPosts) {
          projectItems.add(_ProjectItem(post: post));
        }
        // Add current sub-projects from service
        for (final project in service.currentSubProjects) {
          projectItems.add(_ProjectItem(project: project));
        }

        final List<_ProjectItem> availableItems = [];
        if (service.isSelectionMode) {
          // Add available posts
          for (final post in service.availablePosts) {
            availableItems.add(_ProjectItem(post: post));
          }
          // Add available projects from service
          for (final project in service.availableProjects) {
            availableItems.add(_ProjectItem(project: project));
          }
        }

        if (projectItems.isEmpty && !service.isSelectionMode) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'No items in this project',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project items row
            Padding(
              padding: const EdgeInsets.only(left: 24.0, bottom: 8.0),
              child: Text(
                'Project items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            SizedBox(
              height: itemSize,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: projectItems.length,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final item = projectItems[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 24.0 : 16.0,
                      right: index == projectItems.length - 1 ? 24.0 : 0.0,
                    ),
                    child: item.post != null
                        ? SelectableCompactPostCard(
                            post: item.post!,
                            isSelected:
                                service.selectedPostIds.contains(item.post!.id),
                            onToggle: () =>
                                service.togglePostSelection(item.post!.id),
                            isProjectPost: true,
                            width: itemSize,
                            height: itemSize,
                          )
                        : SelectableCompactProjectCard(
                            project: item.project!,
                            postThumbnails: const [], // TODO: Add thumbnails
                            isSelected: service.selectedProjectIds
                                .contains(item.project!.id),
                            onToggle: () => service
                                .toggleProjectSelection(item.project!.id),
                            isProjectPost: true,
                            width: itemSize,
                            height: itemSize,
                          ),
                  );
                },
              ),
            ),

            // Available items row (only in selection mode)
            if (service.isSelectionMode && availableItems.isNotEmpty) ...[
              const SizedBox(height: 24.0),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, bottom: 8.0),
                child: Text(
                  'Available items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              SizedBox(
                height: itemSize,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableItems.length,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final item = availableItems[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 24.0 : 16.0,
                        right: index == availableItems.length - 1 ? 24.0 : 0.0,
                      ),
                      child: item.post != null
                          ? SelectableCompactPostCard(
                              post: item.post!,
                              isSelected: service.selectedPostIds
                                  .contains(item.post!.id),
                              onToggle: () =>
                                  service.togglePostSelection(item.post!.id),
                              isProjectPost: false,
                              width: itemSize,
                              height: itemSize,
                            )
                          : SelectableCompactProjectCard(
                              project: item.project!,
                              postThumbnails: const [], // TODO: Add thumbnails
                              isSelected: service.selectedProjectIds
                                  .contains(item.project!.id),
                              onToggle: () => service
                                  .toggleProjectSelection(item.project!.id),
                              isProjectPost: false,
                              width: itemSize,
                              height: itemSize,
                            ),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// Helper class to combine posts and projects in a single list
class _ProjectItem {
  final PostModel? post;
  final ProjectModel? project;

  _ProjectItem({this.post, this.project})
      : assert(post != null || project != null);
}
