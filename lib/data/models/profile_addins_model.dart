class AddInItem {
  final String id;
  final String name;
  final String description;
  final bool enabled;

  const AddInItem({
    required this.id,
    required this.name,
    required this.description,
    this.enabled = false,
  });

  AddInItem copyWith({
    String? id,
    String? name,
    String? description,
    bool? enabled,
  }) {
    return AddInItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'enabled': enabled,
    };
  }

  factory AddInItem.fromJson(Map<String, dynamic> json) {
    return AddInItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      enabled: json['enabled'] as bool,
    );
  }
}

class AddInCategory {
  final String id;
  final String name;
  final List<AddInItem> items;

  const AddInCategory({
    required this.id,
    required this.name,
    required this.items,
  });

  AddInCategory copyWith({
    String? id,
    String? name,
    List<AddInItem>? items,
  }) {
    return AddInCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory AddInCategory.fromJson(Map<String, dynamic> json) {
    return AddInCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => AddInItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProfileAddInsModel {
  final List<AddInCategory> categories;

  const ProfileAddInsModel({
    this.categories = const [],
  });

  ProfileAddInsModel copyWith({
    List<AddInCategory>? categories,
  }) {
    return ProfileAddInsModel(
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }

  factory ProfileAddInsModel.fromJson(Map<String, dynamic> json) {
    return ProfileAddInsModel(
      categories: (json['categories'] as List<dynamic>)
          .map((category) => AddInCategory.fromJson(category as Map<String, dynamic>))
          .toList(),
    );
  }
}
