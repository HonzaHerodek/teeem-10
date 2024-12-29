import '../../domain/repositories/trait_repository.dart';
import '../models/traits/trait_type_model.dart';
import '../models/traits/user_trait_model.dart';

import '../../domain/repositories/user_repository.dart';

class MockTraitRepository implements TraitRepository {
  final UserRepository _userRepository;

  MockTraitRepository(this._userRepository);
  // Mock data for trait types
  final List<TraitTypeModel> _traitTypes = [
    TraitTypeModel(
      id: '1',
      name: 'Hair Color',
      iconData: 'e318', // content_cut icon
      category: 'Physical',
      possibleValues: ['Blonde', 'Brown', 'Black', 'Red', 'Gray', 'White'],
      displayOrder: 1,
    ),
    TraitTypeModel(
      id: '2',
      name: 'Eye Color',
      iconData: 'e417', // remove_red_eye icon
      category: 'Physical',
      possibleValues: ['Blue', 'Green', 'Brown', 'Hazel', 'Gray'],
      displayOrder: 2,
    ),
    TraitTypeModel(
      id: '3',
      name: 'Hobby',
      iconData: 'e332', // sports_basketball icon
      category: 'Interests',
      possibleValues: ['Reading', 'Gaming', 'Sports', 'Music', 'Art', 'Cooking', 'Travel'],
      displayOrder: 3,
    ),
    TraitTypeModel(
      id: '4',
      name: 'Language',
      iconData: 'e8e2', // language icon
      category: 'Skills',
      possibleValues: ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'],
      displayOrder: 4,
    ),
    TraitTypeModel(
      id: '5',
      name: 'Pet',
      iconData: 'e91d', // pets icon
      category: 'Lifestyle',
      possibleValues: ['Dog', 'Cat', 'Bird', 'Fish', 'Hamster', 'None'],
      displayOrder: 5,
    ),
  ];

  // Mock data for user traits
  final Map<String, List<UserTraitModel>> _userTraits = {
    'test_user': [
      UserTraitModel(
        id: '1',
        traitTypeId: '1',
        value: 'Brown',
        displayOrder: 1,
      ),
      UserTraitModel(
        id: '2',
        traitTypeId: '2',
        value: 'Blue',
        displayOrder: 2,
      ),
      UserTraitModel(
        id: '3',
        traitTypeId: '3',
        value: 'Gaming',
        displayOrder: 3,
      ),
      UserTraitModel(
        id: '4',
        traitTypeId: '4',
        value: 'English',
        displayOrder: 4,
      ),
      UserTraitModel(
        id: '5',
        traitTypeId: '5',
        value: 'Dog',
        displayOrder: 5,
      ),
      UserTraitModel(
        id: '6',
        traitTypeId: '1',
        value: 'Black',
        displayOrder: 6,
      ),
      UserTraitModel(
        id: '7',
        traitTypeId: '3',
        value: 'Music',
        displayOrder: 7,
      ),
      UserTraitModel(
        id: '8',
        traitTypeId: '4',
        value: 'Spanish',
        displayOrder: 8,
      ),
      UserTraitModel(
        id: '9',
        traitTypeId: '5',
        value: 'Cat',
        displayOrder: 9,
      ),
      UserTraitModel(
        id: '10',
        traitTypeId: '3',
        value: 'Art',
        displayOrder: 10,
      ),
    ],
  };

  @override
  Future<List<TraitTypeModel>> getTraitTypes() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _traitTypes;
  }

  @override
  Future<List<UserTraitModel>> getUserTraits(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _userTraits[userId] ?? [];
  }

  @override
  Future<UserTraitModel> addUserTrait({
    required String userId,
    required String traitTypeId,
    required String value,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    print('MockTraitRepository - Adding trait:'); // Debug log
    print('- User ID: $userId');
    print('- Trait Type ID: $traitTypeId');
    print('- Value: $value');

    // Validate trait type exists
    final traitType = _traitTypes.firstWhere(
      (t) => t.id == traitTypeId,
      orElse: () => throw Exception('Trait type not found'),
    );

    print('MockTraitRepository - Found trait type: ${traitType.name}'); // Debug log

    // Validate value is allowed
    if (!traitType.possibleValues.contains(value)) {
      throw Exception('Invalid trait value');
    }

    // Create new trait
    final trait = UserTraitModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      traitTypeId: traitTypeId,
      value: value,
      displayOrder: (_userTraits[userId]?.length ?? 0) + 1,
    );

    try {
      // Add to user traits
      if (_userTraits.containsKey(userId)) {
        _userTraits[userId] = [..._userTraits[userId]!, trait];
      } else {
        _userTraits[userId] = [trait];
      }

      print('MockTraitRepository - Current traits for user:'); // Debug log
      print('- Count: ${_userTraits[userId]?.length}');
      print('- Traits: ${_userTraits[userId]?.map((t) => '${t.traitTypeId}:${t.value}').join(', ')}');

      // Update user model
      final user = await _userRepository.getUserById(userId);
      if (user != null) {
        final updatedUser = user.copyWith(traits: [...user.traits, trait]);
        await _userRepository.updateUser(updatedUser);
        print('MockTraitRepository - Updated user traits count: ${updatedUser.traits.length}'); // Debug log
      }

      return trait;
    } catch (e) {
      print('MockTraitRepository - Error adding trait: $e'); // Debug log
      // If updating user model fails, rollback trait addition
      _userTraits[userId]?.removeLast();
      rethrow;
    }
  }

  @override
  Future<void> removeUserTrait({
    required String userId,
    required String traitId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final traits = _userTraits[userId];
      if (traits != null) {
        final updatedTraits = traits.where((t) => t.id != traitId).toList();
        _userTraits[userId] = updatedTraits;

        // Update user model
        final user = await _userRepository.getUserById(userId);
        if (user != null) {
          await _userRepository.updateUser(
            user.copyWith(traits: updatedTraits)
          );
        }
      }
    } catch (e) {
      // If updating user model fails, rollback trait removal
      rethrow;
    }
  }

  @override
  Future<void> updateTraitOrder({
    required String userId,
    required List<String> traitIds,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final traits = _userTraits[userId];
      if (traits != null) {
        // Create a map of id to trait for quick lookup
        final traitMap = {for (var t in traits) t.id: t};
        
        // Create new list with updated order
        final updatedTraits = traitIds
            .map((id) => traitMap[id]?.copyWith(
                  displayOrder: traitIds.indexOf(id) + 1,
                ))
            .whereType<UserTraitModel>()
            .toList();

        _userTraits[userId] = updatedTraits;

        // Update user model
        final user = await _userRepository.getUserById(userId);
        if (user != null) {
          await _userRepository.updateUser(
            user.copyWith(traits: updatedTraits)
          );
        }
      }
    } catch (e) {
      // If updating user model fails, rollback trait order update
      rethrow;
    }
  }
}
