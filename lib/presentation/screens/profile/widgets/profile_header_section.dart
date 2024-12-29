import 'package:flutter/material.dart';
import '../../../widgets/circular_action_button.dart';
import '../../../widgets/user_avatar.dart';
import '../../../widgets/rating_stars.dart';
import '../../../widgets/trophy_row.dart';
import '../profile_bloc/profile_state.dart';
import '../../../../data/models/trophy_model.dart';

class ProfileHeaderSection extends StatefulWidget {
  final ProfileState state;
  final VoidCallback onTraitsPressed;
  final VoidCallback onNetworkPressed;
  final bool showTraits;
  final bool showNetwork;

  const ProfileHeaderSection({
    Key? key,
    required this.state,
    required this.onTraitsPressed,
    required this.onNetworkPressed,
    required this.showTraits,
    required this.showNetwork,
  }) : super(key: key);

  @override
  State<ProfileHeaderSection> createState() => _ProfileHeaderSectionState();
}

class _ProfileHeaderSectionState extends State<ProfileHeaderSection> {
  bool _statsExpanded = false;
  bool _trophiesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.state.user;
    if (user == null) return const SizedBox.shrink();

    const profileSize = 130.0;
    // Calculate sliding panel width (75% of screen width)
    final screenWidth = MediaQuery.of(context).size.width;
    final slidingPanelWidth = screenWidth * 0.75;
    // Stars should be 80% of sliding panel width
    final starsWidth = slidingPanelWidth * 0.8;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        if (widget.state.ratingStats != null) ...[
          TrophyRow(
            trophies: defaultTrophies,
            onExpanded: (expanded) =>
                setState(() => _trophiesExpanded = expanded),
          ),
          if (_trophiesExpanded) const SizedBox(height: 16),
          if (!_trophiesExpanded)
            const SizedBox(height: 48),
          Center(
            child: SizedBox(
              width: starsWidth,
              child: RatingStars(
                rating: widget.state.ratingStats!.averageRating,
                size: 36,
                color: Colors.amber,
                frameWidth: starsWidth,
                sizeModifier: 0.2, // Maps to 1.2 size increase
                starSpacing: 3.6,
                curvature: 0.3,
                distribution: widget.state.ratingStats!.ratingDistribution,
                totalRatings: widget.state.ratingStats!.totalRatings,
                showRatingText: true,
                onExpanded: (expanded) => setState(() => _statsExpanded = expanded),
              ),
            ),
          ),
          if (_statsExpanded || _trophiesExpanded) const SizedBox(height: 16),
        ],
        Transform.translate(
          offset: const Offset(0, -15),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 300,
              maxHeight: profileSize,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularActionButton(
                  icon: Icons.psychology,
                  onPressed: widget.onTraitsPressed,
                  isSelected: widget.showTraits,
                ),
                const SizedBox(width: 20),
                UserAvatar(
                  imageUrl: user.profileImage,
                  name: user.username,
                  size: profileSize,
                ),
                const SizedBox(width: 20),
                CircularActionButton(
                  icon: Icons.people,
                  onPressed: widget.onNetworkPressed,
                  isSelected: widget.showNetwork,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
