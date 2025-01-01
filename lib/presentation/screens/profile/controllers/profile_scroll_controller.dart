import 'package:flutter/material.dart';
import 'dart:async';

class ProfileScrollController extends ScrollController {
  bool _isDisposed = false;
  bool _isScrolling = false;
  bool _isExpanded = false;
  Timer? _scrollDebouncer;
  Timer? _expansionDebouncer;

  ProfileScrollController() : super(keepScrollOffset: true) {
    addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_isDisposed || _isExpanded) return;
    
    _scrollDebouncer?.cancel();
    _scrollDebouncer = Timer(const Duration(milliseconds: 150), () {
      if (!_isDisposed && hasClients) {
        _isScrolling = false;
      }
    });
  }

  void handleScrollEnd() {
    if (_isDisposed || _isExpanded) return;
    _isScrolling = false;
  }

  void handleExpansion(bool isExpanded) {
    if (_isDisposed) return;

    _expansionDebouncer?.cancel();
    _isExpanded = isExpanded;
    
    if (isExpanded) {
      // Lock scrolling immediately when expanding
      _isScrolling = true;
      
      // Ensure we're at a valid scroll position
      if (hasClients && position.pixels > 0) {
        jumpTo(position.pixels);
      }
    } else {
      // Add a small delay before unlocking scroll
      _expansionDebouncer = Timer(const Duration(milliseconds: 350), () {
        if (!_isDisposed && hasClients) {
          _isScrolling = false;
        }
      });
    }
  }

  Future<void> scrollToWidget(GlobalKey key, {Duration? duration}) async {
    if (_isDisposed || !hasClients || _isExpanded || _isScrolling) return;

    try {
      _isScrolling = true;

      // Wait for layout to complete
      await Future.delayed(const Duration(milliseconds: 50));

      if (_isDisposed || key.currentContext == null || !hasClients) return;

      final RenderBox? renderBox =
          key.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox == null || !hasClients) return;

      final position = renderBox.localToGlobal(Offset.zero);
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
      if (!_isDisposed && hasClients) {
        _isScrolling = false;
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollDebouncer?.cancel();
    _expansionDebouncer?.cancel();
    removeListener(_handleScroll);
    super.dispose();
  }
}
