import 'package:flutter/material.dart';
import '../constants/post_widget_constants.dart';

class AnimatedProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final String username;
  final double headerHeight;
  final double postSize;
  final Animation<double> animation;
  final bool isExpanded;
  final VoidCallback? onTap;
  final bool canExpand;
  final bool showFullScreenWhenExpanded;

  const AnimatedProfilePicture({
    super.key,
    this.imageUrl,
    required this.username,
    required this.headerHeight,
    required this.postSize,
    required this.animation,
    required this.isExpanded,
    this.onTap,
    this.canExpand = true,
    this.showFullScreenWhenExpanded = true,
  });

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          username[0].toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16 * PostWidgetConstants.textScale,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(999),
          bottom: Radius.circular(postSize / 2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(999),
          bottom: Radius.circular(postSize / 2),
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedImage(double size, double top) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: canExpand && !isExpanded ? onTap : null,
          child: Container(
            width: size,
            height: size,
            decoration: PostWidgetConstants.circularBorderDecoration,
            child: ClipOval(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) return const SizedBox();

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Show expanded image only when fully expanded
        if (showFullScreenWhenExpanded && animation.value == 1.0) {
          return Positioned.fill(child: _buildExpandedImage());
        }

        // Otherwise show the collapsing/expanding circular image
        final size = Tween<double>(
          begin: PostWidgetConstants.collapsedAvatarSize,
          end: headerHeight,
        ).evaluate(animation);

        final top = Tween<double>(
          begin: 20,
          end: 0,
        ).evaluate(animation);

        return _buildCollapsedImage(size, top);
      },
    );
  }
}
