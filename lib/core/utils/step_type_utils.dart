import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';

class StepTypeUtils {
  static Color getColorForStepType(StepType type) {
    switch (type) {
      // Consuming Step Types
      case StepType.text:
        return const Color(0xFF4CAF50); // Material Green 500
      case StepType.image:
        return const Color(0xFF2196F3); // Material Blue 500
      case StepType.video:
        return const Color(0xFFF44336); // Material Red 500
      case StepType.audio:
        return const Color(0xFFFF9800); // Material Orange 500
      case StepType.document:
        return const Color(0xFF9E9E9E); // Material Grey 500
      case StepType.link:
        return const Color(0xFF3F51B5); // Material Indigo 500
      case StepType.code:
        return const Color(0xFF9C27B0); // Material Purple 500
      case StepType.vr:
        return const Color(0xFF607D8B); // Material Blue Grey 500
      case StepType.ar:
        return const Color(0xFF795548); // Material Brown 500

      // Interactive Step Types
      case StepType.shareMaterial:
        return const Color(0xFFE91E63); // Material Pink 500
      case StepType.shareLocation:
        return const Color(0xFFFF5722); // Material Deep Orange 500
      case StepType.select:
        return const Color(0xFF673AB7); // Material Deep Purple 500
      case StepType.quiz:
        return const Color(0xFF00BCD4); // Material Cyan 500
      case StepType.shareOut:
        return const Color(0xFF009688); // Material Teal 500
      case StepType.download:
        return const Color(0xFF8BC34A); // Material Light Green 500
      case StepType.upload:
        return const Color(0xFFCDDC39); // Material Lime 500

      // Admin Step Types
      case StepType.taskAuthorApproval:
        return const Color(0xFF5D4037); // Material Brown 700
      case StepType.respondentApproval:
        return const Color(0xFF455A64); // Material Blue Grey 700
      case StepType.conditionalRoute:
        return const Color(0xFF424242); // Material Grey 800

      default:
        return Colors.grey;
    }
  }

  static String getStepTypeDisplayName(StepType type) {
    switch (type) {
      // Consuming Step Types
      case StepType.text:
        return 'Text';
      case StepType.image:
        return 'Image';
      case StepType.video:
        return 'Video';
      case StepType.audio:
        return 'Audio';
      case StepType.document:
        return 'Document';
      case StepType.link:
        return 'Link';
      case StepType.code:
        return 'Code';
      case StepType.vr:
        return 'VR';
      case StepType.ar:
        return 'AR';

      // Interactive Step Types
      case StepType.shareMaterial:
        return 'Share Material';
      case StepType.shareLocation:
        return 'Share Location';
      case StepType.select:
        return 'Select';
      case StepType.quiz:
        return 'Quiz';
      case StepType.shareOut:
        return 'Share Out';
      case StepType.download:
        return 'Download';
      case StepType.upload:
        return 'Upload';

      // Admin Step Types
      case StepType.taskAuthorApproval:
        return 'Task Author Approval';
      case StepType.respondentApproval:
        return 'Respondent Approval';
      case StepType.conditionalRoute:
        return 'Conditional Route';

      default:
        return 'Unknown';
    }
  }

  static IconData getIconForStepType(StepType type) {
    switch (type) {
      // Consuming Step Types
      case StepType.text:
        return Icons.text_fields;
      case StepType.image:
        return Icons.image;
      case StepType.video:
        return Icons.videocam;
      case StepType.audio:
        return Icons.audiotrack;
      case StepType.document:
        return Icons.description;
      case StepType.link:
        return Icons.link;
      case StepType.code:
        return Icons.code;
      case StepType.vr:
        return Icons.vrpano;
      case StepType.ar:
        return Icons.view_in_ar;

      // Interactive Step Types
      case StepType.shareMaterial:
        return Icons.share;
      case StepType.shareLocation:
        return Icons.location_on;
      case StepType.select:
        return Icons.check_box;
      case StepType.quiz:
        return Icons.quiz;
      case StepType.shareOut:
        return Icons.share;
      case StepType.download:
        return Icons.download;
      case StepType.upload:
        return Icons.upload;

      // Admin Step Types
      case StepType.taskAuthorApproval:
        return Icons.admin_panel_settings;
      case StepType.respondentApproval:
        return Icons.how_to_vote;
      case StepType.conditionalRoute:
        return Icons.route;

      default:
        return Icons.help_outline;
    }
  }
}
