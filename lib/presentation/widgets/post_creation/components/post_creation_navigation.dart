import 'package:flutter/material.dart';

class PostCreationNavigation extends StatelessWidget {
  final int currentPage;
  final int stepsCount;
  final PageController pageController;
  final VoidCallback onAddStep;

  const PostCreationNavigation({
    Key? key,
    required this.currentPage,
    required this.stepsCount,
    required this.pageController,
    required this.onAddStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stepsCount == 0) return const SizedBox.shrink();

    return Stack(
      children: [
        if (currentPage > 0)
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white70,
                ),
                onPressed: () {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
        if (stepsCount > 0)
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: currentPage < stepsCount
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        if (currentPage < stepsCount) {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white70,
                      ),
                      onPressed: onAddStep,
                    ),
            ),
          ),
      ],
    );
  }
}
