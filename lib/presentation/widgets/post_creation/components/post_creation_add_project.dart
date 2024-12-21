import 'package:flutter/material.dart';
import '../../../../data/models/project_model.dart';
import '../in_feed_post_creation.dart';
import '../../../../presentation/widgets/common/glass_container.dart';
import './search_close_icon.dart';

class PostCreationAddProject extends StatefulWidget {
  final InFeedPostCreation postCreation;
  final ProjectModel project;
  final VoidCallback onRemoveProject;

  const PostCreationAddProject({
    super.key,
    required this.postCreation,
    required this.project,
    required this.onRemoveProject,
  });

  @override
  State<PostCreationAddProject> createState() => _PostCreationAddProjectState();
}

class _PostCreationAddProjectState extends State<PostCreationAddProject> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
      }
    });
  }

  Widget _buildProjectFrame(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GlassContainer.newlyCreated(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: child,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final searchBarWidth = constraints.maxWidth * 0.35; // 35% of available width
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cancel button
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.onRemoveProject,
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              alignment: Alignment.center,
                              children: const [
                                Icon(
                                  Icons.crop_square_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32), // Increased spacing
                      if (_isSearchExpanded)
                        // Search bar with custom close icon
                        Container(
                          width: searchBarWidth,
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: TextField(
                                    controller: _searchController,
                                    focusNode: _searchFocusNode,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Search projects...',
                                      hintStyle: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _toggleSearch,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(14),
                                    bottomRight: Radius.circular(14),
                                  ),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: const SearchCloseIconWidget(size: 24),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        // Search button
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _toggleSearch,
                              borderRadius: BorderRadius.circular(14),
                              child: const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      // Project chip
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            widget.project.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildProjectFrame(widget.postCreation);
  }
}
