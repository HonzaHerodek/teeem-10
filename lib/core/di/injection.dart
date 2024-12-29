import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/providers/background_color_provider.dart';
import '../../presentation/providers/background_animation_provider.dart';
import '../services/connectivity_service.dart';
import '../services/logger_service.dart';
import '../services/rating_service.dart';
import '../services/test_data_service.dart';
import '../navigation/navigation_service.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../data/repositories/mock_post_repository.dart';
import '../../data/repositories/mock_rating_service.dart';
import '../../data/repositories/mock_step_type_repository.dart';
import '../../data/repositories/mock_trait_repository.dart';
import '../../data/repositories/mock_user_repository.dart';
import '../../data/repositories/mock_project_repository.dart';
import '../../data/repositories/shared_preferences_settings_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/step_type_repository.dart';
import '../../domain/repositories/trait_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../presentation/screens/feed/services/filter_service.dart';

final getIt = GetIt.instance;

// Helper function to retry operations
Future<T> retry<T>(Future<T> Function() operation, {
  int maxAttempts = 3,
  Duration delay = const Duration(milliseconds: 500),
}) async {
  int attempts = 0;
  while (attempts < maxAttempts) {
    try {
      return await operation();
    } catch (e) {
      attempts++;
      if (attempts == maxAttempts) rethrow;
      debugPrint('Attempt $attempts failed, retrying in ${delay.inMilliseconds}ms...');
      await Future.delayed(delay);
    }
  }
  throw Exception('Failed after $maxAttempts attempts');
}

Future<void> initializeDependencies() async {
  
  // Services
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<LoggerService>(() => LoggerService());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<FilterService>(() => FilterService());
  getIt.registerLazySingleton<TestDataService>(() => TestDataService());
  getIt.registerLazySingleton<RatingService>(() => MockRatingService());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
  getIt.registerLazySingleton<PostRepository>(() => MockPostRepository());
  getIt.registerLazySingleton<StepTypeRepository>(() => MockStepTypeRepository());
  getIt.registerLazySingleton<UserRepository>(() => MockUserRepository());
  getIt.registerLazySingleton<ProjectRepository>(() => MockProjectRepository());
  getIt.registerLazySingleton<TraitRepository>(() => MockTraitRepository());
  getIt.registerLazySingleton<SettingsRepository>(
    () => SharedPreferencesSettingsRepository(),
  );
  
  // Providers
  getIt.registerLazySingleton(() => BackgroundColorProvider());
  getIt.registerLazySingleton(() => BackgroundAnimationProvider());
}
