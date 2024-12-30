import 'package:flutter/material.dart';
import '../../data/models/project_model.dart';

class CompactProjectCard extends StatelessWidget {
  final ProjectModel project;
  final double width;
  final double height;
  final List<String> postThumbnails;
  final VoidCallback? onTap;
  final bool showRoute;
  final String? route;
  final bool showParentIndicator;

  const CompactProjectCard({
    super.key,
    required this.project,
    required this.postThumbnails,
    this.width = 120,
    this.height = 120,
    this.onTap,
    this.showRoute = false,
    this.route,
    this.showParentIndicator = true,
  });

  Widget _buildPostMiniatures() {
    // Show up to 3 post thumbnails plus the count in the fourth position
    final int displayCount = postThumbnails.length > 3 ? 3 : postThumbnails.length;
    
    return Positioned(
      right: 8,
      bottom: 8,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            // Show post thumbnails in first 3 positions
            for (var i = 0; i < displayCount; i++)
              Positioned(
                top: (i ~/ 2) * 20.0,
                left: (i % 2) * 20.0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                    image: DecorationImage(
                      image: NetworkImage(postThumbnails[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            // Show post count in fourth position
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.7),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: Text(
                    '+${project.postIds.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Parent/Child indicators
              if (showParentIndicator)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (project.parentId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.subdirectory_arrow_right,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      if (project.childrenIds.isNotEmpty) ...[
                        if (project.parentId != null)
                          const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.account_tree,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${project.childrenIds.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (showRoute && route != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      route!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(12, showRoute && route != null ? 28 : 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (postThumbnails.isNotEmpty) _buildPostMiniatures(),
            ],
          ),
        ),
      ),
    );
  }
}
