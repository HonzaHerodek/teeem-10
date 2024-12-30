import 'package:flutter/material.dart';

class ProfileScrollController {
  final ScrollController scrollController;

  ProfileScrollController() : scrollController = ScrollController();

  void scrollToWidget(GlobalKey key, {Duration? duration}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (key.currentContext != null && scrollController.hasClients) {
        try {
          final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
          final position = renderBox.localToGlobal(Offset.zero);
          
          // Calculate if the widget is fully visible
          final viewportHeight = scrollController.position.viewportDimension;
          final widgetHeight = renderBox.size.height;
          
          // Calculate target scroll position to show the widget
          final targetScroll = scrollController.offset + position.dy - (viewportHeight * 0.2);
          
          // Only scroll if needed
          if (position.dy + widgetHeight > viewportHeight) {
            scrollController.animateTo(
              targetScroll.clamp(
                0.0,
                scrollController.position.maxScrollExtent,
              ),
              duration: duration ?? const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            );
          }
        } catch (e) {
          print('Error scrolling to widget: $e');
        }
      }
    });
  }

  ScrollPhysics get physics => const ClampingScrollPhysics();

  void dispose() {
    if (scrollController.hasClients) {
      scrollController.dispose();
    }
  }
}
