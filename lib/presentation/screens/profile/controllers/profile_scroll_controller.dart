import 'package:flutter/material.dart';

class ProfileScrollController extends ScrollController {
  bool _isDisposed = false;

  ProfileScrollController() : super();

  void scrollToWidget(GlobalKey key, {Duration? duration}) {
    if (_isDisposed || !hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || key.currentContext == null) return;

      try {
        final RenderBox? renderBox =
            key.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox == null || !hasClients) return;

        final position = renderBox.localToGlobal(Offset.zero);

        // Safely get scroll metrics
        if (!hasClients) return;
        final viewportHeight = this.position.viewportDimension;
        final widgetHeight = renderBox.size.height;
        final currentOffset = offset;
        final maxScroll = this.position.maxScrollExtent;

        // Calculate target scroll position
        final targetScroll =
            currentOffset + position.dy - (viewportHeight * 0.2);

        // Only scroll if needed and controller is still valid
        if (position.dy + widgetHeight > viewportHeight &&
            !_isDisposed &&
            hasClients) {
          animateTo(
            targetScroll.clamp(0.0, maxScroll),
            duration: duration ?? const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          ).catchError((error) {
            print('Error during scroll animation: $error');
          });
        }
      } catch (e) {
        print('Error scrolling to widget: $e');
      }
    });
  }

  void jumpToTop() {
    if (_isDisposed || !hasClients) return;
    try {
      jumpTo(0);
    } catch (e) {
      print('Error jumping to top: $e');
    }
  }

  void animateToTop({Duration? duration}) {
    if (_isDisposed || !hasClients) return;
    try {
      animateTo(
        0,
        duration: duration ?? const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      ).catchError((error) {
        print('Error animating to top: $error');
      });
    } catch (e) {
      print('Error animating to top: $e');
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      if (hasClients) {
        // Stop any ongoing animations
        jumpTo(offset);
      }
      super.dispose();
    } catch (e) {
      print('Error disposing scroll controller: $e');
    }
  }
}
