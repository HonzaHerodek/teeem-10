import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../core/di/injection.dart';
import '../core/navigation/navigation_service.dart';
import '../core/navigation/navigation_service.dart' show AppRoutes, generateRoute;
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/user_repository.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'providers/background_color_provider.dart';
import 'providers/background_animation_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = getIt<NavigationService>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => getIt<BackgroundColorProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<BackgroundAnimationProvider>(),
        ),
        Provider<NavigationService>(
          create: (_) => navigationService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: getIt<AuthRepository>(),
              userRepository: getIt<UserRepository>(),
            )..add(const AuthStarted()),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigationService.navigatorKey,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: generateRoute,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
        ),
      ),
    );
  }
}
