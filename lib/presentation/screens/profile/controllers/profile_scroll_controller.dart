import 'package:flutter/material.dart';

class ProfileScrollController {
  final ScrollController scrollController = ScrollController();

  void scrollToWidget(GlobalKey key, {Duration? duration}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (key.currentContext != null) {
        final RenderBox renderBox =
            key.currentContext!.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);

        // Calculate if the widget is fully visible
        final screenHeight =
            WidgetsBinding.instance.window.physicalSize.height /
                WidgetsBinding.instance.window.devicePixelRatio;
        final widgetHeight = renderBox.size.height;
        final bottomPadding = 20.0;

        // Calculate target scroll position to show the widget
        final targetScroll =
            scrollController.position.pixels + position.dy - 100;

        // If widget is not fully visible in viewport, scroll to show it
        if (position.dy + widgetHeight > screenHeight) {
          scrollController.animateTo(
            targetScroll.clamp(
              0.0,
              scrollController.position.maxScrollExtent,
            ),
            duration: duration ??
                const Duration(milliseconds: 800), // Longer duration
            curve: Curves.easeInOutCubic, // More fluid curve
          );
        }
      }
    });
  }

  ScrollPhysics get physics => const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );

  void dispose() {
    scrollController.dispose();
  }
}
