import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/dimming_effect.dart';
import '../../../../data/models/notification_model.dart';
import '../../../widgets/animated_gradient_background.dart';
import '../../../widgets/post_creation/in_feed_post_creation.dart';
import '../../../widgets/sliding_panel.dart';
import '../../profile/profile_screen.dart';
import '../controllers/feed_header_controller.dart';
import '../services/feed_position_tracker.dart';
import '../controllers/feed_controller.dart';
import '../feed_bloc/feed_bloc.dart';
import '../feed_bloc/feed_state.dart';
import '../managers/dimming_manager.dart';
import '../managers/notification_item_manager.dart';
import '../managers/feed_layout_manager.dart';
import '../managers/feed_state_manager.dart';
import 'feed_action_buttons.dart';
import 'feed_header.dart';
import 'feed_main_content.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  // State
  bool _isCreatingPost = false;
  bool _isProfileOpen = false;
  bool _isDimmed = false;
  DimmingConfig _dimmingConfig = const DimmingConfig();
  List<GlobalKey> _excludedKeys = [];
  Offset? _dimmingSource;
  GlobalKey? _selectedItemKey;

  // Controllers and Keys
  final _scrollController = ScrollController();
  final _postCreationKey = GlobalKey<InFeedPostCreationState>();
  final _plusActionButtonKey = GlobalKey();
  final _profileButtonKey = GlobalKey();
  final _searchBarKey = GlobalKey();
  final _filtersKey = GlobalKey();

  // Controllers and Managers
  late final FeedHeaderController _headerController;
  late final FeedPositionTracker _positionTracker;
  late final FeedController _feedController;
  late final DimmingManager _dimmingManager;
  late final FeedLayoutManager _layoutManager;
  late final NotificationItemManager _notificationManager;
  late final FeedStateManager _stateManager;

  @override
  void initState() {
    super.initState();
    _initializeManagers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _positionTracker.setTopPadding(_layoutManager.getTopPadding(context));
    });
    _setupListeners();
  }

  void _initializeManagers() {
    _headerController = FeedHeaderController();
    _positionTracker = FeedPositionTracker(scrollController: _scrollController);
    _feedController = FeedController(
      feedBloc: context.read<FeedBloc>(),
      positionTracker: _positionTracker,
      context: context,
    );

    _dimmingManager = DimmingManager(
      headerController: _headerController,
      plusActionButtonKey: _plusActionButtonKey,
      profileButtonKey: _profileButtonKey,
      searchBarKey: _searchBarKey,
      filtersKey: _filtersKey,
      onDimmingUpdate: ({
        required bool isDimmed,
        required List<GlobalKey> excludedKeys,
        required DimmingConfig config,
        Offset? source,
      }) {
        if (mounted) {
          setState(() {
            _isDimmed = isDimmed;
            _dimmingConfig = config;
            _excludedKeys = excludedKeys;
            _dimmingSource = source;
          });
        }
      },
    );

    _layoutManager = FeedLayoutManager(
      feedController: _feedController,
      headerController: _headerController,
      dimmingManager: _dimmingManager,
      isProfileOpen: _isProfileOpen,
      isCreatingPost: _isCreatingPost,
      selectedItemKey: _selectedItemKey,
      onDimmingUpdate: ({
        required bool isDimmed,
        required List<GlobalKey> excludedKeys,
        required DimmingConfig config,
        Offset? source,
      }) {
        _dimmingManager.onDimmingUpdate(
          isDimmed: isDimmed,
          excludedKeys: excludedKeys,
          config: config,
          source: source,
        );
      },
    );

    _notificationManager = NotificationItemManager(
      feedController: _feedController,
      headerController: _headerController,
      dimmingManager: _dimmingManager,
      isProfileOpen: _isProfileOpen,
      selectedItemKey: _selectedItemKey,
      onKeyUpdate: (key) {
        if (mounted) setState(() => _selectedItemKey = key);
      },
    );

    _stateManager = FeedStateManager(
      feedController: _feedController,
      headerController: _headerController,
      dimmingManager: _dimmingManager,
      notificationManager: _notificationManager,
      layoutManager: _layoutManager,
      onCreatePostChanged: (value) {
        if (mounted) setState(() => _isCreatingPost = value);
      },
      onDimmingChanged: ({
        required bool isDimmed,
        required DimmingConfig config,
        required List<GlobalKey> excludedKeys,
        Offset? source,
      }) {
        if (mounted) {
          setState(() {
            _isDimmed = isDimmed;
            _dimmingConfig = config;
            _excludedKeys = excludedKeys;
            _dimmingSource = source;
          });
        }
      },
      onKeyChanged: (key) {
        if (mounted) setState(() => _selectedItemKey = key);
      },
    );
  }

  void _setupListeners() {
    _scrollController.addListener(() => _layoutManager.handleScroll(_scrollController));
    _headerController.addListener(() => _stateManager.updateManagers(
      isProfileOpen: _isProfileOpen,
      isCreatingPost: _isCreatingPost,
      selectedItemKey: _selectedItemKey,
    ));
    context.read<FeedBloc>().stream.listen(_handleFeedState);
  }

  void _handleFeedState(FeedState state) {
    if (state is FeedSuccess) {
      final notification = _headerController.selectedNotification;
      if (notification?.type != NotificationType.profile) {
        _layoutManager.updateFeedService(state.posts, state.projects);
        if (notification != null && mounted) {
          final itemId = notification.type == NotificationType.post
              ? notification.postId!
              : notification.projectId!;
          _notificationManager.moveToItem(itemId, notification.type == NotificationType.project);
        }
      }
    }
  }

  Future<void> _handleActionButton() async {
    if (_isCreatingPost) {
      if (_postCreationKey.currentState != null) {
        await _postCreationKey.currentState!.save();
        _stateManager.handlePostComplete(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Could not save post'),
            backgroundColor: Colors.red,
          ),
        );
        _stateManager.handlePostComplete(false);
      }
    } else {
      setState(() => _isCreatingPost = !_isCreatingPost);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _stateManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _layoutManager.updateDimming();
        });

        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedGradientBackground(
              child: FeedMainContent(
                scrollController: _scrollController,
                feedController: _feedController,
                isCreatingPost: _isCreatingPost,
                postCreationKey: _postCreationKey,
                onCancel: () => setState(() => _isCreatingPost = false),
                onComplete: (success) {
                  setState(() => _isCreatingPost = false);
                  if (success) _feedController.refresh();
                },
                topPadding: _layoutManager.getTopPadding(context),
                selectedItemKey: _selectedItemKey,
                selectedNotification: _headerController.selectedNotification,
              ),
            ).withDimming(
              isDimmed: _isDimmed,
              config: _dimmingConfig,
              excludedKeys: _excludedKeys,
              source: _dimmingSource,
            ),
            FeedHeader(
              headerController: _headerController,
              feedController: _feedController,
              searchBarKey: _searchBarKey,
              filtersKey: _filtersKey,
            ),
            FeedActionButtons(
              plusActionButtonKey: _plusActionButtonKey,
              profileButtonKey: _profileButtonKey,
              isCreatingPost: _isCreatingPost,
              onProfileTap: () {
                setState(() => _isProfileOpen = !_isProfileOpen);
                _stateManager.handleProfileStateChange(_isProfileOpen);
              },
              onActionButtonTap: _handleActionButton,
            ),
            SlidingPanel(
              isOpen: _isProfileOpen,
              onClose: () {
                setState(() => _isProfileOpen = false);
                _stateManager.handleProfileStateChange(false);
              },
              excludeFromOverlay: _layoutManager.getExcludedAreas(context),
              child: const ProfileScreen(),
            ),
          ],
        );
      },
    ),
  );
}
