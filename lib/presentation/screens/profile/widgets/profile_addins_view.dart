import 'package:flutter/material.dart';
import '../../../../data/models/profile_addins_model.dart';
import 'add_in_box.dart';

class ProfileAddInsView extends StatefulWidget {
  final ProfileAddInsModel addIns;
  final Function(ProfileAddInsModel) onAddInsChanged;

  const ProfileAddInsView({
    Key? key,
    required this.addIns,
    required this.onAddInsChanged,
  }) : super(key: key);

  @override
  State<ProfileAddInsView> createState() => _ProfileAddInsViewState();
}

class _ProfileAddInsViewState extends State<ProfileAddInsView> {
  String? _expandedAddInId;

  void _toggleAddInExpansion(String addInId) {
    setState(() {
      if (_expandedAddInId == addInId) {
        _expandedAddInId = null;
      } else {
        _expandedAddInId = addInId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.addIns.categories
              .map((category) => _buildCategory(category)),
        ],
      ),
    );
  }

  Widget _buildCategory(AddInCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            category.name,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _expandedAddInId != null &&
                  category.items.any((item) => item.id == _expandedAddInId)
              ? MediaQuery.of(context).size.height * 0.7
              : 180,
          child: Stack(
            children: [
              if (_expandedAddInId == null)
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black,
                      ],
                      stops: const [0.0, 0.05, 0.95, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstOut,
                  child: ListView.builder(
                    key: PageStorageKey('addins_${category.id}'),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: category.items.length,
                    itemBuilder: (context, index) {
                      final addIn = category.items[index];
                      return AddInBox(
                        key: ValueKey('addin_${addIn.id}'),
                        addIn: addIn,
                        isExpanded: false,
                        onToggleExpand: () => _toggleAddInExpansion(addIn.id),
                        onGet: () {
                          final updatedItems = category.items.map((item) {
                            if (item.id == addIn.id) {
                              return item.copyWith(enabled: true);
                            }
                            return item;
                          }).toList();

                          final updatedCategory =
                              category.copyWith(items: updatedItems);
                          final updatedCategories = widget.addIns.categories.map((c) {
                            if (c.id == category.id) {
                              return updatedCategory;
                            }
                            return c;
                          }).toList();

                          widget.onAddInsChanged(
                            widget.addIns.copyWith(categories: updatedCategories),
                          );
                        },
                      );
                    },
                  ),
                ),
              if (_expandedAddInId != null && category.items.any((item) => item.id == _expandedAddInId))
                Center(
                  child: AddInBox(
                    key: ValueKey('addin_expanded_${_expandedAddInId}'),
                    addIn: category.items.firstWhere((item) => item.id == _expandedAddInId),
                    isExpanded: true,
                    onToggleExpand: () => _toggleAddInExpansion(_expandedAddInId!),
                    onGet: () {
                      final addIn = category.items.firstWhere((item) => item.id == _expandedAddInId);
                      final updatedItems = category.items.map((item) {
                        if (item.id == addIn.id) {
                          return item.copyWith(enabled: true);
                        }
                        return item;
                      }).toList();

                      final updatedCategory =
                          category.copyWith(items: updatedItems);
                      final updatedCategories = widget.addIns.categories.map((c) {
                        if (c.id == category.id) {
                          return updatedCategory;
                        }
                        return c;
                      }).toList();

                      widget.onAddInsChanged(
                        widget.addIns.copyWith(categories: updatedCategories),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
