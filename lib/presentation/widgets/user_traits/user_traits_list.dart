import 'package:flutter/material.dart';
import '../../../data/models/traits/trait_type_model.dart';
import '../../../data/models/traits/user_trait_model.dart';
import 'expanding_trait_button.dart';
import 'expanding_search_button.dart';
import 'user_trait_chip.dart';

class UserTraitsList extends StatefulWidget {
  final List<TraitTypeModel> traitTypes;
  final List<UserTraitModel> traits;
  final Function(TraitTypeModel traitType, String value) onTraitSelected;
  final Function(TraitTypeModel traitType)? onTraitTypeEdit;
  final Function(UserTraitModel trait)? onTraitValueEdit;
  final double itemHeight;

  const UserTraitsList({
    super.key,
    required this.traitTypes,
    required this.traits,
    required this.onTraitSelected,
    this.onTraitTypeEdit,
    this.onTraitValueEdit,
    this.itemHeight = 35,
  });

  @override
  State<UserTraitsList> createState() => _UserTraitsListState();
}

class _UserTraitsListState extends State<UserTraitsList> {
  String _searchText = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<UserTraitModel> get _filteredTraits {
    if (_searchText.isEmpty) return widget.traits;
    return widget.traits.where((trait) {
      final traitType = widget.traitTypes.firstWhere(
        (t) => t.id == trait.traitTypeId,
        orElse: () => throw Exception('Trait type not found'),
      );
      return traitType.name.toLowerCase().contains(_searchText.toLowerCase()) ||
          trait.value.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();
  }

  Widget _buildSearchButton() {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      constraints: const BoxConstraints(
        minWidth: 48,
        maxWidth: 260,
      ),
      child: ExpandingSearchButton(
        height: widget.itemHeight,
        onSearch: (text) => setState(() => _searchText = text),
      ),
    );
  }

  Widget _buildAddTraitButton() {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      constraints: const BoxConstraints(
        minWidth: 48,
        maxWidth: 260,
      ),
      child: ExpandingTraitButton(
        traitTypes: widget.traitTypes,
        height: widget.itemHeight,
        onTraitSelected: widget.onTraitSelected,
      ),
    );
  }

  List<List<Widget>> _organizeTraitsInRows(BoxConstraints constraints) {
    final spacing = 15.0;
    final buttonWidth = 48.0 + spacing;
    final minItemWidth = 80.0;

    // Create trait widgets with dynamic widths based on content
    final traitWidgets = _filteredTraits.map((trait) {
      final traitType = widget.traitTypes.firstWhere(
        (t) => t.id == trait.traitTypeId,
        orElse: () => throw Exception('Trait type not found'),
      );

      // Calculate width based on longer of type name or value
      final typeTextSpan = TextSpan(
        text: traitType.name,
        style: const TextStyle(fontSize: 11),
      );
      final valueTextSpan = TextSpan(
        text: trait.value,
        style: const TextStyle(fontSize: 13),
      );
      final typeTextPainter = TextPainter(
        text: typeTextSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final valueTextPainter = TextPainter(
        text: valueTextSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      // Use the wider of the two texts
      final textWidth = typeTextPainter.width > valueTextPainter.width
          ? typeTextPainter.width
          : valueTextPainter.width;

      // Add padding and ensure minimum width
      // Icon width (height) + horizontal padding (24) + text width
      final contentWidth =
          (widget.itemHeight + 24 + textWidth).clamp(minItemWidth, 300.0);

      return UserTraitChip(
        trait: trait,
        traitType: traitType,
        width: contentWidth,
        height: widget.itemHeight,
        spacing: spacing,
        canEditType: true,
        canEditValue: true,
        onTraitTypeEdit: widget.onTraitTypeEdit,
        onTraitValueEdit: widget.onTraitValueEdit,
      );
    }).toList();

    // Calculate available widths for each row
    final firstRowWidth = constraints.maxWidth - buttonWidth;
    final secondRowWidth = constraints.maxWidth - buttonWidth;
    final thirdRowWidth = constraints.maxWidth;

    // Initialize rows
    List<List<Widget>> rows = [[], [], []];
    List<double> rowWidths = [0, 0, 0];
    var remainingTraits = [...traitWidgets];

    // Helper function to find best row for next trait
    int findBestRow(Widget trait) {
      final traitWidth =
          trait is UserTraitChip ? (trait.width ?? 0) + spacing : 0;

      // Check which row has enough space and would be most balanced
      for (int i = 0; i < 3; i++) {
        final maxWidth =
            i < 2 ? (i == 0 ? firstRowWidth : secondRowWidth) : thirdRowWidth;

        if (rowWidths[i] + traitWidth <= maxWidth) {
          return i;
        }
      }

      // If no row has enough space, find the one with most remaining space
      return rowWidths.indexOf(rowWidths.reduce((a, b) => a < b ? a : b));
    }

    // Distribute traits optimally
    while (remainingTraits.isNotEmpty) {
      final trait = remainingTraits.removeAt(0);
      final bestRow = findBestRow(trait);

      rows[bestRow].add(trait);
      if (trait is UserTraitChip) {
        rowWidths[bestRow] += (trait.width ?? 0) + spacing;
      }
    }

    return rows;
  }

  Widget _buildRow(List<Widget> traits, Widget? button) {
    return SizedBox(
      height: widget.itemHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (button != null) button,
          ...traits,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final traitRows = _organizeTraitsInRows(constraints);

        return NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow(traitRows[0], _buildSearchButton()),
                  const SizedBox(height: 9),
                  _buildRow(traitRows[1], _buildAddTraitButton()),
                  if (traitRows[2].isNotEmpty) ...[
                    const SizedBox(height: 9),
                    _buildRow(traitRows[2], null),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
