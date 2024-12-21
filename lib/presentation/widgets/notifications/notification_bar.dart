import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';

class NotificationBar extends StatefulWidget {
  final List<NotificationModel> notifications;
  final Function(NotificationModel) onNotificationSelected;
  final VoidCallback onClose;
  final GlobalKey? barKey;

  const NotificationBar({
    super.key,
    required this.notifications,
    required this.onNotificationSelected,
    required this.onClose,
    this.barKey,
  });

  @override
  State<NotificationBar> createState() => _NotificationBarState();
}

class _NotificationBarState extends State<NotificationBar> {
  PageController? _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializePageController();
  }

  @override
  void didUpdateWidget(NotificationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notifications != oldWidget.notifications) {
      _pageController?.dispose();
      _initializePageController();
    }
  }

  void _initializePageController() {
    if (widget.notifications.isNotEmpty) {
      _pageController = PageController();
      widget.onNotificationSelected(widget.notifications[_currentIndex]);
    } else {
      _pageController = null;
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _handleIndexChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onNotificationSelected(widget.notifications[index]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notifications.isEmpty) {
      return Container(
        key: widget.barKey,
        height: 56,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      key: widget.barKey,
      height: 56,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left arrow
          Container(
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(28)),
            ),
            child: Center(
              child: GestureDetector(
                onTap: _currentIndex > 0 && _pageController != null
                    ? () {
                        _pageController?.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.white.withOpacity(
                    _currentIndex > 0 ? 1.0 : 0.5,
                  ),
                  size: 16,
                ),
              ),
            ),
          ),
          
          // Notification count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${_currentIndex + 1}/${widget.notifications.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          
          // Notifications PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _handleIndexChanged,
              itemCount: widget.notifications.length,
              itemBuilder: (context, index) {
                final notification = widget.notifications[index];
                return Center(
                  child: Text(
                    notification.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: _currentIndex == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          
          // Right arrow
          Container(
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(28)),
            ),
            child: Center(
              child: GestureDetector(
                onTap: _currentIndex < widget.notifications.length - 1 && _pageController != null
                    ? () {
                        _pageController?.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                child: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white.withOpacity(
                    _currentIndex < widget.notifications.length - 1 ? 1.0 : 0.5,
                  ),
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
