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
  final List<String> childProjectIds;
  final List<String> parentProjectIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.postIds,
    this.likes = const [],
    required this.createdAt,
    required this.updatedAt,
    this.childProjectIds = const [],
    this.parentProjectIds = const [],
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
    List<String>? childProjectIds,
    List<String>? parentProjectIds,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      postIds: postIds ?? this.postIds,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      childProjectIds: childProjectIds ?? this.childProjectIds,
      parentProjectIds: parentProjectIds ?? this.parentProjectIds,
    );
  }
}
