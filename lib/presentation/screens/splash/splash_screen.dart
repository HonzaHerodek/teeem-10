import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../core/di/injection.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _loadAnimation();
  }

  Future<void> _loadAnimation() async {
    try {
      if (!mounted) return;
      
      // The animation will automatically play when loaded
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onAnimationComplete();
        }
      });
    } catch (e) {
      print('Error loading animation: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        _onAnimationComplete();
      }
    }
  }

  void _onAnimationComplete() {
    try {
      print('Animation complete, checking auth state...');
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;
      print('Current auth state: $authState');
      
      if (authState.isAuthenticated) {
        print('User is authenticated, navigating to feed...');
        getIt<NavigationService>().navigateToAndReplace(AppRoutes.feed);
      } else {
        print('User is not authenticated, navigating to login...');
        getIt<NavigationService>().navigateToAndReplace(AppRoutes.login);
      }
    } catch (e, stackTrace) {
      print('Error in _onAnimationComplete: $e');
      print('Stack trace: $stackTrace');
      // Try to navigate to login as fallback
      getIt<NavigationService>().navigateToAndReplace(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building SplashScreen...');
    if (_hasError) {
      print('Has error, skipping animation...');
      return const SizedBox.shrink(); // Error case: immediately proceed to next screen
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Builder(
          builder: (context) {
            try {
              return Lottie.asset(
                'assets/videos/teeem-logo-in.mp4.lottie.json',
                controller: _controller,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..forward();
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading animation: $error');
                  // Immediately navigate to next screen on error
                  Future.microtask(() => _onAnimationComplete());
                  return const CircularProgressIndicator();
                },
              );
            } catch (e) {
              print('Error in animation builder: $e');
              // Immediately navigate to next screen on error
              Future.microtask(() => _onAnimationComplete());
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
