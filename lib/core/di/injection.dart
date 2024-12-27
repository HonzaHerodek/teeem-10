import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

Future<void> initializeDependencies() async {
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
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
    () => SharedPreferencesSettingsRepository(prefs),
  );
}
