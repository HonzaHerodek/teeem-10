// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_trait_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTraitModel _$UserTraitModelFromJson(Map<String, dynamic> json) =>
    UserTraitModel(
      id: json['id'] as String,
      traitTypeId: json['trait_type_id'] as String,
      value: json['value'] as String,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserTraitModelToJson(UserTraitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trait_type_id': instance.traitTypeId,
      'value': instance.value,
      'displayOrder': instance.displayOrder,
    };
