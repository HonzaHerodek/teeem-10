import 'notification_attention_state.dart';

class NotificationAttentionConfig {
  final Duration filledThreshold;
  final Duration mediumSizeThreshold;
  final Duration largeSizeThreshold;
  final Duration dotThreshold;
  final Duration circleThreshold;
  final Duration expandedThreshold;
  final Duration blinkingThreshold;
  final Duration requiredInteractionTime;

  const NotificationAttentionConfig({
    this.filledThreshold = const Duration(minutes: 5),
    this.mediumSizeThreshold = const Duration(minutes: 15),
    this.largeSizeThreshold = const Duration(minutes: 30),
    this.dotThreshold = const Duration(hours: 1),
    this.circleThreshold = const Duration(hours: 2),
    this.expandedThreshold = const Duration(hours: 4),
    this.blinkingThreshold = const Duration(hours: 8),
    this.requiredInteractionTime = const Duration(seconds: 30),
  });

  NotificationAttentionState getStateForDuration(Duration ignoredDuration) {
    if (ignoredDuration >= blinkingThreshold) {
      return NotificationAttentionState.blinking;
    } else if (ignoredDuration >= expandedThreshold) {
      return NotificationAttentionState.expanded;
    } else if (ignoredDuration >= circleThreshold) {
      return NotificationAttentionState.withCircle;
    } else if (ignoredDuration >= dotThreshold) {
      return NotificationAttentionState.withDot;
    } else if (ignoredDuration >= largeSizeThreshold) {
      return NotificationAttentionState.largeSize;
    } else if (ignoredDuration >= mediumSizeThreshold) {
      return NotificationAttentionState.mediumSize;
    } else if (ignoredDuration >= filledThreshold) {
      return NotificationAttentionState.filled;
    }
    return NotificationAttentionState.normal;
  }
}
