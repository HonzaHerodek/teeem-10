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
    // Don't show navigation dots on first page or step type selection page
    if (currentPage == 0 || currentPage == 1) return const SizedBox.shrink();

    // Adjust page index to account for step type selection page
    final adjustedCurrentPage = currentPage > 1 ? currentPage - 1 : currentPage;
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i <= stepsCount; i++)
              GestureDetector(
                onTap: () {
                  // Adjust target page to account for step type selection page
                  final targetPage = i == 0 ? 0 : i + 1;
                  pageController.animateToPage(
                    targetPage,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == adjustedCurrentPage
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
