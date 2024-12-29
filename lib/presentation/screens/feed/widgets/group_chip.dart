import 'package:flutter/material.dart';
import '../../../widgets/common/shadowed_text.dart';

class GroupProfileInfo {
  final String imageUrl;
  final String username;

  const GroupProfileInfo({
    required this.imageUrl,
    required this.username,
  });
}

class GroupChip extends StatelessWidget {
  final String groupName;
  final List<GroupProfileInfo> profiles;
  final VoidCallback? onTap;
  final bool isSelected;
  final double height;
  final double spacing;
  final bool showAddPeople;

  const GroupChip({
    super.key,
    required this.groupName,
    required this.profiles,
    this.onTap,
    this.isSelected = false,
    this.height = 56,
    this.spacing = 20,
    this.showAddPeople = false,
  });

  Widget _buildProfileGrid() {
    const double gridHeight = 50.0; // Fixed height for all layouts

    if (showAddPeople) {
      return SizedBox(
        width: gridHeight,
        height: gridHeight,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.person_add,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),
        ),
      );
    }

    const double smallSpacing = 2.0;
    final visibleProfiles = profiles.take(4).toList(); // Show max 4 profiles
    final shouldShowCount = profiles.length > 4;
    
    // Profile sizes based on layout
    double profileSize = 24.0;
    if (visibleProfiles.length == 2) {
      profileSize = 28.0; // Larger size for diagonal layout
    }
    
    // Calculate grid width based on layout
    double gridWidth = profileSize * 2 + smallSpacing;
    if (visibleProfiles.length == 1) {
      gridWidth = profileSize;
    }

    return SizedBox(
      width: gridWidth,
      height: gridHeight,
      child: Stack(
        children: [
          // Position profiles based on count
          ...visibleProfiles.asMap().entries.map((entry) {
            final index = entry.key;
            final profile = entry.value;
            
            // Calculate position based on index and total count
            double? left;
            double? top;
            
            if (visibleProfiles.length == 1) {
              left = 0;
              top = (gridHeight - profileSize) / 2;
            } else if (visibleProfiles.length == 2) {
              // Diagonal layout
              if (index == 0) {
                left = 0;
                top = 0;
              } else {
                left = profileSize - smallSpacing;
                top = gridHeight - profileSize;
              }
            } else if (visibleProfiles.length == 3) {
              if (index == 0) {
                left = (gridWidth - profileSize) / 2;
                top = 0;
              } else {
                left = (index - 1) * (profileSize + smallSpacing);
                top = profileSize + smallSpacing;
              }
            } else {
              // 4 profiles in a grid
              left = (index % 2) * (profileSize + smallSpacing);
              top = (index ~/ 2) * (profileSize + smallSpacing);
            }

            return Positioned(
              left: left,
              top: top,
              child: Container(
                width: profileSize,
                height: profileSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    profile.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white.withOpacity(0.15),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: profileSize * 0.6,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          }),
          // Total count in center (only if more than 4 profiles)
          if (shouldShowCount)
            Positioned.fill(
              child: Center(
                child: ShadowedText(
                  text: '${profiles.length}',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  strokeWidth: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: spacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile grid with fixed height
            _buildProfileGrid(),
            const SizedBox(height: 4),
            // Group name with shadow
            ShadowedText(
              text: groupName,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ],
        ),
      ),
    );
  }
}
