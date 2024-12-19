import 'package:flutter/material.dart';
import '../../../widgets/notifications/notification_bar.dart';
import '../controllers/feed_header_controller.dart';

class FeedNotificationOverlay extends StatelessWidget {
  final FeedHeaderController headerController;
  final double topPadding;
  final double headerHeight;

  const FeedNotificationOverlay({
    super.key,
    required this.headerController,
    required this.topPadding,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (!headerController.state.isNotificationMenuOpen) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: topPadding + headerHeight,
      left: 0,
      right: 0,
      child: NotificationBar(
        key: headerController.notificationBarKey,
        notifications: headerController.notifications,
        onNotificationSelected: headerController.selectNotification,
        onClose: headerController.toggleNotificationMenu,
      ),
    );
  }
}
