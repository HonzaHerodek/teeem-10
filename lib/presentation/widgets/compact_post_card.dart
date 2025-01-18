import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import 'common/animated_profile_picture.dart';
import 'common/expandable_post_content.dart';
import 'mixins/expandable_content_mixin.dart';

class CompactPostCard extends StatefulWidget {
  final PostModel post;
  final double width;
  final double height;
  final bool circular;
  final bool showHeartButton;
  final VoidCallback? onUnsave;

  const CompactPostCard({
    super.key,
    required this.post,
    this.width = 120,
    this.height = 120,
    this.circular = true,
    this.showHeartButton = false,
    this.onUnsave,
  });

  @override
  State<CompactPostCard> createState() => _CompactPostCardState();
}

class _CompactPostCardState extends State<CompactPostCard>
    with TickerProviderStateMixin, ExpandableContentMixin {
  // Use a single ScrollController for all instances
  static final ScrollController _sharedScrollController = ScrollController();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    initializeExpandableContent();
  }

  void _handleExpand(bool expanded) {
    if (!mounted) return;
    setState(() {
      _isExpanded = expanded;
      updateExpandedState(expanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.6),
              // Use box shadow instead of PhysicalModel for better performance
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[850]!.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: GestureDetector(
                onTap: () => _handleExpand(!_isExpanded),
                onVerticalDragStart: handleVerticalDragStart,
                onVerticalDragUpdate: (details) => handleVerticalDragUpdate(
                  details,
                  onExpand: () => _handleExpand(true),
                  onCollapse: () => _handleExpand(false),
                ),
                onVerticalDragEnd: handleVerticalDragEnd,
                onVerticalDragCancel: handleVerticalDragCancel,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Profile picture
                    AnimatedProfilePicture(
                      imageUrl: widget.post.userProfileImage,
                      username: widget.post.username,
                      headerHeight: widget.height,
                      postSize: widget.width,
                      animation: controller,
                      isExpanded: _isExpanded,
                      onTap: () => _handleExpand(!_isExpanded),
                      showFullScreenWhenExpanded: false,
                    ),
                    // Content
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isExpanded
                          ? ExpandablePostContent(
                              key: const ValueKey('expanded'),
                              isExpanded: true,
                              animation: controller,
                              scrollController: _sharedScrollController,
                              post: widget.post,
                              title: widget.post.title,
                              description: widget.post.description,
                              rating: widget.post.ratingStats.averageRating,
                              totalRatings: widget.post.ratings.length,
                              steps: widget.post.steps,
                              showHeartButton: widget.showHeartButton,
                              onUnsave: widget.onUnsave,
                              width: widget.width,
                            )
                          : ExpandablePostContent(
                              key: const ValueKey('collapsed'),
                              isExpanded: false,
                              animation: controller,
                              scrollController: _sharedScrollController,
                              title: widget.post.title,
                              description: widget.post.description,
                              rating: widget.post.ratingStats.averageRating,
                              totalRatings: widget.post.ratings.length,
                              steps: widget.post.steps,
                              showHeartButton: widget.showHeartButton,
                              onUnsave: widget.onUnsave,
                              width: widget.width,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
