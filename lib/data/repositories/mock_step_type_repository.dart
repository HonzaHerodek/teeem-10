import '../../domain/repositories/step_type_repository.dart';
import '../models/step_type_model.dart';

class MockStepTypeRepository implements StepTypeRepository {
  final List<StepTypeModel> _stepTypes = [
    // Basic content types
    StepTypeModel(
      id: 'text',
      name: 'Text',
      description: 'A simple text step',
      icon: 'text_fields',
      color: '#4CAF50', // Green for text
      options: [
        StepTypeOption(
          id: 'text',
          label: 'Content',
          type: 'text',
          config: {'multiline': true},
        ),
      ],
    ),
    StepTypeModel(
      id: 'image',
      name: 'Image',
      description: 'An image with optional caption',
      icon: 'image',
      color: '#2196F3', // Blue for images
      options: [
        StepTypeOption(
          id: 'imageUrl',
          label: 'Image URL',
          type: 'text',
        ),
        StepTypeOption(
          id: 'caption',
          label: 'Caption',
          type: 'text',
        ),
      ],
    ),
    StepTypeModel(
      id: 'code',
      name: 'Code',
      description: 'A code snippet',
      icon: 'code',
      color: '#9C27B0', // Purple for code
      options: [
        StepTypeOption(
          id: 'code',
          label: 'Code',
          type: 'text',
          config: {
            'multiline': true,
            'monospace': true,
          },
        ),
        StepTypeOption(
          id: 'language',
          label: 'Language',
          type: 'select',
          config: {
            'options': [
              'javascript',
              'python',
              'java',
              'dart',
              'html',
              'css',
              'other',
            ],
          },
        ),
      ],
    ),
    StepTypeModel(
      id: 'video',
      name: 'Video',
      description: 'A video with optional description',
      icon: 'video_library',
      color: '#F44336', // Red for video
      options: [
        StepTypeOption(
          id: 'videoUrl',
          label: 'Video URL',
          type: 'text',
        ),
        StepTypeOption(
          id: 'description',
          label: 'Description',
          type: 'text',
          config: {'multiline': true},
        ),
      ],
    ),
    // Additional content types
    StepTypeModel(
      id: 'audio',
      name: 'Audio',
      description: 'An audio clip with transcript',
      icon: 'audiotrack',
      color: '#FF9800', // Orange for audio
      options: [
        StepTypeOption(
          id: 'audioUrl',
          label: 'Audio URL',
          type: 'text',
        ),
        StepTypeOption(
          id: 'transcript',
          label: 'Transcript',
          type: 'text',
          config: {'multiline': true},
        ),
      ],
    ),
    StepTypeModel(
      id: 'document',
      name: 'Document',
      description: 'A document file with summary',
      icon: 'description',
      color: '#795548', // Brown for documents
      options: [
        StepTypeOption(
          id: 'documentUrl',
          label: 'Document URL',
          type: 'text',
        ),
        StepTypeOption(
          id: 'summary',
          label: 'Summary',
          type: 'text',
          config: {'multiline': true},
        ),
      ],
    ),
    StepTypeModel(
      id: 'link',
      name: 'Link',
      description: 'A link with preview',
      icon: 'link',
      color: '#607D8B', // Blue grey for links
      options: [
        StepTypeOption(
          id: 'url',
          label: 'URL',
          type: 'text',
        ),
        StepTypeOption(
          id: 'preview',
          label: 'Preview Text',
          type: 'text',
          config: {'multiline': true},
        ),
      ],
    ),
    StepTypeModel(
      id: 'quiz',
      name: 'Quiz',
      description: 'A quiz with multiple choice questions',
      icon: 'quiz',
      color: '#009688', // Teal for quizzes
      options: [
        StepTypeOption(
          id: 'questions',
          label: 'Questions',
          type: 'array',
          config: {
            'item': {
              'type': 'object',
              'properties': {
                'question': {'type': 'text'},
                'options': {'type': 'array', 'item': {'type': 'text'}},
                'correctAnswer': {'type': 'number'},
              },
            },
          },
        ),
      ],
    ),
    // Immersive content types
    StepTypeModel(
      id: 'ar',
      name: 'AR',
      description: 'An augmented reality experience',
      icon: 'view_in_ar',
      color: '#00BCD4', // Cyan for AR
      options: [
        StepTypeOption(
          id: 'modelUrl',
          label: '3D Model URL',
          type: 'text',
        ),
        StepTypeOption(
          id: 'instructions',
          label: 'Instructions',
          type: 'text',
          config: {'multiline': true},
        ),
      ],
    ),
    StepTypeModel(
      id: 'vr',
      name: 'VR',
      description: 'A virtual reality experience',
      icon: 'vrpano',
      color: '#3F51B5', // Indigo for VR
      options: [
        StepTypeOption(
          id: 'sceneUrl',
          label: 'VR Scene URL',
          type: 'text',
        ),
        StepTypeOption(
          id: 'instructions',
          label: 'Instructions',
          type: 'text',
          config: {'multiline': true},
        ),
      ],
    ),
    // Interactive Step Types
    StepTypeModel(
      id: 'share_material',
      name: 'Share Material',
      description: 'Share various types of material',
      icon: 'share',
      color: '#E91E63', // Pink for sharing
      options: [
        StepTypeOption(
          id: 'materialType',
          label: 'Material Type',
          type: 'select',
          config: {
            'options': ['text', 'link', 'image', 'video'],
          },
        ),
        StepTypeOption(
          id: 'allowMultiple',
          label: 'Allow Multiple Responses',
          type: 'boolean',
        ),
      ],
    ),
    StepTypeModel(
      id: 'share_location',
      name: 'Share Location',
      description: 'Share location or route',
      icon: 'location_on',
      color: '#FF5722', // Deep Orange for location
      options: [
        StepTypeOption(
          id: 'isRoute',
          label: 'Share Route',
          type: 'boolean',
        ),
        StepTypeOption(
          id: 'requiredLocation',
          label: 'Required Location',
          type: 'location',
        ),
        StepTypeOption(
          id: 'trackingTime',
          label: 'Tracking Time',
          type: 'number',
        ),
      ],
    ),
    StepTypeModel(
      id: 'select',
      name: 'Select',
      description: 'Selection from multiple options',
      icon: 'check_box',
      color: '#9C27B0', // Purple for selection
      options: [
        StepTypeOption(
          id: 'options',
          label: 'Options',
          type: 'array',
          config: {
            'item': {
              'type': 'object',
              'properties': {
                'content': {'type': 'text'},
                'type': {'type': 'select', 'options': ['text', 'image', 'video', 'link']},
              },
            },
          },
        ),
        StepTypeOption(
          id: 'allowMultiple',
          label: 'Allow Multiple Selections',
          type: 'boolean',
        ),
      ],
    ),
    StepTypeModel(
      id: 'share_out',
      name: 'Share Out',
      description: 'Share to external platforms',
      icon: 'share',
      color: '#00BCD4', // Cyan for external sharing
      options: [
        StepTypeOption(
          id: 'platform',
          label: 'Platform',
          type: 'select',
          config: {
            'options': ['Facebook', 'Instagram', 'Email', 'WhatsApp', 'Slack'],
          },
        ),
        StepTypeOption(
          id: 'requireLink',
          label: 'Require Link',
          type: 'boolean',
        ),
      ],
    ),
    StepTypeModel(
      id: 'download',
      name: 'Download',
      description: 'Download file',
      icon: 'download',
      color: '#4CAF50', // Green for download
      options: [
        StepTypeOption(
          id: 'fileUrl',
          label: 'File URL',
          type: 'text',
        ),
        StepTypeOption(
          id: 'allowMultiple',
          label: 'Allow Multiple Downloads',
          type: 'boolean',
        ),
      ],
    ),
    StepTypeModel(
      id: 'upload',
      name: 'Upload',
      description: 'Upload file',
      icon: 'upload',
      color: '#FF9800', // Orange for upload
      options: [
        StepTypeOption(
          id: 'fileType',
          label: 'Required File Type',
          type: 'select',
          config: {
            'options': ['text', 'image', 'video', 'document'],
          },
        ),
        StepTypeOption(
          id: 'allowMultiple',
          label: 'Allow Multiple Files',
          type: 'boolean',
        ),
      ],
    ),
    // Admin Step Types
    StepTypeModel(
      id: 'task_author_approval',
      name: 'Task Author Approval',
      description: 'Approval by task author',
      icon: 'admin_panel_settings',
      color: '#673AB7', // Deep Purple for admin
      options: [
        StepTypeOption(
          id: 'approvedMaterial',
          label: 'Approved Material',
          type: 'select',
          config: {
            'options': ['share_material', 'share_location'],
          },
        ),
        StepTypeOption(
          id: 'autoApprove',
          label: 'Automatic Approval',
          type: 'boolean',
        ),
      ],
    ),
    StepTypeModel(
      id: 'respondent_approval',
      name: 'Respondent Approval',
      description: 'Approval by respondents',
      icon: 'how_to_vote',
      color: '#2196F3', // Blue for voting
      options: [
        StepTypeOption(
          id: 'approvedMaterial',
          label: 'Approved Material',
          type: 'select',
          config: {
            'options': ['text', 'image', 'location'],
          },
        ),
        StepTypeOption(
          id: 'publicApproval',
          label: 'Public Approval',
          type: 'boolean',
        ),
      ],
    ),
    StepTypeModel(
      id: 'conditional_route',
      name: 'Conditional Route',
      description: 'Route based on conditions',
      icon: 'route',
      color: '#795548', // Brown for routing
      options: [
        StepTypeOption(
          id: 'previousActivity',
          label: 'Activity on Previous Step',
          type: 'select',
        ),
        StepTypeOption(
          id: 'previousValue',
          label: 'Value on Previous Step',
          type: 'select',
        ),
        StepTypeOption(
          id: 'repeatable',
          label: 'Users Can Repeat',
          type: 'boolean',
        ),
      ],
    ),
  ];

  @override
  Future<List<StepTypeModel>> getStepTypes() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _stepTypes;
  }

  @override
  Future<StepTypeModel> getStepTypeById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _stepTypes.firstWhere(
      (type) => type.id == id,
      orElse: () => throw Exception('Step type not found'),
    );
  }

  @override
  Future<void> createStepType(StepTypeModel stepType) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (_stepTypes.any((type) => type.id == stepType.id)) {
      throw Exception('Step type with this ID already exists');
    }

    _stepTypes.add(stepType);
  }

  @override
  Future<void> updateStepType(StepTypeModel stepType) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _stepTypes.indexWhere((type) => type.id == stepType.id);
    if (index == -1) {
      throw Exception('Step type not found');
    }

    _stepTypes[index] = stepType;
  }

  @override
  Future<void> deleteStepType(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _stepTypes.indexWhere((type) => type.id == id);
    if (index == -1) {
      throw Exception('Step type not found');
    }

    _stepTypes.removeAt(index);
  }
}
