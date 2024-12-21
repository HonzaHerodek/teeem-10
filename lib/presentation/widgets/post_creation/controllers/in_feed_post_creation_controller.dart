import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../domain/repositories/post_repository.dart';
import '../../../../domain/repositories/step_type_repository.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/step_type_model.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_state.dart';
import '../models/post_creation_state.dart';

abstract class PostCreationController {
  Future<List<StepTypeModel>> loadStepTypes();
  Future<void> save([PostCreationState? state]);
}

class DefaultPostCreationController implements PostCreationController {
  final BuildContext context;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final GlobalKey<FormState> formKey;
  final Function(bool success) onComplete;
  
  final PostRepository _postRepository = getIt<PostRepository>();
  final StepTypeRepository _stepTypeRepository = getIt<StepTypeRepository>();

  DefaultPostCreationController({
    required this.context,
    required this.titleController,
    required this.descriptionController,
    required this.formKey,
    required this.onComplete,
  });

  @override
  Future<List<StepTypeModel>> loadStepTypes() async {
    try {
      return await _stepTypeRepository.getStepTypes();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load step types: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }

  @override
  Future<void> save([PostCreationState? state]) async {
    if (state == null) {
      throw Exception('State is required for saving');
    }

    if (!state.hasSteps) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one step'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!formKey.currentState!.validate() || !state.validateSteps()) {
      return;
    }

    try {
      final AuthState authState = context.read<AuthBloc>().state;
      if (!authState.isAuthenticated || authState.userId == null) {
        throw Exception('User not authenticated');
      }

      final steps = state.getValidSteps();
      final post = _createPostModel(authState, steps);
      await _postRepository.createPost(post);
      
      if (context.mounted) {
        onComplete(true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $e'),
            backgroundColor: Colors.red,
          ),
        );
        onComplete(false);
      }
    }
  }

  PostModel _createPostModel(AuthState authState, List<PostStep> steps) {
    return PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authState.userId!,
      username: authState.username ?? 'Anonymous',
      userProfileImage: 'https://i.pravatar.cc/150?u=${authState.userId}',
      title: titleController.text,
      description: descriptionController.text,
      steps: steps,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likes: [],
      comments: [],
      status: PostStatus.active,
      targetingCriteria: null,
      aiMetadata: {
        'tags': ['tutorial', 'multi-step'],
        'category': 'tutorial',
      },
      ratings: [],
      userTraits: [],
    );
  }
}
