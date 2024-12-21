enum NotificationType {
  post,
  project,
  profile
}

extension NotificationTypeX on NotificationType {
  String toJson() => name;
  
  static NotificationType fromJson(String json) => 
    NotificationType.values.firstWhere((e) => e.name == json);
}

class NotificationModel {
  final String id;
  final String title;
  final NotificationType type;
  final String? postId;      // For post notifications
  final String? projectId;   // For project notifications
  final String? profileId;   // For profile notifications
  final DateTime timestamp;
  final bool isRead;
  final DateTime? lastInteractionTime;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.type,
    this.postId,
    this.projectId,
    this.profileId,
    required this.timestamp,
    this.isRead = false,
    this.lastInteractionTime,
  }) : assert(
         (type == NotificationType.post && postId != null) ||
         (type == NotificationType.project && projectId != null) ||
         (type == NotificationType.profile && profileId != null),
         'ID must be provided based on notification type'
       );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: NotificationTypeX.fromJson(json['type'] as String),
      postId: json['postId'] as String?,
      projectId: json['projectId'] as String?,
      profileId: json['profileId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      lastInteractionTime: json['lastInteractionTime'] != null 
          ? DateTime.parse(json['lastInteractionTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.toJson(),
    'postId': postId,
    'projectId': projectId,
    'profileId': profileId,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'lastInteractionTime': lastInteractionTime?.toIso8601String(),
  };
}
