class AddInItem {
  final String id;
  final String name;
  final String description;
  final String detailedDescription;
  final String symbol;
  final bool enabled;
  final List<String> features;
  final String version;
  final String publisher;

  const AddInItem({
    required this.id,
    required this.name,
    required this.description,
    required this.detailedDescription,
    required this.symbol,
    this.enabled = false,
    this.features = const [],
    this.version = '1.0.0',
    this.publisher = '',
  });

  AddInItem copyWith({
    String? id,
    String? name,
    String? description,
    String? detailedDescription,
    String? symbol,
    bool? enabled,
    List<String>? features,
    String? version,
    String? publisher,
  }) {
    return AddInItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      symbol: symbol ?? this.symbol,
      enabled: enabled ?? this.enabled,
      features: features ?? this.features,
      version: version ?? this.version,
      publisher: publisher ?? this.publisher,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'detailedDescription': detailedDescription,
      'symbol': symbol,
      'enabled': enabled,
      'features': features,
      'version': version,
      'publisher': publisher,
    };
  }

  factory AddInItem.fromJson(Map<String, dynamic> json) {
    return AddInItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      detailedDescription: json['detailedDescription'] as String,
      symbol: json['symbol'] as String,
      enabled: json['enabled'] as bool,
      features: (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      version: json['version'] as String,
      publisher: json['publisher'] as String,
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
