import 'package:json_annotation/json_annotation.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final List<String> postIds;
  final List<String> likes;
  final String? parentId;
  final List<String> childrenIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.postIds,
    this.likes = const [],
    this.parentId,
    this.childrenIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    List<String>? postIds,
    List<String>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentId,
    List<String>? childrenIds,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      postIds: postIds ?? this.postIds,
      likes: likes ?? this.likes,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
