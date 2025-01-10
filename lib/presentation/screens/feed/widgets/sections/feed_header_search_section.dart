import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../widgets/notifications/notification_bar.dart';
import '../../../../widgets/notifications/notification_attention_icon.dart';
import '../../controllers/feed_header_controller.dart';
import '../../controllers/feed_controller.dart';
import '../../feed_bloc/feed_bloc.dart';
import '../../feed_bloc/feed_event.dart';
import '../feed_search_bar.dart';
import '../target_icon.dart';

class FeedHeaderSearchSection extends StatefulWidget {
  final FeedHeaderController headerController;
  final FeedController? feedController;
  final GlobalKey searchBarKey;
  final GlobalKey filtersKey;
  final bool isTargetHighlighted;
  final Animation<double>? targetHighlightAnimation;

  const FeedHeaderSearchSection({
    super.key,
    required this.headerController,
    required this.searchBarKey,
    required this.filtersKey,
    this.feedController,
    this.isTargetHighlighted = false,
    this.targetHighlightAnimation,
  });

  @override
  State<FeedHeaderSearchSection> createState() => _FeedHeaderSearchSectionState();
}

class _FeedHeaderSearchSectionState extends State<FeedHeaderSearchSection> {
  bool _testMode = false;
  bool _showTestControls = false;

  void _handleTestModeChanged(bool enabled) {
    setState(() {
      _testMode = enabled;
      if (!enabled) {
        _showTestControls = false;
      }
    });
  }

  void _handleLongPress() {
    if (!widget.headerController.state.isNotificationMenuOpen) {
      setState(() {
        _showTestControls = !_showTestControls;
        if (!_showTestControls) {
          _testMode = false;
        }
      });
    }
  }

  void _handleSearch(BuildContext context, String query) {
    context.read<FeedBloc>().add(FeedSearchChanged(query));
  }

  Widget _buildSearchBar(BuildContext context) {
    if (!widget.headerController.state.isSearchVisible ||
        widget.headerController.state.activeFilterType == null) {
      return const SizedBox.shrink();
    }

    return Container(
      key: widget.filtersKey,
      child: FeedSearchBar(
        key: widget.searchBarKey,
        filterType: widget.headerController.state.activeFilterType!,
        onSearch: (query) => _handleSearch(context, query),
        onClose: widget.headerController.closeSearch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _handleLongPress,
      child: SizedBox(
        height: 64,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!widget.headerController.state.isCreatingPost)
              SizedBox(
                width: 56,
                child: Center(
                  child: NotificationAttentionIcon(
                    notificationCount: widget.headerController.unreadNotificationCount,
                    onTap: _showTestControls ? () {} : widget.headerController.toggleNotificationMenu,
                    isActive: widget.headerController.state.isNotificationMenuOpen,
                    longestIgnoredDuration: widget.headerController.longestIgnoredDuration,
                    testMode: _testMode,
                    showTestModeControls: _showTestControls,
                    onTestModeChanged: _handleTestModeChanged,
                  ),
                ),
              ),

            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        child: child,
                      ),
                    );
                  },
                  child: widget.headerController.state.isNotificationMenuOpen
                      ? NotificationBar(
                          key: const ValueKey('notification_bar'),
                          notifications: widget.headerController.notifications,
                          onNotificationSelected: (notification) {
                            widget.headerController.selectNotification(
                                notification, widget.feedController);
                          },
                          onClose: widget.headerController.toggleNotificationMenu,
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildSearchBar(context),
                        ),
                ),
              ),
            ),

            SizedBox(
              width: 56,
              child: Center(
                child: TargetIcon(
                  key: widget.headerController.targetIconKey,
                  onTap: widget.headerController.toggleSearch,
                  isActive: widget.headerController.state.isSearchVisible,
                  isHighlighted: widget.isTargetHighlighted,
                  highlightAnimation: widget.targetHighlightAnimation,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
