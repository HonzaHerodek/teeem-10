import 'package:flutter/material.dart';

class ProfileScrollController {
  final ScrollController scrollController = ScrollController();
  bool _isInitialized = false;

  ProfileScrollController() {
    scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_isInitialized && scrollController.hasClients) {
      _isInitialized = true;
    }
  }

  void scrollToWidget(GlobalKey key, {Duration? duration}) {
    if (!_isInitialized || !scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (key.currentContext != null) {
        final RenderBox renderBox =
            key.currentContext!.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);

        final screenHeight =
            WidgetsBinding.instance.window.physicalSize.height /
                WidgetsBinding.instance.window.devicePixelRatio;
        final widgetHeight = renderBox.size.height;

        final targetScroll =
            scrollController.position.pixels + position.dy - 100;

        if (position.dy + widgetHeight > screenHeight) {
          scrollController.animateTo(
            targetScroll.clamp(
              0.0,
              scrollController.position.maxScrollExtent,
            ),
            duration: duration ?? const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  ScrollPhysics get physics => const AlwaysScrollableScrollPhysics();

  void dispose() {
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
  }
}
