import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/dimming_effect.dart';
import '../../../widgets/animated_gradient_background.dart';
import '../../../widgets/post_creation/in_feed_post_creation.dart';
import '../../../widgets/sliding_panel.dart';
import '../../profile/profile_screen.dart';
import '../controllers/feed_header_controller.dart';
import '../services/feed_position_tracker.dart';
import '../services/feed_item_service.dart';
import '../controllers/feed_controller.dart';
import '../feed_bloc/feed_bloc.dart';
import '../feed_bloc/feed_state.dart';
import '../../../../data/models/notification_model.dart';
import '../managers/dimming_manager.dart';
import 'feed_action_buttons.dart';
import 'feed_header.dart';
import 'feed_main_content.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  bool _isCreatingPost = false;
  bool _isProfileOpen = false;
  bool _isDimmed = false;
  DimmingConfig _dimmingConfig = const DimmingConfig();
  List<GlobalKey> _excludedKeys = [];
  Offset? _dimmingSource;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<InFeedPostCreationState> _postCreationKey = GlobalKey();
  final GlobalKey _plusActionButtonKey = GlobalKey();
  final GlobalKey _profileButtonKey = GlobalKey();
  final GlobalKey _searchBarKey = GlobalKey();
  final GlobalKey _filtersKey = GlobalKey();
  GlobalKey? _selectedItemKey;

  late final FeedHeaderController _headerController;
  late final FeedPositionTracker _positionTracker;
  late final FeedController _feedController;
  late final DimmingManager _dimmingManager;

  Future<void> _tryMoveToItem(String itemId, bool isProject) async {
    if (!mounted) return;

    // Create key before scrolling
    setState(() {
      _selectedItemKey = GlobalKey();
    });

    // Wait for next frame to ensure the key is properly attached
    await Future.delayed(const Duration(milliseconds: 50));

    // Try to find and scroll to item
    final foundIndex = await _feedController.moveToItem(itemId, isProject: isProject);

    if (mounted) {
      if (foundIndex != null) {
        // Update dimming after scrolling is complete
        _dimmingManager.updateDimming(
          isProfileOpen: _isProfileOpen,
          selectedItemKey: _selectedItemKey,
        );
      } else {
        // If item not found, clear the key
        setState(() {
          _selectedItemKey = null;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _headerController = FeedHeaderController();
    _positionTracker = FeedPositionTracker(scrollController: _scrollController);

    // Set initial padding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final topPadding = MediaQuery.of(context).padding.top;
      const headerBaseHeight = 64.0;
      const chipsHeight = 96.0;
      _positionTracker
          .setTopPadding(topPadding + headerBaseHeight + chipsHeight);
    });

    final feedBloc = context.read<FeedBloc>();
    _feedController = FeedController(
      feedBloc: feedBloc,
      positionTracker: _positionTracker,
      context: context,
    );

    // Listen to feed state changes to handle scrolling when content is loaded
    feedBloc.stream.listen((state) {
      if (state is FeedSuccess) {
        final notification = _headerController.selectedNotification;
        if (notification != null &&
            notification.type != NotificationType.profile) {
          final itemId = notification.type == NotificationType.post
              ? notification.postId!
              : notification.projectId!;

          final isProject = notification.type == NotificationType.project;

          // Update feed controller with latest data first
          _feedController.updateItemService(
            FeedItemService(
              posts: state.posts,
              projects: state.projects,
              isCreatingPost: _isCreatingPost,
            ),
          );

          // Try to find and scroll to item immediately
          if (mounted) {
            _tryMoveToItem(itemId, isProject);
          }
        }
      }
    });

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

    _scrollController.addListener(_onScroll);
    _headerController.addListener(_updateDimming);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerController.removeListener(_updateDimming);
    _headerController.dispose();
    _feedController.dispose();
    super.dispose();
  }

  void _updateDimming() {
    final isNotificationMenuOpen =
        _headerController.state.isNotificationMenuOpen;
    final isSearchVisible = _headerController.state.isSearchVisible;
    final selectedNotification = _headerController.selectedNotification;

    // Handle notification selection
    if (selectedNotification != null && isNotificationMenuOpen) {
      if (_selectedItemKey == null) {
        setState(() {
          _selectedItemKey = GlobalKey();
        });
      }
    } else if (_selectedItemKey != null) {
      setState(() {
        _selectedItemKey = null;
      });
    }

    // Always update dimming to handle all state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dimmingManager.updateDimming(
          isProfileOpen: _isProfileOpen,
          selectedItemKey: _selectedItemKey,
        );
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent) {
      _feedController.refresh();
    } else if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _feedController.loadMore();
    }
  }

  void _toggleProfile() {
    setState(() {
      _isProfileOpen = !_isProfileOpen;
      _updateDimming();
    });
  }

  void _toggleCreatePost() {
    setState(() {
      _isCreatingPost = !_isCreatingPost;
    });
  }

  void _handlePostCreationComplete(bool success) {
    setState(() {
      _isCreatingPost = false;
    });
    if (success) {
      _feedController.refresh();
    }
  }

  Future<void> _handleActionButton() async {
    if (_isCreatingPost) {
      final state = _postCreationKey.currentState;
      if (state != null) {
        await state.save();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Could not save post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      _toggleCreatePost();
    }
  }

  List<Rect> _getExcludedAreas(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return [
      Rect.fromLTWH(
        0,
        size.height - bottomPadding - 88,
        size.width,
        88 + bottomPadding,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    const headerBaseHeight = 64.0;
    const chipsHeight = 96.0;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Update dimming when layout changes (e.g. keyboard)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _dimmingManager.updateDimming(
                isProfileOpen: _isProfileOpen,
                selectedItemKey: _selectedItemKey,
              );
            }
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
                  onCancel: _toggleCreatePost,
                  onComplete: _handlePostCreationComplete,
                  topPadding: topPadding + headerBaseHeight + chipsHeight,
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
                onProfileTap: _toggleProfile,
                onActionButtonTap: _handleActionButton,
              ),
              SlidingPanel(
                isOpen: _isProfileOpen,
                onClose: _toggleProfile,
                excludeFromOverlay: _getExcludedAreas(context),
                child: const ProfileScreen(),
              ),
            ],
          );
        },
      ),
    );
  }
}
