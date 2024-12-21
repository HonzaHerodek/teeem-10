import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import '../../data/models/post_model.dart';
import '../../data/models/traits/trait_type_model.dart';
import '../../data/models/traits/user_trait_model.dart';
import '../../domain/repositories/post_repository.dart';
import '../../core/di/injection.dart';
import 'common/animated_profile_picture.dart';
import 'common/other_posts_list.dart';
import 'mixins/expandable_content_mixin.dart';
import 'rating_stars.dart';
import 'rating_count_star.dart';
import 'user_traits/user_trait_chip.dart';

class PostHeader extends StatefulWidget {
  final String username;
  final String? userProfileImage;
  final List<PostStep> steps;
  final int currentStep;
  final bool isExpanded;
  final Function(bool) onExpandChanged;
  final String userId;
  final String currentPostId;
  final Function(double)? onAnimationChanged;
  final List<TraitTypeModel> traitTypes;
  final List<UserTraitModel> userTraits;
  final double rating;

  const PostHeader({
    super.key,
    required this.username,
    this.userProfileImage,
    required this.steps,
    required this.currentStep,
    required this.isExpanded,
    required this.onExpandChanged,
    required this.userId,
    required this.currentPostId,
    this.onAnimationChanged,
    required this.traitTypes,
    this.userTraits = const [],
    required this.rating,
  });

  @override
  State<PostHeader> createState() => _PostHeaderState();
}

class _PostHeaderState extends State<PostHeader>
    with TickerProviderStateMixin, ExpandableContentMixin {
  List<PostModel>? _otherPosts;
  bool _isLoadingPosts = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initializeExpandableContent(
      startExpanded: widget.isExpanded,
      onAnimationChanged: widget.onAnimationChanged,
    );

    if (widget.isExpanded) {
      _fetchOtherPosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PostHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      updateExpandedState(widget.isExpanded);
      if (widget.isExpanded) {
        _fetchOtherPosts();
      }
    }
  }

  Future<void> _fetchOtherPosts() async {
    if (_isLoadingPosts) return;

    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final posts = await getIt<PostRepository>().getPosts(
        userId: widget.userId,
        limit: 10,
      );

      if (mounted) {
        setState(() {
          _otherPosts =
              posts.where((post) => post.id != widget.currentPostId).toList();
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
    }
  }

  bool get _showProfilePicture =>
      widget.currentStep == 0 || widget.currentStep == widget.steps.length - 1;

  bool get _canExpand =>
      widget.currentStep == 0 || widget.currentStep == widget.steps.length - 1;

  Widget _buildHeaderContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final starsWidth = screenWidth * 0.6;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_otherPosts != null) ...[
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingCountStar(
                  count: _otherPosts!.fold<int>(
                    0,
                    (sum, post) => sum + post.ratings.length,
                  ),
                  size: 24,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: starsWidth,
                  child: RatingStars(
                    rating: widget.rating,
                    size: 24,
                    color: Colors.amber,
                    frameWidth: starsWidth,
                    sizeModifier: 0.2,
                    starSpacing: 3.6,
                    curvature: 0.3,
                    isInteractive: false,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (widget.userTraits.isNotEmpty)
          SizedBox(
            height: 35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.userTraits.length,
              itemBuilder: (context, index) {
                final trait = widget.userTraits[index];
                final traitType = widget.traitTypes
                    .where((t) => t.id == trait.traitTypeId)
                    .firstOrNull;
                if (traitType == null) return const SizedBox.shrink();

                return UserTraitChip(
                  trait: trait,
                  traitType: traitType,
                  spacing: 15,
                  canEditType: false,
                  canEditValue: false,
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        if (_otherPosts != null && _otherPosts!.isNotEmpty)
          OtherPostsList(
            posts: _otherPosts!,
            scrollController: _scrollController,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final postSize = MediaQuery.of(context).size.width - 32;
    final expandedHeight = postSize * 0.75;
    final collapsedHeight = 120.0;

    return AbsorbPointer(
      absorbing: !_canExpand,
      child: GestureDetector(
        onVerticalDragStart: handleVerticalDragStart,
        onVerticalDragUpdate: (details) => handleVerticalDragUpdate(
          details,
          onExpand: () => widget.onExpandChanged(true),
          onCollapse: () => widget.onExpandChanged(false),
        ),
        onVerticalDragEnd: (details) {
          handleVerticalDragEnd(details);
          widget.onExpandChanged(controller.value > 0.5);
        },
        onVerticalDragCancel: handleVerticalDragCancel,
        behavior: HitTestBehavior.translucent,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final currentHeight =
                lerpDouble(collapsedHeight, expandedHeight, controller.value)!;
            final borderRadius = lerpDouble(0, postSize / 2, controller.value)!;

            return Material(
              color: Colors.transparent,
              clipBehavior: Clip.none,
              child: Container(
                width: double.infinity,
                height: currentHeight,
                clipBehavior: Clip.none,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.vertical(
                          top: const Radius.circular(999),
                          bottom: Radius.circular(borderRadius),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: const Radius.circular(999),
                            bottom: Radius.circular(borderRadius),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7 * controller.value),
                              Colors.black.withOpacity(0.5 * controller.value),
                              Colors.black.withOpacity(0.7 * controller.value),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_showProfilePicture)
                      AnimatedProfilePicture(
                        imageUrl: widget.userProfileImage,
                        username: widget.username,
                        headerHeight: currentHeight,
                        postSize: postSize,
                        animation: controller,
                        isExpanded: widget.isExpanded,
                        onTap: _canExpand
                            ? () => widget.onExpandChanged(true)
                            : null,
                        canExpand: _canExpand,
                        showFullScreenWhenExpanded: true,
                      ),
                    if (widget.isExpanded) ...[
                      Positioned(
                        top: 32,
                        left: 0,
                        right: 0,
                        child: Opacity(
                          opacity:
                              (controller.value - 0.8).clamp(0.0, 0.2) * 5.0,
                          child: _buildHeaderContent(),
                        ),
                      ),
                      if (_isLoadingPosts)
                        const Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
