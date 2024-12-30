import 'package:flutter/material.dart';

class ProfileScrollController {
  final ScrollController _scrollController;
  bool _isDisposed = false;

  ProfileScrollController() : _scrollController = ScrollController();

  ScrollController get controller => _scrollController;

  void scrollToWidget(GlobalKey key, {Duration? duration}) {
    if (_isDisposed || !_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || key.currentContext == null) return;
      
      try {
        final RenderBox? renderBox = key.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox == null || !_scrollController.hasClients) return;
        
        final position = renderBox.localToGlobal(Offset.zero);
        
        // Safely get scroll metrics
        if (!_scrollController.hasClients) return;
        final viewportHeight = _scrollController.position.viewportDimension;
        final widgetHeight = renderBox.size.height;
        final currentOffset = _scrollController.offset;
        final maxScroll = _scrollController.position.maxScrollExtent;
        
        // Calculate target scroll position
        final targetScroll = currentOffset + position.dy - (viewportHeight * 0.2);
        
        // Only scroll if needed and controller is still valid
        if (position.dy + widgetHeight > viewportHeight && !_isDisposed && _scrollController.hasClients) {
          _scrollController.animateTo(
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
    if (_isDisposed || !_scrollController.hasClients) return;
    try {
      _scrollController.jumpTo(0);
    } catch (e) {
      print('Error jumping to top: $e');
    }
  }

  void animateToTop({Duration? duration}) {
    if (_isDisposed || !_scrollController.hasClients) return;
    try {
      _scrollController.animateTo(
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

  ScrollPhysics get physics => const ClampingScrollPhysics();

  bool get hasClients => _scrollController.hasClients;

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    
    try {
      if (_scrollController.hasClients) {
        // Stop any ongoing animations
        _scrollController.jumpTo(_scrollController.offset);
      }
      _scrollController.dispose();
    } catch (e) {
      print('Error disposing scroll controller: $e');
    }
  }
}
