import 'package:flutter/material.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../data/models/traits/trait_type_model.dart';
import '../../../../data/repositories/mock_notification_repository.dart';
import '../../../../data/repositories/mock_trait_repository.dart';
import '../models/filter_type.dart';
import '../controllers/feed_controller.dart';

class FeedHeaderState {
  final bool isSearchVisible;
  final bool isNotificationMenuOpen;
  final FilterType activeFilterType;
  final TraitTypeModel? selectedTraitType;
  final String? selectedTraitValue;
  final List<TraitTypeModel> traitTypes;
  final NotificationModel? selectedNotification;
  final List<NotificationModel> notifications;

  const FeedHeaderState({
    this.isSearchVisible = false,
    this.isNotificationMenuOpen = false,
    this.activeFilterType = FilterType.none,
    this.selectedTraitType,
    this.selectedTraitValue,
    this.traitTypes = const [],
    this.selectedNotification,
    this.notifications = const [],
  });

  FeedHeaderState copyWith({
    bool? isSearchVisible,
    bool? isNotificationMenuOpen,
    FilterType? activeFilterType,
    TraitTypeModel? selectedTraitType,
    String? selectedTraitValue,
    List<TraitTypeModel>? traitTypes,
    NotificationModel? selectedNotification,
    List<NotificationModel>? notifications,
    bool clearNotification = false,
    bool clearTraitType = false,
    bool clearTraitValue = false,
  }) {
    return FeedHeaderState(
      isSearchVisible: isSearchVisible ?? this.isSearchVisible,
      isNotificationMenuOpen:
          isNotificationMenuOpen ?? this.isNotificationMenuOpen,
      activeFilterType: activeFilterType ?? this.activeFilterType,
      selectedTraitType:
          clearTraitType ? null : (selectedTraitType ?? this.selectedTraitType),
      selectedTraitValue: clearTraitValue
          ? null
          : (selectedTraitValue ?? this.selectedTraitValue),
      traitTypes: traitTypes ?? this.traitTypes,
      selectedNotification: clearNotification
          ? null
          : (selectedNotification ?? this.selectedNotification),
      notifications: notifications ?? this.notifications,
    );
  }
}

class FeedHeaderController extends ChangeNotifier {
  FeedHeaderState _state = const FeedHeaderState();
  final GlobalKey targetIconKey = GlobalKey();
  final GlobalKey notificationBarKey = GlobalKey();
  final MockNotificationRepository _notificationRepository;

  final MockTraitRepository _traitRepository;

  FeedHeaderController({
    MockNotificationRepository? notificationRepository,
    MockTraitRepository? traitRepository,
  })  : _notificationRepository =
            notificationRepository ?? MockNotificationRepository(),
        _traitRepository = traitRepository ?? MockTraitRepository() {
    _loadNotifications();
    _loadTraitTypes();
  }

  Future<void> _loadTraitTypes() async {
    final traitTypes = await _traitRepository.getTraitTypes();
    _state = _state.copyWith(traitTypes: traitTypes);
    notifyListeners();
  }

  FeedHeaderState get state => _state;
  List<TraitTypeModel> get traitTypes => _state.traitTypes;
  NotificationModel? get selectedNotification => _state.selectedNotification;
  List<NotificationModel> get notifications => _state.notifications;
  int get unreadNotificationCount => _notificationRepository.getUnreadCount();

  Future<void> _loadNotifications() async {
    final notifications = await _notificationRepository.getNotifications();
    _state = _state.copyWith(notifications: notifications);
    notifyListeners();
  }

  void toggleSearch() {
    final newSearchVisible = !_state.isSearchVisible;
    _state = _state.copyWith(
      isSearchVisible: newSearchVisible,
      isNotificationMenuOpen: false,
      activeFilterType: newSearchVisible ? FilterType.traits : FilterType.none,
      clearTraitType: !newSearchVisible,
      clearTraitValue: !newSearchVisible,
    );
    notifyListeners();
  }

  void hideSearch() {
    if (_state.isSearchVisible) {
      _state = _state.copyWith(isSearchVisible: false);
      notifyListeners();
    }
  }

  void closeSearch() {
    _state = _state.copyWith(
      isSearchVisible: false,
      activeFilterType: FilterType.none,
      clearTraitType: true,
      clearTraitValue: true,
    );
    notifyListeners();
  }

  void toggleNotificationMenu() {
    final newState = !_state.isNotificationMenuOpen;
    _state = _state.copyWith(
      isNotificationMenuOpen: newState,
      isSearchVisible: false,
      clearNotification: !newState,
    );
    notifyListeners();
  }

  void selectNotification(
      NotificationModel notification, FeedController? feedController) {
    _notificationRepository.markAsRead(notification.id);
    _state = _state.copyWith(
      selectedNotification: notification,
      isNotificationMenuOpen: true,
    );

    // Scroll to the associated content if it's a post or project notification
    if (feedController != null &&
        notification.type != NotificationType.profile) {
      final itemId = notification.type == NotificationType.post
          ? notification.postId!
          : notification.projectId!;

      final isProject = notification.type == NotificationType.project;
      feedController.moveToItem(itemId, isProject: isProject);
    }

    notifyListeners();
  }

  void clearNotificationSelection() {
    _state = _state.copyWith(clearNotification: true);
    notifyListeners();
  }

  void selectFilter(FilterType type) {
    if (_state.activeFilterType == type) {
      _state = _state.copyWith(
        activeFilterType: FilterType.none,
        clearTraitType: true,
        clearTraitValue: true,
      );
    } else {
      _state = _state.copyWith(
        activeFilterType: type,
        clearTraitType: true,
        clearTraitValue: true,
      );
    }
    notifyListeners();
  }

  void selectTraitType(TraitTypeModel? traitType) {
    _state = _state.copyWith(
      selectedTraitType: traitType,
      clearTraitValue: true,
    );
    notifyListeners();
  }

  void selectTraitValue(String value) {
    _state = _state.copyWith(selectedTraitValue: value);
    notifyListeners();
  }

  void updateTraitTypes(List<TraitTypeModel> traitTypes) {
    _state = _state.copyWith(traitTypes: traitTypes);
    notifyListeners();
  }

  void reset() {
    _state = const FeedHeaderState();
    notifyListeners();
  }
}
