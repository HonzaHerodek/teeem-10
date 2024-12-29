import 'package:flutter/material.dart';
import '../../../widgets/common/shadowed_text.dart';

class ProfileMiniatureChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final double size;
  final double spacing;
  final bool isAddButton;

  const ProfileMiniatureChip({
    super.key,
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.size = 50,
    this.spacing = 15,
    this.isAddButton = false,
  });

  String _getImageUrl() {
    // Generate a consistent random number for each user
    int randomSeed;
    switch (label) {
      case 'alex_morgan':
        randomSeed = 101;
        break;
      case 'sophia.lee':
        randomSeed = 102;
        break;
      case 'james_walker':
        randomSeed = 103;
        break;
      case 'olivia_chen':
        randomSeed = 104;
        break;
      case 'ethan_brown':
        randomSeed = 105;
        break;
      case 'mia_patel':
        randomSeed = 106;
        break;
      case 'lucas_kim':
        randomSeed = 107;
        break;
      case 'emma_davis':
        randomSeed = 108;
        break;
      default:
        // Use the hash code of the label to generate a consistent random number
        randomSeed = label.hashCode.abs() % 1000;
    }
    return 'https://picsum.photos/150/150?random=$randomSeed';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: spacing),
        width: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile picture circle or add button
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAddButton ? Colors.transparent : Colors.white.withOpacity(0.15),
                border: isAddButton ? Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ) : null,
              ),
              child: isAddButton
                  ? Icon(
                      Icons.person_add,
                      color: Colors.white.withOpacity(0.7),
                      size: size * 0.5,
                    )
                  : ClipOval(
                      child: Image.network(
                        _getImageUrl(),
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: Colors.white,
                            size: size * 0.6,
                          );
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            // Username with shadow
            ShadowedText(
              text: label,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
