import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';
import '../models/targeting_model.dart';
import '../models/rating_model.dart';
import '../models/trophy_model.dart';
import '../models/traits/user_trait_model.dart';

@LazySingleton(as: UserRepository)
class MockUserRepository implements UserRepository {
  final Map<String, UserModel> _users = {};
  final _delay = const Duration(milliseconds: 500); // Simulate network delay

  MockUserRepository() {
    // Initialize with test data
    _initializeTestUsers();
  }

  void _initializeTestUsers() {
    // Create some test ratings
    final testRatings = [
      RatingModel(
        value: 4.5,
        userId: 'user_2',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      RatingModel(
        value: 5.0,
        userId: 'user_3',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      RatingModel(
        value: 4.0,
        userId: 'user_4',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // Create some test traits matching trait types from MockTraitRepository
    final testTraits = [
      const UserTraitModel(
        id: 'hair_1',
        traitTypeId: '1', // Hair Color trait type
        value: 'Brown',
        displayOrder: 0,
      ),
      const UserTraitModel(
        id: 'eye_1',
        traitTypeId: '2', // Eye Color trait type
        value: 'Blue',
        displayOrder: 1,
      ),
      const UserTraitModel(
        id: 'hobby_1',
        traitTypeId: '3', // Hobby trait type
        value: 'Gaming',
        displayOrder: 2,
      ),
    ];

    // Initialize the test user that matches mock_auth_repository
    final testUser = UserModel(
      id: 'user_1',
      username: 'Test User',
      email: 'test@example.com', // Match the debug login credentials
      profileImage: 'https://picsum.photos/150/150?random=1',
      bio: 'This is a test user account',
      followers: ['user_2', 'user_3'],
      following: ['user_2'],
      settings: {
        'notifications': true,
        'darkMode': false,
        'language': 'en',
      },
      targetingCriteria: TargetingCriteria(
        interests: ['coding', 'design', 'technology'],
        minAge: 18,
        maxAge: 65,
        languages: ['English'],
        experienceLevel: 'intermediate',
        skills: ['Flutter', 'Dart', 'Mobile Development'],
        industries: ['Technology', 'Software'],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastActive: DateTime.now(),
      ratings: testRatings,
      traits: testTraits,
    );

    _users[testUser.id] = testUser;

    // Add some additional test users
    for (var i = 2; i <= 5; i++) {
      final userId = 'user_$i';
      final ratings = List.generate(
        3,
        (index) => RatingModel(
          value: 3.0 + index.toDouble(),
          userId: 'user_${(i + index) % 5 + 1}',
          createdAt: DateTime.now().subtract(Duration(days: index)),
        ),
      );

      final user = UserModel(
        id: userId,
        username: 'User $i',
        email: 'user$i@example.com',
        profileImage: 'https://picsum.photos/150/150?random=$i',
        bio: 'This is the bio for User $i',
        followers: i % 2 == 0 ? ['user_1'] : [],
        following: i % 2 == 0 ? [] : ['user_1'],
        settings: {
          'notifications': true,
          'darkMode': false,
          'language': 'en',
        },
        targetingCriteria: TargetingCriteria(
          interests: ['general', 'learning'],
          languages: ['English'],
          experienceLevel: 'beginner',
        ),
        createdAt: DateTime.now().subtract(Duration(days: 30 - i)),
        lastActive: DateTime.now().subtract(Duration(minutes: i)),
        ratings: ratings,
      );

      _users[userId] = user;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(_delay);
    return _users['user_1']; // Return the test user
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    await Future.delayed(_delay);
    final user = _users[userId];
    print('Getting user $userId - traits: ${user?.traits.length}'); // Debug log
    if (user == null) {
      throw NotFoundException('User not found');
    }
    return user;
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await Future.delayed(_delay);
    if (!_users.containsKey(user.id)) {
      throw NotFoundException('User not found');
    }
    
    // Debug logs
    print('Updating user:');
    print('- ID: ${user.id}');
    print('- Current traits count: ${_users[user.id]?.traits.length}');
    print('- New traits count: ${user.traits.length}');
    print('- New traits: ${user.traits.map((t) => '${t.traitTypeId}:${t.value}').join(', ')}');
    
    // Update user
    _users[user.id] = user;
    
    // Verify the update
    final updatedUser = _users[user.id];
    print('Verified user traits after update: ${updatedUser?.traits.length}');
  }

  @override
  Future<void> followUser(String userId) async {
    await Future.delayed(_delay);
    final currentUserId = 'user_1'; // Mock current user
    if (!_users.containsKey(userId)) {
      throw NotFoundException('User not found');
    }

    final currentUser = _users[currentUserId];
    final targetUser = _users[userId];

    if (currentUser != null && targetUser != null) {
      _users[currentUserId] = currentUser.copyWith(
        following: [...currentUser.following, userId],
      );
      _users[userId] = targetUser.copyWith(
        followers: [...targetUser.followers, currentUserId],
      );
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    await Future.delayed(_delay);
    final currentUserId = 'user_1'; // Mock current user

    final currentUser = _users[currentUserId];
    final targetUser = _users[userId];

    if (currentUser != null && targetUser != null) {
      _users[currentUserId] = currentUser.copyWith(
        following: currentUser.following.where((id) => id != userId).toList(),
      );
      _users[userId] = targetUser.copyWith(
        followers:
            targetUser.followers.where((id) => id != currentUserId).toList(),
      );
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    await Future.delayed(_delay);
    final queryLower = query.toLowerCase();
    return _users.values.where((user) {
      return user.username.toLowerCase().contains(queryLower) ||
          user.email.toLowerCase().contains(queryLower);
    }).toList();
  }

  @override
  Stream<List<UserModel>> getFollowers(String userId) async* {
    await Future.delayed(_delay);
    final user = _users[userId];
    if (user != null) {
      yield user.followers
          .map((id) => _users[id])
          .whereType<UserModel>()
          .toList();
    } else {
      yield [];
    }
  }

  @override
  Stream<List<UserModel>> getFollowing(String userId) async* {
    await Future.delayed(_delay);
    final user = _users[userId];
    if (user != null) {
      yield user.following
          .map((id) => _users[id])
          .whereType<UserModel>()
          .toList();
    } else {
      yield [];
    }
  }

  @override
  Future<void> updateProfileImage(String imagePath) async {
    await Future.delayed(_delay);
    final currentUserId = 'user_1'; // Mock current user
    final user = _users[currentUserId];
    if (user != null) {
      _users[currentUserId] = user.copyWith(
        profileImage: 'https://picsum.photos/150/150?random=${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  @override
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    await Future.delayed(_delay);
    final currentUserId = 'user_1'; // Mock current user
    final user = _users[currentUserId];
    if (user != null) {
      _users[currentUserId] = user.copyWith(
        settings: {...user.settings ?? {}, ...settings},
      );
    }
  }

  @override
  Future<bool> checkUsername(String username) async {
    await Future.delayed(_delay);
    return !_users.values.any(
      (user) => user.username.toLowerCase() == username.toLowerCase(),
    );
  }

  @override
  Stream<UserModel> getUserStream(String userId) async* {
    await Future.delayed(_delay);
    final user = _users[userId];
    if (user == null) {
      throw NotFoundException('User not found');
    }
    yield user;
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(_delay);
    final currentUserId = 'user_1'; // Mock current user
    _users.remove(currentUserId);
  }

  @override
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    await Future.delayed(_delay);
    final currentUserId = 'user_1'; // Mock current user
    final user = _users[currentUserId];
    if (user != null) {
      final currentSettings = user.settings ?? {};
      _users[currentUserId] = user.copyWith(
        settings: {...currentSettings, 'notifications': settings},
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    await Future.delayed(_delay);
    final user = _users[userId];
    if (user == null) {
      throw NotFoundException('User not found');
    }

    return {
      'followers': user.followers.length,
      'following': user.following.length,
      'engagement': {
        'likes': 100,
        'comments': 50,
        'shares': 25,
      },
      'growth': {
        'followersGrowth': 10,
        'engagementGrowth': 15,
      },
    };
  }

  @override
  Future<List<Trophy>> getTrophies() async {
    await Future.delayed(_delay);
    try {
      return defaultTrophies;
    } catch (e) {
      throw AppException('Failed to fetch trophies');
    }
  }
}
