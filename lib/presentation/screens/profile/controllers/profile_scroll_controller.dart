import 'package:flutter/material.dart';

class ProfileScrollController extends ScrollController {
  bool _isDisposed = false;
  bool _isScrolling = false;
  DateTime _lastScrollTime = DateTime.now();

  ProfileScrollController() : super(keepScrollOffset: true);

  Future<void> scrollToWidget(GlobalKey key, {Duration? duration}) async {
    if (_isDisposed || !hasClients) return;
    
    // Prevent rapid consecutive scrolls
    final now = DateTime.now();
    if (_isScrolling || now.difference(_lastScrollTime).inMilliseconds < 200) {
      return;
    }

    try {
      _isScrolling = true;
      _lastScrollTime = now;

      // Wait for layout to complete
      await Future.delayed(const Duration(milliseconds: 50));
      
      if (_isDisposed || key.currentContext == null || !hasClients) return;

      final RenderBox? renderBox =
          key.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox == null || !hasClients) return;

      final position = renderBox.localToGlobal(Offset.zero);
      
      // Get latest metrics after layout
      if (!hasClients) return;
      final viewportHeight = this.position.viewportDimension;
      final widgetHeight = renderBox.size.height;
      final currentOffset = offset;
      final maxScroll = this.position.maxScrollExtent;

      // Calculate target scroll position with padding
      final targetScroll =
          (currentOffset + position.dy - (viewportHeight * 0.2))
              .clamp(0.0, maxScroll);

      // Only scroll if needed and controller is still valid
      if (position.dy + widgetHeight > viewportHeight &&
          !_isDisposed &&
          hasClients) {
        await animateTo(
          targetScroll,
          duration: duration ?? const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    } catch (e) {
      print('Error scrolling to widget: $e');
    } finally {
      _isScrolling = false;
      _lastScrollTime = DateTime.now();
    }
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      try {
        super.notifyListeners();
      } catch (e) {
        print('Error notifying scroll listeners: $e');
      }
    }
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
