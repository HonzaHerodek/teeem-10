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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initializeExpandableContent();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleExpand(bool expanded) {
    setState(() {
      updateExpandedState(expanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: PhysicalModel(
        color: Colors.transparent,
        shadowColor: Colors.grey[850]!,
        elevation: 25,
        shape: BoxShape.circle,
        clipBehavior: Clip.none,
        child: GestureDetector(
          onTap: () => _handleExpand(!isExpanded), // Add tap to expand
          onVerticalDragStart: handleVerticalDragStart,
          onVerticalDragUpdate: (details) => handleVerticalDragUpdate(
            details,
            onExpand: () => _handleExpand(true),
            onCollapse: () => _handleExpand(false),
          ),
          onVerticalDragEnd: handleVerticalDragEnd,
          onVerticalDragCancel: handleVerticalDragCancel,
          behavior: HitTestBehavior.opaque, // Changed from translucent to opaque
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.6),
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedProfilePicture(
                    imageUrl: widget.post.userProfileImage,
                    username: widget.post.username,
                    headerHeight: widget.height,
                    postSize: widget.width,
                    animation: controller,
                    isExpanded: isExpanded,
                    onTap: () => _handleExpand(!isExpanded),
                    showFullScreenWhenExpanded: false,
                  ),
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          // Non-expanded content (title, description)
                          Opacity(
                            opacity: 1.0 - controller.value,
                            child: ExpandablePostContent(
                              isExpanded: false,
                              animation: controller,
                              scrollController: _scrollController,
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
                          // Expanded content
                          Opacity(
                            opacity: controller.value,
                            child: ExpandablePostContent(
                              isExpanded: true,
                              animation: controller,
                              scrollController: _scrollController,
                              post: widget.post,
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
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
