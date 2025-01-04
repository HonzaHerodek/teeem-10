import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/project_model.dart';
import '../compact_post_card.dart';
import '../compact_project_card.dart';
import '../project/selectable_compact_post_card.dart';
import '../project/project_post_selection_service.dart';

class ProjectContentList extends StatefulWidget {
  final List<String> childProjectIds;
  final List<PostModel> projectPosts;
  final ProjectPostSelectionService service;
  final VoidCallback? onTap;
  final double itemSize;
  final List<ProjectModel> availableProjects;

  const ProjectContentList({
    super.key,
    required this.childProjectIds,
    required this.projectPosts,
    required this.service,
    required this.itemSize,
    required this.availableProjects,
    this.onTap,
  });

  @override
  State<ProjectContentList> createState() => _ProjectContentListState();
}

class _ProjectContentListState extends State<ProjectContentList> {
  late ScrollController _scrollController;
  late ScrollController _availableScrollController;
  final double _horizontalPadding = 16.0;
  final double _itemSpacing = 16.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _availableScrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _availableScrollController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProjectContent() {
    // Filter out any child project IDs that don't exist in available projects
    final validChildProjects = widget.childProjectIds
        .map((id) {
          try {
            return widget.availableProjects.firstWhere((p) => p.id == id);
          } catch (_) {
            return null;
          }
        })
        .where((project) => project != null)
        .cast<ProjectModel>()
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final centerPosition = constraints.maxWidth / 2;
        final itemWidth = widget.itemSize + _itemSpacing;

        // Calculate total width of projects and posts
        final projectsWidth = validChildProjects.length * itemWidth;
        final postsWidth = widget.projectPosts.length * itemWidth;

        // Calculate starting positions to center both sections
        final projectsStart = centerPosition - projectsWidth;
        final postsStart = centerPosition;

        return SizedBox(
          height: widget.itemSize,
          child: Stack(
            children: [
              // Projects section (left side)
              if (validChildProjects.isNotEmpty)
                Positioned(
                  left: projectsStart,
                  child: SizedBox(
                    height: widget.itemSize,
                    child: Row(
                      children: validChildProjects.map((childProject) {
                        return Padding(
                          padding: EdgeInsets.only(right: _itemSpacing),
                          child: CompactProjectCard(
                            project: childProject,
                            postThumbnails: const [],
                            width: widget.itemSize,
                            height: widget.itemSize,
                            onTap: widget.onTap,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              // Posts section (right side)
              if (widget.projectPosts.isNotEmpty)
                Positioned(
                  left: postsStart,
                  child: SizedBox(
                    height: widget.itemSize,
                    child: Row(
                      children: widget.projectPosts.map((post) {
                        return Padding(
                          padding: EdgeInsets.only(right: _itemSpacing),
                          child: widget.service.isSelectionMode
                              ? SelectableCompactPostCard(
                                  post: post,
                                  width: widget.itemSize,
                                  height: widget.itemSize,
                                  isSelected: widget.service.selectedPostIds.contains(post.id),
                                  onToggle: () => widget.service.togglePostSelection(post.id),
                                  isProjectPost: true,
                                )
                              : CompactPostCard(
                                  post: post,
                                  width: widget.itemSize,
                                  height: widget.itemSize,
                                  circular: true,
                                ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvailablePosts() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerPosition = constraints.maxWidth / 2;
        final itemWidth = widget.itemSize + _itemSpacing;
        final totalWidth = widget.service.availablePosts.length * itemWidth;
        final startPosition = centerPosition - (totalWidth / 2);

        return SizedBox(
          height: widget.itemSize,
          child: Stack(
            children: [
              Positioned(
                left: startPosition,
                child: Row(
                  children: widget.service.availablePosts.map((post) {
                    return Padding(
                      padding: EdgeInsets.only(right: _itemSpacing),
                      child: SelectableCompactPostCard(
                        post: post,
                        width: widget.itemSize,
                        height: widget.itemSize,
                        isSelected: widget.service.selectedPostIds.contains(post.id),
                        onToggle: () => widget.service.togglePostSelection(post.id),
                        isProjectPost: false,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.service.isSelectionMode) {
      // In selection mode, show current content in original layout plus available posts
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeader('Project Content'),
          _buildProjectContent(),
          if (widget.service.availablePosts.isNotEmpty) ...[
            _buildSectionHeader('Available Posts'),
            _buildAvailablePosts(),
          ],
        ],
      );
    }

    // Normal mode - show regular project content
    return _buildProjectContent();
  }
}
