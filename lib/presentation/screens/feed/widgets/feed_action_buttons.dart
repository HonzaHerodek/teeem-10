import 'package:flutter/material.dart';
import '../../../widgets/circular_action_button.dart';
import '../../../widgets/user_avatar.dart';
import '../controllers/feed_header_controller.dart';

class FeedActionButtons extends StatelessWidget {
  final bool isCreatingPost;
  final VoidCallback onProfileTap;
  final VoidCallback onActionButtonTap;
  final GlobalKey? plusActionButtonKey;
  final GlobalKey? profileButtonKey;
  final FeedHeaderController headerController;

  const FeedActionButtons({
    super.key,
    required this.isCreatingPost,
    required this.onProfileTap,
    required this.onActionButtonTap,
    required this.headerController,
    this.plusActionButtonKey,
    this.profileButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).padding.bottom + 16,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              key: profileButtonKey,
              child: UserAvatar(
                imageUrl: 'https://picsum.photos/150/150?random=1',
                size: 56,
                onTap: onProfileTap,
                backgroundColor: Theme.of(context).colorScheme.primary,
                useTransparentEdges: true,
              ),
            ),
            if (!headerController.state.isNotificationMenuOpen)
              CircularActionButton(
                key: plusActionButtonKey,
                icon: isCreatingPost ? Icons.check : Icons.add,
                onPressed: onActionButtonTap,
                isBold: true,
                strokeWidth: 4.0,
              ),
          ],
        ),
      ),
    );
  }
}
