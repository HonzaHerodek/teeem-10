import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../data/models/post_model.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../screens/feed/feed_bloc/feed_bloc.dart';
import '../../screens/feed/feed_bloc/feed_state.dart';
import 'selectable_compact_post_card.dart';
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
      child: _ProjectContentBody(
        name: name,
        description: description,
        posts: posts,
        availablePosts: availablePosts,
        isLoading: isLoading,
        errorMessage: errorMessage,
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

  const _ProjectContentBody({
    required this.name,
    required this.description,
    required this.posts,
    required this.availablePosts,
    required this.isLoading,
    required this.errorMessage,
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
                              icon: const Icon(Icons.check, color: Colors.white),
                              onPressed: () => service.handlePostsAdded(context),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
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
                                service.enterSelectionMode(availablePosts, state.projects);
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
        final displayPosts = service.isSelectionMode
            ? [...posts, ...availablePosts]
            : posts;

        if (displayPosts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'No posts in this project',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
          );
        }

        final postSize = 140.0;
        
        return SizedBox(
          height: postSize,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayPosts.length,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final post = displayPosts[index];
              final isProjectPost = posts.contains(post);
              
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 24.0 : 16.0,
                  right: index == displayPosts.length - 1 ? 24.0 : 0.0,
                ),
                child: SelectableCompactPostCard(
                  post: post,
                  isSelected: service.selectedPostIds.contains(post.id),
                  onToggle: () => service.togglePostSelection(post.id),
                  isProjectPost: isProjectPost,
                  width: postSize,
                  height: postSize,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
