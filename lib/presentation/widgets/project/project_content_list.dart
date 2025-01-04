import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/project_model.dart';
import '../compact_post_card.dart';
import '../compact_project_card.dart';
import 'selectable_compact_post_card.dart';
import 'selectable_compact_project_card.dart';
import 'project_content_selection_service.dart';

class ProjectContentList extends StatefulWidget {
  final List<String> childProjectIds;
  final List<PostModel> projectPosts;
  final ProjectContentSelectionService service;
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
  late ScrollController _contentController;
  late ScrollController _availableController;
  final double _horizontalPadding = 24.0;
  final double _itemSpacing = 16.0;
  final double _centerSpacing = 32.0;

  @override
  void initState() {
    super.initState();
    _contentController = ScrollController();
    _availableController = ScrollController();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _availableController.dispose();
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

  Widget _buildContentRow({
    required List<Widget> leftContent,
    required List<Widget> rightContent,
    required ScrollController controller,
  }) {
    return SizedBox(
      height: widget.itemSize,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasLeft = leftContent.isNotEmpty;
          final hasRight = rightContent.isNotEmpty;
          
          // Calculate content widths
          final itemWidth = widget.itemSize + _itemSpacing;
          final leftWidth = hasLeft ? leftContent.length * itemWidth : 0.0;
          final rightWidth = hasRight ? rightContent.length * itemWidth : 0.0;
          
          // Calculate initial padding to center the split
          final centerX = constraints.maxWidth / 2;
          final initialPadding = centerX - leftWidth - (_centerSpacing / 2);

          return ListView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              // Initial padding to center the split
              SizedBox(width: initialPadding.clamp(24.0, double.infinity)),
              // Left content (projects)
              if (hasLeft) ...[
                ...leftContent.map((widget) => Padding(
                  padding: EdgeInsets.only(right: _itemSpacing),
                  child: widget,
                )),
              ],
              // Center spacing
              if (hasLeft && hasRight) SizedBox(width: _centerSpacing),
              // Right content (posts)
              if (hasRight) ...[
                ...rightContent.map((widget) => Padding(
                  padding: EdgeInsets.only(right: _itemSpacing),
                  child: widget,
                )),
              ],
              // End padding
              SizedBox(width: _horizontalPadding),
            ],
          );
        },
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

    final projectWidgets = validChildProjects.map((project) => CompactProjectCard(
      project: project,
      postThumbnails: const [],
      width: widget.itemSize,
      height: widget.itemSize,
      onTap: widget.onTap,
    )).toList();

    final postWidgets = widget.projectPosts.map((post) => widget.service.isSelectionMode
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
          )).toList();

    return _buildContentRow(
      leftContent: projectWidgets,
      rightContent: postWidgets,
      controller: _contentController,
    );
  }

  Widget _buildAvailableContent() {
    final availableProjects = widget.service.availableProjects;
    final availablePosts = widget.service.availablePosts;

    final projectWidgets = availableProjects.map((project) => SelectableCompactProjectCard(
      project: project,
      width: widget.itemSize,
      height: widget.itemSize,
      isSelected: widget.service.selectedProjectIds.contains(project.id),
      onToggle: () => widget.service.toggleProjectSelection(project.id),
    )).toList();

    final postWidgets = availablePosts.map((post) => SelectableCompactPostCard(
      post: post,
      width: widget.itemSize,
      height: widget.itemSize,
      isSelected: widget.service.selectedPostIds.contains(post.id),
      onToggle: () => widget.service.togglePostSelection(post.id),
      isProjectPost: false,
    )).toList();

    return _buildContentRow(
      leftContent: projectWidgets,
      rightContent: postWidgets,
      controller: _availableController,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.service.isSelectionMode) {
      final hasAvailableContent = widget.service.availableProjects.isNotEmpty || 
                                widget.service.availablePosts.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeader('Project Content'),
          _buildProjectContent(),
          if (hasAvailableContent) ...[
            _buildSectionHeader('Available Content'),
            _buildAvailableContent(),
          ],
        ],
      );
    }

    // Normal mode - show regular project content
    return _buildProjectContent();
  }
}
