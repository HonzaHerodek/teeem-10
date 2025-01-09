import 'package:flutter/material.dart';

class FeedSkeletonLoading extends StatefulWidget {
  final double topPadding;

  const FeedSkeletonLoading({
    super.key,
    required this.topPadding,
  });

  @override
  State<FeedSkeletonLoading> createState() => _FeedSkeletonLoadingState();
}

class _FeedSkeletonLoadingState extends State<FeedSkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: widget.topPadding),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _SkeletonItem(
                shimmerController: _shimmerController,
              ),
              childCount: 5, // Show 5 skeleton items
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonItem extends StatelessWidget {
  final AnimationController shimmerController;

  const _SkeletonItem({
    required this.shimmerController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AnimatedBuilder(
        animation: shimmerController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Avatar placeholder
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getShimmerColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Username and timestamp placeholders
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 14,
                              decoration: BoxDecoration(
                                color: _getShimmerColor(),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 80,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getShimmerColor(),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content placeholder
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _getShimmerColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _getShimmerColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Image placeholder
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _getShimmerColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                // Action buttons placeholder
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getShimmerColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getShimmerColor() {
    return Color.lerp(
      Colors.white.withOpacity(0.1),
      Colors.white.withOpacity(0.3),
      shimmerController.value,
    )!;
  }
}
