enum NotificationAttentionState {
  normal,
  filled,
  mediumSize,
  largeSize,
  withDot,
  withCircle,
  expanded,
  blinking;

  bool get isSizeIncreased => 
    this == NotificationAttentionState.mediumSize ||
    this == NotificationAttentionState.largeSize ||
    this == NotificationAttentionState.expanded;

  double get iconScale {
    switch (this) {
      case NotificationAttentionState.mediumSize:
        return 1.2;
      case NotificationAttentionState.largeSize:
        return 1.4;
      case NotificationAttentionState.expanded:
        return 1.6;
      default:
        return 1.0;
    }
  }

  double get buttonScale {
    return this == NotificationAttentionState.expanded ? 1.2 : 1.0;
  }
}
