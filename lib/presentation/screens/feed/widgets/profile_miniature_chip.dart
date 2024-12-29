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
    // Use different images for each individual
    switch (label) {
      case 'alex_morgan':
        return 'https://i.pravatar.cc/150?img=1';  // Professional looking man
      case 'sophia.lee':
        return 'https://i.pravatar.cc/150?img=5';  // Young woman with glasses
      case 'james_walker':
        return 'https://i.pravatar.cc/150?img=3';  // Casual style man
      case 'olivia_chen':
        return 'https://i.pravatar.cc/150?img=9';  // Creative looking woman
      case 'ethan_brown':
        return 'https://i.pravatar.cc/150?img=13'; // Business casual man
      case 'mia_patel':
        return 'https://i.pravatar.cc/150?img=10'; // Professional woman
      case 'lucas_kim':
        return 'https://i.pravatar.cc/150?img=15'; // Young professional man
      case 'emma_davis':
        return 'https://i.pravatar.cc/150?img=11'; // Friendly looking woman
      default:
        return 'https://i.pravatar.cc/150?img=7';
    }
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
