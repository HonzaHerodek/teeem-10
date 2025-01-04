import '../../data/models/post_model.dart';
import '../../data/models/rating_model.dart';
import '../../data/models/traits/trait_type_model.dart';
import '../../data/models/traits/user_trait_model.dart';
import '../../domain/repositories/trait_repository.dart';
import 'dart:math';

class TestDataService {
  static final Random _random = Random();
  static List<TraitTypeModel> _cachedTraitTypes = [];
  static late TraitRepository _traitRepository;

  TestDataService();

  static Future<void> initialize() async {
    try {
      // Initialize with empty data first
      _cachedTraitTypes = [];
      
      // Delay trait loading until after dependency injection is complete
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Now try to load traits
      _cachedTraitTypes = await _traitRepository.getTraitTypes();
    } catch (e) {
      print('Warning: Failed to initialize test data service: $e');
      // Continue with empty trait types rather than crashing
      _cachedTraitTypes = [];
    }
  }

  static void setTraitRepository(TraitRepository repository) {
    _traitRepository = repository;
  }

  static const String _longText = '''
Flutter is an open-source UI software development kit created by Google. It is used to develop cross-platform applications from a single codebase for any web browser, Fuchsia, Android, iOS, Linux, macOS, and Windows.

Key Features of Flutter:
[... rest of the text ...]
''';

  static List<PostModel> generateTestPosts({int count = 10}) {
    return List.generate(count, (index) {
      final id = 'post_$index';
      final userId = index % 3 == 0 ? 'user_1' : 'user_${2 + (index % 3)}';
      final username =
          userId == 'user_1' ? 'Test User' : 'User ${2 + (index % 3)}';

      final ratings = List.generate(
        3,
        (rIndex) => RatingModel(
          value: 3.0 + (rIndex % 3),
          userId: 'user_${rIndex + 2}',
          createdAt: DateTime.now().subtract(Duration(days: rIndex)),
        ),
      );

      // Use cached trait types safely
      final selectedTraitTypes = _cachedTraitTypes.take(3).toList();
      final userTraits = selectedTraitTypes.map((type) => UserTraitModel(
        id: 'trait_${type.id}',
        traitTypeId: type.id,
        value: type.possibleValues.first,
        displayOrder: selectedTraitTypes.indexOf(type),
      )).toList();

      return PostModel(
        id: id,
        userId: userId,
        username: username,
        userProfileImage: 'https://i.pravatar.cc/150?u=$userId',
        title: 'Test Post $index',
        description: 'Test description for post $index',
        steps: generateTestSteps(count: 5 + _random.nextInt(3)),
        createdAt: DateTime.now().subtract(Duration(days: index)),
        likes: List.generate(index, (i) => 'user_${2 + (i % 3)}'),
        comments: List.generate(index ~/ 2, (i) => 'comment_$i'),
        status: PostStatus.active,
        ratings: ratings,
        userTraits: userTraits,
        updatedAt: DateTime.now().subtract(Duration(days: index)),
      );
    });
  }

  static PostModel generateLongTestPost() {
    const userId = 'user_1';
    final ratings = List.generate(
      3,
      (rIndex) => RatingModel(
        value: 4.0 + (rIndex % 2),
        userId: 'user_${rIndex + 2}',
        createdAt: DateTime.now().subtract(Duration(days: rIndex)),
      ),
    );

    // Use cached trait types safely
    final userTraits = _cachedTraitTypes.map((type) => UserTraitModel(
      id: 'trait_${type.id}',
      traitTypeId: type.id,
      value: type.possibleValues.first,
      displayOrder: _cachedTraitTypes.indexOf(type),
    )).toList();

    return PostModel(
      id: 'long_test_post',
      userId: userId,
      username: 'Test User',
      userProfileImage: 'https://i.pravatar.cc/150?u=$userId',
      title: 'Complete Programming Tutorial',
      description: 'A comprehensive guide with 20 detailed steps',
      steps: generateDetailedSteps(),
      createdAt: DateTime.now(),
      likes: List.generate(10, (i) => 'user_${2 + (i % 3)}'),
      comments: List.generate(5, (i) => 'comment_$i'),
      status: PostStatus.active,
      ratings: ratings,
      userTraits: userTraits,
      updatedAt: DateTime.now(),
    );
  }

  static List<PostStep> generateTestSteps({int count = 3}) {
    final allStepTypes = StepType.values.toList();
    allStepTypes.shuffle(_random);

    return List.generate(count, (index) {
      final stepType = allStepTypes[index % allStepTypes.length];
      final content = <String, dynamic>{};
      final stepNumber = index + 1;

      switch (stepType) {
        case StepType.text:
          content['text'] = index % 3 == 0 ? _longText : 
              'This is step $stepNumber with text content explaining the process.';
          break;
        case StepType.image:
          content['imageUrl'] = 'https://picsum.photos/500/300?random=step_$index';
          content['caption'] = 'Image caption for step $stepNumber';
          break;
        case StepType.code:
          content['code'] = '''void main() {
  print("Hello from step $stepNumber!");
}''';
          content['language'] = 'dart';
          break;
        default:
          content['text'] = 'Content for step $stepNumber';
          break;
      }

      return PostStep(
        id: 'step_$index',
        title: 'Step $stepNumber',
        description: 'This is step $stepNumber',
        type: stepType,
        content: content,
      );
    });
  }

  static List<PostStep> generateDetailedSteps() {
    return List.generate(20, (index) {
      final stepNumber = index + 1;
      return PostStep(
        id: 'step_$index',
        title: 'Step $stepNumber',
        description: 'Detailed step $stepNumber',
        type: StepType.text,
        content: {'text': 'Content for step $stepNumber\n\n$_longText'},
      );
    });
  }

  static Map<String, dynamic> generateTestAnalytics() {
    return {
      'totalViews': 1000,
      'totalLikes': 500,
      'totalComments': 250,
      'averageRating': 4.5,
      'totalPosts': 25,
      'topCategories': [
        {'name': 'Physical', 'count': 10},
        {'name': 'Interests', 'count': 8},
      ],
      'engagement': {
        'daily': 85,
        'weekly': 450,
        'monthly': 1800,
      },
      'userGrowth': {
        'followers': 300,
        'following': 250,
      },
    };
  }
}
