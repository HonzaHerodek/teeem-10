import '../models/notification_model.dart';

class MockNotificationRepository {
  final List<NotificationModel> _notifications = [];
  
  MockNotificationRepository() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _notifications.addAll([
      NotificationModel(
        id: '1',
        title: 'New comment on your post',
        type: NotificationType.post,
        postId: 'post_0',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: '2',
        title: 'Someone liked your project',
        type: NotificationType.project,
        projectId: '1',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '3',
        title: 'New follower',
        type: NotificationType.profile,
        profileId: 'user1',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: '4',
        title: 'Your post was featured',
        type: NotificationType.post,
        postId: 'post_1',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);
  }

  Future<List<NotificationModel>> getNotifications() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _notifications;
  }

  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        type: _notifications[index].type,
        postId: _notifications[index].postId,
        projectId: _notifications[index].projectId,
        profileId: _notifications[index].profileId,
        timestamp: _notifications[index].timestamp,
        isRead: true,
        lastInteractionTime: _notifications[index].lastInteractionTime,
      );
    }
  }

  Future<void> recordInteraction(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        type: _notifications[index].type,
        postId: _notifications[index].postId,
        projectId: _notifications[index].projectId,
        profileId: _notifications[index].profileId,
        timestamp: _notifications[index].timestamp,
        isRead: _notifications[index].isRead,
        lastInteractionTime: DateTime.now(),
      );
    }
  }

  Duration? getLongestIgnoredDuration() {
    if (_notifications.isEmpty) return null;

    Duration? longest;
    final now = DateTime.now();

    for (final notification in _notifications) {
      if (notification.lastInteractionTime == null) {
        final duration = now.difference(notification.timestamp);
        if (longest == null || duration > longest) {
          longest = duration;
        }
      }
    }

    return longest;
  }

  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }
}
