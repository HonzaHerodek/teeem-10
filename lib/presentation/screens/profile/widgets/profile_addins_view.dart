import 'package:flutter/material.dart';
import '../../../../data/models/profile_addins_model.dart';

class ProfileAddInsView extends StatelessWidget {
  final ProfileAddInsModel addIns;
  final Function(ProfileAddInsModel) onAddInsChanged;

  const ProfileAddInsView({
    Key? key,
    required this.addIns,
    required this.onAddInsChanged,
  }) : super(key: key);

  void _onItemToggled(String categoryId, String itemId, bool value) {
    final updatedCategories = addIns.categories.map((category) {
      if (category.id == categoryId) {
        final updatedItems = category.items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(enabled: value);
          }
          return item;
        }).toList();
        return category.copyWith(items: updatedItems);
      }
      return category;
    }).toList();

    onAddInsChanged(addIns.copyWith(categories: updatedCategories));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add-ins',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...addIns.categories.map((category) => _buildCategory(category)),
        ],
      ),
    );
  }

  Widget _buildCategory(AddInCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            category.name,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...category.items.map((item) => _buildItem(category.id, item)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildItem(String categoryId, AddInItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: item.enabled,
            onChanged: (value) => _onItemToggled(categoryId, item.id, value),
            activeColor: Colors.amber,
          ),
        ],
      ),
    );
  }
}
