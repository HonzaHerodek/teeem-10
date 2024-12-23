import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';

class StepFormData {
  final StepTypeModel stepType;
  final Map<String, dynamic> formData;

  StepFormData({
    required this.stepType,
    required this.formData,
  });

  // Validate the form data against the step type's options
  List<String> validate() {
    final List<String> errors = [];
    
    for (final option in stepType.options) {
      final value = formData[option.id];
      
      if (value == null || (value is String && value.isEmpty)) {
        errors.add('${option.label} is required');
        continue;
      }

      switch (option.type) {
        case 'number':
          if (value is! num) {
            errors.add('${option.label} must be a number');
          }
          // Check number constraints if specified in config
          if (option.config != null) {
            final num numValue = value as num;
            final dynamic minValue = option.config!['min'];
            final dynamic maxValue = option.config!['max'];
            
            if (minValue != null) {
              final num min = num.parse(minValue.toString());
              if (numValue < min) {
                errors.add('${option.label} must be at least $min');
              }
            }
            
            if (maxValue != null) {
              final num max = num.parse(maxValue.toString());
              if (numValue > max) {
                errors.add('${option.label} must be at most $max');
              }
            }
          }
          break;

        case 'select':
          final List<String> options = 
              (option.config?['options'] as List<dynamic>?)?.cast<String>() ?? [];
          if (!options.contains(value)) {
            errors.add('Invalid selection for ${option.label}');
          }
          break;

        case 'text':
          if (option.config != null) {
            final String strValue = value as String;
            final dynamic minLength = option.config!['minLength'];
            final dynamic maxLength = option.config!['maxLength'];
            
            if (minLength != null) {
              final int min = int.parse(minLength.toString());
              if (strValue.length < min) {
                errors.add('${option.label} must be at least $min characters');
              }
            }
            
            if (maxLength != null) {
              final int max = int.parse(maxLength.toString());
              if (strValue.length > max) {
                errors.add('${option.label} must be at most $max characters');
              }
            }
          }
          break;
      }
    }

    return errors;
  }
}
