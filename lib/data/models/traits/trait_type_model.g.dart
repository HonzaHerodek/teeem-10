// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trait_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TraitTypeModel _$TraitTypeModelFromJson(Map<String, dynamic> json) =>
    TraitTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconData: json['icon_data'] as String,
      category: json['category'] as String,
      possibleValues: (json['possibleValues'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TraitTypeModelToJson(TraitTypeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon_data': instance.iconData,
      'category': instance.category,
      'possibleValues': instance.possibleValues,
      'displayOrder': instance.displayOrder,
    };
