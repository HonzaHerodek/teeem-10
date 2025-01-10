import 'package:flutter/material.dart';
import '../controllers/feed_header_controller.dart';
import '../controllers/feed_controller.dart';
import 'sections/feed_header_search_section.dart';
import 'sections/feed_header_traits_section.dart';
import 'sections/feed_header_profiles_section.dart';
import 'sections/feed_header_groups_section.dart';
import 'sections/feed_header_special_filters_section.dart';

class FeedHeader extends StatelessWidget {
  final FeedHeaderController headerController;
  final FeedController? feedController;
  final GlobalKey searchBarKey;
  final GlobalKey filtersKey;
  final bool isTargetHighlighted;
  final Animation<double>? targetHighlightAnimation;

  const FeedHeader({
    super.key,
    required this.headerController,
    required this.searchBarKey,
    required this.filtersKey,
    this.feedController,
    this.isTargetHighlighted = false,
    this.targetHighlightAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Material(
      type: MaterialType.transparency,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.only(top: topPadding),
        child: ListenableBuilder(
          listenable: headerController,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FeedHeaderSearchSection(
                  headerController: headerController,
                  feedController: feedController,
                  searchBarKey: searchBarKey,
                  filtersKey: filtersKey,
                  isTargetHighlighted: isTargetHighlighted,
                  targetHighlightAnimation: targetHighlightAnimation,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: -1.0,
                        axis: Axis.vertical,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 80,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: FeedHeaderProfilesSection(
                            headerController: headerController,
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      SizedBox(
                        height: 80,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: FeedHeaderGroupsSection(
                            headerController: headerController,
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      SizedBox(
                        height: 35,
                        child: FeedHeaderSpecialFiltersSection(
                          headerController: headerController,
                        ),
                      ),
                      const SizedBox(height: 9),
                      SizedBox(
                        height: 35,
                        child: FeedHeaderTraitsSection(
                          headerController: headerController,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
