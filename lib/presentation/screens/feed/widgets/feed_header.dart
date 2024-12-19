import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/traits/trait_type_model.dart';
import '../../../widgets/notifications/notification_icon.dart';
import '../controllers/feed_header_controller.dart';
import '../feed_bloc/feed_bloc.dart';
import '../feed_bloc/feed_event.dart';
import '../models/filter_type.dart';
import 'feed_search_bar.dart';
import 'filter_chips.dart';
import 'target_icon.dart';

import '../../../../data/models/traits/user_trait_model.dart';
import '../../../widgets/user_traits/user_trait_chip.dart';

class FeedHeader extends StatelessWidget {
  final FeedHeaderController headerController;

  const FeedHeader({
    super.key,
    required this.headerController,
  });

  void _handleSearch(BuildContext context, String query) {
    context.read<FeedBloc>().add(FeedSearchChanged(query));
  }

  Widget _buildSearchBar(BuildContext context) {
    if (!headerController.state.isSearchVisible || 
        headerController.state.activeFilterType == null) {
      return const SizedBox.shrink();
    }

    return FeedSearchBar(
      key: ValueKey(headerController.state.activeFilterType),
      filterType: headerController.state.activeFilterType!,
      onSearch: (query) => _handleSearch(context, query),
      onClose: headerController.closeSearch,
    );
  }

  Widget _buildTraitChips() {
    if (!headerController.state.isSearchVisible) {
      return const SizedBox.shrink();
    }

    // If no trait type is selected, show categories and trait types
    if (headerController.state.selectedTraitType == null) {
      final categories = headerController.traitTypes
          .map((t) => t.category)
          .toSet()
          .toList();

      return ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: headerController.traitTypes.length,
        itemBuilder: (context, index) {
          final traitType = headerController.traitTypes[index];
          return UserTraitChip(
            trait: UserTraitModel(
              id: traitType.id,
              traitTypeId: traitType.id,
              value: traitType.name,
              displayOrder: 0,
            ),
            traitType: traitType,
            isSelected: false,
            canEditType: false,
            canEditValue: true,
            onTraitValueEdit: (trait) {
              headerController.selectTraitValue(trait.value);
            },
            onTap: () => headerController.selectTraitType(traitType),
            spacing: 15,
          );
        },
      );
    }
    
    // If a trait type is selected, show its possible values
    final selectedType = headerController.state.selectedTraitType!;
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: selectedType.possibleValues.length + 1, // +1 for back button
      itemBuilder: (context, index) {
        if (index == 0) {
          // Back button as first chip
          return UserTraitChip(
            trait: UserTraitModel(
              id: 'back',
              traitTypeId: 'back',
              value: 'Back',
              displayOrder: 0,
            ),
            traitType: TraitTypeModel(
              id: 'back',
              name: '',
              iconData: 'e5c4', // arrow_back icon
              category: '',
              possibleValues: const [],
              displayOrder: 0,
            ),
            canEditType: false,
            canEditValue: true,
            onTraitValueEdit: (trait) {
              headerController.selectTraitValue(trait.value);
            },
            onTap: () => headerController.selectTraitType(null),
            spacing: 15,
          );
        }
        
        final value = selectedType.possibleValues[index - 1];
          return UserTraitChip(
            trait: UserTraitModel(
              id: selectedType.id,
              traitTypeId: selectedType.id,
              value: value,
              displayOrder: 0,
            ),
            traitType: selectedType,
            isSelected: false,
            canEditType: false,
            canEditValue: true,
            onTraitValueEdit: (trait) {
              headerController.selectTraitValue(trait.value);
            },
            onTap: () {
              // Handle value selection
              headerController.selectTraitValue(value);
            },
            spacing: 15,
        );
      },
    );
  }

  Widget _buildFilterChips() {
    if (!headerController.state.isSearchVisible || 
        headerController.state.activeFilterType == null) {
      return const SizedBox.shrink();
    }

    return FilterChipGroup(
      filterTypes: FilterType.values.where((t) => t != FilterType.none).toList(),
      selectedFilter: headerController.state.activeFilterType!,
      onFilterSelected: headerController.selectFilter,
    );
  }

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
                // Header row with buttons and search bar
                SizedBox(
                  height: 64,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Column: Notifications
                      SizedBox(
                        width: 56,
                        child: Center(
                          child: NotificationIcon(
                            notificationCount: 0,
                            onTap: headerController.toggleNotificationMenu,
                            isActive: headerController.state.isNotificationMenuOpen,
                          ),
                        ),
                      ),
                      
                      // Center Column: Search Bar
                      Expanded(
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  axis: Axis.horizontal,
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _buildSearchBar(context),
                            ),
                          ),
                        ),
                      ),
                      
                      // Right Column: Target Icon
                      SizedBox(
                        width: 56,
                        child: Center(
                          child: TargetIcon(
                            key: headerController.targetIconKey,
                            onTap: headerController.toggleSearch,
                            isActive: headerController.state.isSearchVisible,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Chips below header
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
                      // First row - Trait chips
                      SizedBox(
                        height: 35,
                        child: _buildTraitChips(),
                      ),
                      const SizedBox(height: 9), // Spacing between rows
                      // Second row - Filter chips
                      SizedBox(
                        height: 35,
                        child: _buildFilterChips(),
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
