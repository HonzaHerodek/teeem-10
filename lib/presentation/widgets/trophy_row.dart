import 'package:flutter/material.dart';
import '../../data/models/trophy_model.dart';

class TrophyRow extends StatefulWidget {
  final List<Trophy> trophies;
  final Function(bool)? onExpanded;

  const TrophyRow({
    Key? key,
    required this.trophies,
    this.onExpanded,
  }) : super(key: key);

  @override
  State<TrophyRow> createState() => _TrophyRowState();
}

class _TrophyRowState extends State<TrophyRow>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _isHandlingTap = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    // Add listener to debug state changes
    _controller.addStatusListener((status) {
      print('Animation status: $status');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_expanded) {
      widget.onExpanded?.call(false);
    }
    super.dispose();
  }

  Widget _buildTrophyIcon(Trophy trophy, {double size = 24.0}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: trophy.isAchieved
            ? [
                BoxShadow(
                  color: trophy.color.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.grey[800],
            size: size,
          ),
          if (trophy.isAchieved)
            Icon(
              Icons.emoji_events,
              color: trophy.color.withOpacity(0.9),
              size: size,
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String category) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        category,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 11,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTrophyRow() {
    if (widget.trophies.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get achieved and unachieved trophies
    final allAchieved = widget.trophies.where((t) => t.isAchieved).toList();
    final allUnachieved = widget.trophies.where((t) => !t.isAchieved).toList();

    // Take up to 3 achieved trophies for the middle
    final achievedTrophies = allAchieved.take(3).toList();
    final achievedCount = achievedTrophies.length;

    // Calculate how many unachieved trophies we can show on each side
    final sideSpaces = (9 - achievedCount) ~/ 2;
    final leftUnachieved = allUnachieved.take(sideSpaces).toList();
    final rightUnachieved =
        allUnachieved.skip(sideSpaces).take(sideSpaces).toList();

    // Calculate remaining count
    final shownCount =
        achievedCount + leftUnachieved.length + rightUnachieved.length;
    final remainingCount = widget.trophies.length - shownCount;

    return Center(
      child: SizedBox(
        width: 300, // Fixed width
        child: Stack(
          children: [
            // Scrollable trophy row with padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Left grey trophies
                    ...leftUnachieved.map(
                      (trophy) => Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: _buildTrophyIcon(trophy, size: 20),
                      ),
                    ),
                    if (achievedCount > 0)
                      const SizedBox(
                          width: 6), // Spacing before colored trophies
                    // Center colored trophies
                    ...achievedTrophies.map(
                      (trophy) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _buildTrophyIcon(trophy, size: 28),
                      ),
                    ),
                    if (achievedCount > 0)
                      const SizedBox(
                          width: 6), // Spacing after colored trophies
                    // Right grey trophies
                    ...rightUnachieved.map(
                      (trophy) => Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: _buildTrophyIcon(trophy, size: 20),
                      ),
                    ),
                    // Space for the counter
                    if (remainingCount > 0) const SizedBox(width: 28),
                  ],
                ),
              ),
            ),
            // Fixed position remaining count (no background)
            if (remainingCount > 0)
              Positioned(
                right: 16, // Align with padding
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedTrophies() {
    if (widget.trophies.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, List<Trophy>> categorizedTrophies = {};
    for (var trophy in widget.trophies) {
      if (!categorizedTrophies.containsKey(trophy.category)) {
        categorizedTrophies[trophy.category] = [];
      }
      categorizedTrophies[trophy.category]!.add(trophy);
    }

    // Remove empty categories
    categorizedTrophies.removeWhere((_, trophies) => trophies.isEmpty);

    if (categorizedTrophies.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final rowWidth = constraints.maxWidth - 32;
        final cardWidth = (rowWidth / 2.5).floor().toDouble();

        return Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var category in categorizedTrophies.keys) ...[
                  _buildCategoryHeader(category),
                  SizedBox(
                    height: 140, // Fixed height for horizontal scroll container
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        ...categorizedTrophies[category]!.map(
                          (trophy) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SizedBox(
                              width: cardWidth,
                              child: _buildTrophyCard(trophy),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrophyCard(Trophy trophy) {
    return Card(
      elevation: trophy.isAchieved ? 4 : 1,
      color: trophy.isAchieved
          ? Color.lerp(Colors.black, trophy.color, 0.15)
          : Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: trophy.isAchieved
                    ? Color.lerp(Colors.black, trophy.color, 0.2)
                    : Colors.black26,
                shape: BoxShape.circle,
                boxShadow: trophy.isAchieved
                    ? [
                        BoxShadow(
                          color: trophy.color.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: _buildTrophyIcon(trophy, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              trophy.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: trophy.isAchieved ? trophy.color : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              trophy.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        trophy.isAchieved ? Colors.white70 : Colors.grey[600],
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap() async {
    if (_isHandlingTap || !mounted) return;
    _isHandlingTap = true;

    final willExpand = !_expanded;
    
    try {
      // Update local state first
      setState(() {
        _expanded = willExpand;
      });
      
      // Start animation
      if (willExpand) {
        await _controller.forward();
      } else {
        await _controller.reverse();
      }
      
      // Notify parent after animation completes
      if (mounted) {
        widget.onExpanded?.call(willExpand);
      }
    } catch (e) {
      print('Error handling trophy tap: $e');
      // Revert state on error
      if (mounted) {
        setState(() {
          _expanded = !willExpand;
        });
      }
    } finally {
      if (mounted) {
        _isHandlingTap = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _handleTap,
            child: _buildTrophyRow(),
          ),
          ClipRect(
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              child: _expanded ? _buildExpandedTrophies() : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
