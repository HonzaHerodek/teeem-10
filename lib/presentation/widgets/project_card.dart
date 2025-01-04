import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../core/di/injection.dart';
import '../../data/models/post_model.dart';
import '../../data/models/project_model.dart';
import '../../domain/repositories/post_repository.dart';
import '../../presentation/screens/feed/feed_bloc/feed_bloc.dart';
import '../../presentation/screens/feed/feed_bloc/feed_event.dart';
import '../../presentation/screens/feed/feed_bloc/feed_state.dart';
import 'common/glass_container.dart';
import 'common/section_header.dart';
import 'compact_post_card.dart';
import 'compact_project_card.dart';
import 'project/selectable_compact_post_card.dart';
import 'project/project_post_selection_service.dart';
import 'project/square_action_button.dart';
import 'project/project_content_list.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final String? currentUserId;
  final VoidCallback? onTap;
  final double elevation;
  static const double _postSize = 140.0;
  static const Duration _animationDuration = Duration(milliseconds: 300);
  static const Curve _animationCurve = Curves.easeInOut;

  const ProjectCard({
    super.key,
    required this.project,
    this.currentUserId,
    this.onTap,
    this.elevation = 0,
  });

  Widget _buildPostList(List<PostModel> posts, bool isSelectable,
      ProjectPostSelectionService service,
      {bool isProjectPosts = false}) {
    if (posts.isEmpty) return const SizedBox.shrink();

    return AnimatedOpacity(
      duration: _animationDuration,
      curve: _animationCurve,
      opacity: 1.0,
      child: SizedBox(
        height: _postSize,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: posts.length,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final post = posts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: isSelectable
                  ? SelectableCompactPostCard(
                      post: post,
                      width: _postSize,
                      height: _postSize,
                      isSelected: service.selectedPostIds.contains(post.id),
                      onToggle: () => service.togglePostSelection(post.id),
                      isProjectPost: isProjectPosts,
                    )
                  : CompactPostCard(
                      post: post,
                      width: _postSize,
                      height: _postSize,
                      circular: true,
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, ProjectPostSelectionService service) {
    if (service.isSelectionMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SquareActionButton(
            icon: Icons.add_circle_outline,
            onPressed: () {
              // TODO: Implement add post action
            },
            size: 40,
          ),
          const SizedBox(width: 40), // Increased from 32 to 40
          SquareActionButton(
            icon: Icons.add_box_outlined,
            onPressed: () {
              // TODO: Implement add sub-project action
            },
            size: 40,
          ),
        ],
      );
    } else {
      return _buildLikeButton(context);
    }
  }

  Widget _buildLikeButton(BuildContext context) {
    final isLiked =
        currentUserId != null && project.likes.contains(currentUserId);

    return IconButton(
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.white,
        size: 32,
      ),
      onPressed: () {
        if (currentUserId == null) return;

        if (isLiked) {
          context.read<FeedBloc>().add(FeedProjectUnliked(project.id));
        } else {
          context.read<FeedBloc>().add(FeedProjectLiked(project.id));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectPostSelectionService(
        postRepository: getIt<PostRepository>(),
        projectId: project.id,
        projectName: project.name,
        initialPostIds: project.postIds,
      ),
      child: BlocConsumer<FeedBloc, FeedState>(
        listenWhen: (previous, current) {
          if (previous is FeedSuccess && current is FeedSuccess) {
            final prevProject = previous.projects.firstWhere(
              (p) => p.id == project.id,
              orElse: () => project,
            );
            final currentProject = current.projects.firstWhere(
              (p) => p.id == project.id,
              orElse: () => project,
            );
            return prevProject.postIds != currentProject.postIds;
          }
          return false;
        },
        listener: (context, state) {
          if (state is FeedSuccess) {
            final updatedProject = state.projects.firstWhere(
              (p) => p.id == project.id,
              orElse: () => project,
            );
            if (updatedProject.postIds != project.postIds) {
              context
                  .read<ProjectPostSelectionService>()
                  .updatePostIds(updatedProject.postIds);
            }
          }
        },
        builder: (context, state) {
          return Consumer<ProjectPostSelectionService>(
            builder: (context, service, _) {
              return Transform.translate(
                offset: Offset(0, -elevation),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: service.isSelectionMode ? null : onTap,
                        behavior: HitTestBehavior.opaque,
                        child: GlassContainer(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    24.0, 20.0, 24.0, 0.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        project.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    SquareActionButton(
                                      icon: service.isSelectionMode
                                          ? Icons.check
                                          : Icons.settings,
                                      onPressed: () {
                                        if (service.isSelectionMode) {
                                          service.handlePostsAdded(context);
                                        } else if (state is FeedSuccess) {
                                          service
                                              .enterSelectionMode(state.posts);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Unable to edit posts at this time'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      size: 40,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    24.0, 8.0, 24.0, 16.0),
                                child: Text(
                                  project.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (service.isLoading)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                )
                              else if (service.errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0),
                                  child: Text(
                                    service.errorMessage,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                  ),
                                )
                              else ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    ProjectContentList(
                                      childProjectIds: project.childProjectIds,
                                      projectPosts: service.projectPosts,
                                      service: service,
                                      itemSize: _postSize,
                                      availableProjects: state is FeedSuccess ? state.projects : const [],
                                      onTap: onTap,
                                    ),
                                  ],
                                ),
                              ],
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 16.0, bottom: 8.0),
                                child: Center(
                                    child:
                                        _buildActionButtons(context, service)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
