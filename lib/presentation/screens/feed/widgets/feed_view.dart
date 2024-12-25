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
  bool _isCreatingPost = false;
  bool _isProfileOpen = false;
  bool _isDimmed = false;
  DimmingConfig _dimmingConfig = const DimmingConfig();
  Map<GlobalKey, DimmingConfig> _excludedConfigs = {};
  Offset? _dimmingSource;
  GlobalKey? _selectedItemKey;

  final _scrollController = ScrollController();
  final _postCreationKey = GlobalKey<InFeedPostCreationState>();
  final _plusActionButtonKey = GlobalKey();
  final _profileButtonKey = GlobalKey();
  final _searchBarKey = GlobalKey();
  final _filtersKey = GlobalKey();

  late final FeedHeaderController _headerController;
  late final FeedPositionTracker _positionTracker;
  late final FeedController _feedController;
  late final DimmingManager _dimmingManager;
  late final FeedLayoutManager _layoutManager;
  late final NotificationItemManager _notificationManager;
  late final FeedStateManager _stateManager;

  List<Rect> _getExcludedRects() {
    final excludedAreas = _layoutManager.getExcludedAreas(context);
    return excludedAreas.map((key) {
      final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return Rect.zero;
      
      final position = renderBox.localToGlobal(Offset.zero);
      return position & renderBox.size;
    }).toList();
  }

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
        required DimmingConfig config,
        required Map<GlobalKey, DimmingConfig> excludedConfigs,
        Offset? source,
      }) {
        if (mounted) {
          setState(() {
            _isDimmed = isDimmed;
            _dimmingConfig = config;
            _excludedConfigs = excludedConfigs;
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
    );

    _notificationManager = NotificationItemManager(
      feedController: _feedController,
      headerController: _headerController,
      dimmingManager: _dimmingManager,
      isProfileOpen: _isProfileOpen,
      selectedItemKey: _selectedItemKey,
    );

    _stateManager = FeedStateManager(
      feedController: _feedController,
      headerController: _headerController,
      dimmingManager: _dimmingManager,
      notificationManager: _notificationManager,
      layoutManager: _layoutManager,
      onCreatePostChanged: (value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _isCreatingPost = value);
          }
        });
      },
      onDimmingChanged: ({
        required bool isDimmed,
        required DimmingConfig config,
        required Map<GlobalKey, DimmingConfig> excludedConfigs,
        Offset? source,
      }) {
        if (mounted) {
          setState(() {
            _isDimmed = isDimmed;
            _dimmingConfig = config;
            _excludedConfigs = excludedConfigs;
            _dimmingSource = source;
          });
        }
      },
      onKeyChanged: (key) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _selectedItemKey = key);
          }
        });
      },
    );
  }

  void _setupListeners() {
    _scrollController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _layoutManager.handleScroll(_scrollController);
        }
      });
    });
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _layoutManager.updateFeedService(state.posts, state.projects);
            if (notification != null) {
              final itemId = notification.type == NotificationType.post
                  ? notification.postId!
                  : notification.projectId!;
              _notificationManager.moveToItem(itemId, notification.type == NotificationType.project);
            }
          }
        });
      }
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
              child: Builder(
                builder: (context) => FeedMainContent(
                  scrollController: _scrollController,
                  feedController: _feedController,
                  isCreatingPost: _isCreatingPost,
                  postCreationKey: _postCreationKey,
                  onCancel: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _isCreatingPost = false);
                      }
                    });
                  },
                  onComplete: (success, project) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _isCreatingPost = false);
                        if (success) _feedController.refresh();
                      }
                    });
                  },
                  topPadding: _layoutManager.getTopPadding(context),
                  selectedItemKey: _selectedItemKey,
                  selectedNotification: _headerController.selectedNotification,
                ),
              ),
            ).withDimming(
              isDimmed: _isDimmed,
              config: _dimmingConfig,
              excludedConfigs: _excludedConfigs,
              source: _dimmingSource,
              onDimmedAreaTap: () {
                if (_headerController.state.isSearchVisible) {
                  _headerController.closeSearch();
                }
              },
            ),
            FeedHeader(
              headerController: _headerController,
              feedController: _feedController,
              searchBarKey: _searchBarKey,
              filtersKey: _filtersKey,
            ),
            Builder(
              builder: (context) => FeedActionButtons(
                plusActionButtonKey: _plusActionButtonKey,
                profileButtonKey: _profileButtonKey,
                isCreatingPost: _isCreatingPost,
                onProfileTap: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _isProfileOpen = !_isProfileOpen);
                      _stateManager.handleProfileStateChange(_isProfileOpen);
                    }
                  });
                },
                onActionButtonTap: () async {
                  if (_isCreatingPost) {
                    final controller = InFeedPostCreation.of(context);
                    if (controller != null) {
                      try {
                        await controller.save();
                        _stateManager.handlePostComplete(true);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to save post: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        _stateManager.handlePostComplete(false);
                      }
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
                    // Ensure state change happens before any layout updates
                    setState(() => _isCreatingPost = true);
                  }
                },
              ),
            ),
            SlidingPanel(
              isOpen: _isProfileOpen,
              onClose: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() => _isProfileOpen = false);
                    _stateManager.handleProfileStateChange(false);
                  }
                });
              },
              excludeFromOverlay: _getExcludedRects(),
              child: const ProfileScreen(),
            ),
          ],
        );
      },
    ),
  );
}
