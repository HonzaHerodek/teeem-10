import '../../../../data/models/post_model.dart';
import '../../../../data/models/user_model.dart';
import '../models/filter_type.dart';

class FilterService {
  FilterType _currentFilter = FilterType.none;
  String _searchQuery = '';

  FilterType get currentFilter => _currentFilter;

  void setFilter(FilterType filter) {
    _currentFilter = filter;
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
  }

  List<PostModel> filterPosts(List<PostModel> posts, UserModel currentUser) {
    // Early return for empty posts
    if (posts.isEmpty) return [];

    // Pre-compute frequently used values
    final userInterests = currentUser.targetingCriteria?.interests ?? [];
    final userSkills = currentUser.targetingCriteria?.skills ?? [];
    final searchLower = _searchQuery.toLowerCase();
    final hasTargetingCriteria = currentUser.targetingCriteria != null;
    final userFollowingSet = Set<String>.from(currentUser.following);

    // First apply targeting criteria filter with pre-computed values
    var filteredPosts = posts.where((post) {
      // Check if post is active
      if (post.status != PostStatus.active) return false;

      // Check targeting criteria
      if (post.targetingCriteria != null && hasTargetingCriteria) {
        if (!post.isTargetedTo(currentUser.targetingCriteria!)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Then apply the selected filter type
    switch (_currentFilter) {
      // Individual profile filters
      case FilterType.individual1:
      case FilterType.individual2:
      case FilterType.individual3:
      case FilterType.individual4:
      case FilterType.individual5:
      case FilterType.individual6:
      case FilterType.individual7:
      case FilterType.individual8:
        // Filter posts by specific individual
        final targetUserId = _getUserIdForIndividual(_currentFilter);
        filteredPosts = filteredPosts.where((post) => post.userId == targetUserId).toList();
        break;

      // Group filters  
      case FilterType.group1:
      case FilterType.group2:
      case FilterType.group3:
        // Filter posts by group membership
        final groupId = _getGroupId(_currentFilter);
        filteredPosts = filteredPosts.where((post) {
          final group = post.aiMetadata?['group'] as String?;
          return group == groupId;
        }).toList();
        break;

      // Special relation filters
      case FilterType.similarToMe:
        // Early return if user has no traits
        if (userInterests.isEmpty && userSkills.isEmpty) {
          filteredPosts = [];
          break;
        }
        
        // Create sets for faster lookups
        final userInterestsSet = Set<String>.from(userInterests);
        final userSkillsSet = Set<String>.from(userSkills);
        
        filteredPosts = filteredPosts.where((post) {
          // Convert traits to a set for faster lookup
          final traitValues = post.userTraits.map((t) => t.value).toSet();
          return traitValues.any((value) => 
            userInterestsSet.contains(value) || userSkillsSet.contains(value)
          );
        }).toList();
        break;

      case FilterType.iRespondedTo:
        // Filter posts user has commented on
        filteredPosts = filteredPosts.where((post) => 
          post.comments.contains(currentUser.id)
        ).toList();
        break;

      case FilterType.iFollow:
        // Filter posts by followed users using pre-computed set
        filteredPosts = filteredPosts.where((post) => 
          userFollowingSet.contains(post.userId)
        ).toList();
        break;

      case FilterType.myFollowers:
        // Filter posts by followers
        filteredPosts = filteredPosts.where((post) {
          final postUser = _getUserById(post.userId);
          if (postUser == null) return false;
          return postUser.following.contains(currentUser.id);
        }).toList();
        break;

      case FilterType.traits:
        // Filter posts based on trait matching
        if (searchLower.isNotEmpty) {
          filteredPosts = filteredPosts.where((post) {
            // Pre-compute trait lists
            final interests = post.targetingCriteria?.interests ?? [];
            final skills = post.targetingCriteria?.skills ?? [];
            
            // Create a set for faster lookups
            final traits = {...interests, ...skills}.map((t) => t.toLowerCase()).toSet();
            
            return traits.any((trait) => trait.contains(searchLower));
          }).toList();
        }
        break;
      
      case FilterType.none:
      default:
        // Basic search if query exists
        if (searchLower.isNotEmpty) {
          filteredPosts = filteredPosts.where((post) {
            final title = post.title.toLowerCase();
            final description = post.description.toLowerCase();
            return title.contains(searchLower) || description.contains(searchLower);
          }).toList();
        }
        break;
    }

    return filteredPosts;
  }

  bool _shouldShowPost(PostModel post, UserModel currentUser) {
    // Check if post is active
    if (post.status != PostStatus.active) {
      return false;
    }

    // Check targeting criteria
    if (post.targetingCriteria != null &&
        currentUser.targetingCriteria != null) {
      if (!post.isTargetedTo(currentUser.targetingCriteria!)) {
        return false;
      }
    }

    return true;
  }

  String _getUserIdForIndividual(FilterType type) {
    // Map filter types to user IDs (implement based on your user ID system)
    switch (type) {
      case FilterType.individual1:
        return 'user1';
      case FilterType.individual2:
        return 'user2';
      case FilterType.individual3:
        return 'user3';
      case FilterType.individual4:
        return 'user4';
      case FilterType.individual5:
        return 'user5';
      case FilterType.individual6:
        return 'user6';
      case FilterType.individual7:
        return 'user7';
      case FilterType.individual8:
        return 'user8';
      default:
        throw Exception('Invalid individual filter type');
    }
  }

  String _getGroupId(FilterType type) {
    // Map filter types to group IDs (implement based on your group ID system)
    switch (type) {
      case FilterType.group1:
        return 'group1';
      case FilterType.group2:
        return 'group2';
      case FilterType.group3:
        return 'group3';
      default:
        throw Exception('Invalid group filter type');
    }
  }

  UserModel? _getUserById(String userId) {
    // TODO: Implement user lookup, possibly inject user repository
    return null;
  }
}
