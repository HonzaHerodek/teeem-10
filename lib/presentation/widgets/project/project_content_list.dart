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
  final double _horizontalPadding = 16.0;
  final double _itemSpacing = 16.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    // Only attempt to scroll if there are sub-projects
    if (validChildProjects.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        try {
          final itemWidth = widget.itemSize + _itemSpacing;
          final subProjectsWidth = validChildProjects.length * itemWidth;
          final viewportWidth =
              MediaQuery.of(context).size.width - (_horizontalPadding * 2);

          // Only scroll if we have enough content to make it meaningful
          if (subProjectsWidth > viewportWidth / 2 &&
              _scrollController.hasClients) {
            final targetOffset = (subProjectsWidth - viewportWidth / 2)
                .clamp(0.0, subProjectsWidth);
            _scrollController.jumpTo(targetOffset);
          }
        } catch (_) {
          // Ignore any scroll errors
        }
      });
    }

    return SizedBox(
      height: widget.itemSize,
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
        children: [
          // Sub-projects
          if (validChildProjects.isNotEmpty)
            ...validChildProjects.map((childProject) {
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
            }),
          // Project posts
          if (widget.projectPosts.isNotEmpty)
            ...widget.projectPosts.map((post) {
              return Padding(
                padding: EdgeInsets.only(right: _itemSpacing),
                child: widget.service.isSelectionMode
                    ? SelectableCompactPostCard(
                        post: post,
                        width: widget.itemSize,
                        height: widget.itemSize,
                        isSelected:
                            widget.service.selectedPostIds.contains(post.id),
                        onToggle: () =>
                            widget.service.togglePostSelection(post.id),
                        isProjectPost: true,
                      )
                    : CompactPostCard(
                        post: post,
                        width: widget.itemSize,
                        height: widget.itemSize,
                        circular: true,
                      ),
              );
            }),
        ],
      ),
    );
  }
}
