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
  bool _isLoading = true;
  static const _assetPath = 'assets/videos/teeem-logo-in.mp4.lottie.json';

  @override
  void initState() {
    super.initState();
    print('Initializing SplashScreen...');
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener(_handleAnimationStatus);
    _preloadAnimation();
  }

  Future<void> _preloadAnimation() async {
    try {
      print('Starting to preload animation...');
      if (!mounted) return;

      // Pre-load the composition to ensure it's in memory
      final composition = await AssetLottie(_assetPath).load();
      print('Animation loaded with duration: ${composition?.duration}');

      if (!mounted) return;

      if (composition != null) {
        _controller.duration = composition.duration;
        print('Controller duration set to: ${_controller.duration}');
      }

      setState(() {
        _isLoading = false;
      });
      print('Animation preload complete, ready to display');

    } catch (e) {
      print('Error pre-loading animation: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        _onAnimationComplete();
      }
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    print('Animation status changed to: $status');
    if (status == AnimationStatus.completed) {
      print('Animation completed, triggering navigation');
      _onAnimationComplete();
    }
  }

  void _onAnimationComplete() {
    try {
      if (!mounted) return;
      
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
    print('Disposing SplashScreen...');
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building SplashScreen, isLoading: $_isLoading, hasError: $_hasError');
    
    if (_hasError) {
      print('Has error, skipping animation...');
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 300,
            maxHeight: 300,
          ),
          child: Lottie.asset(
            _assetPath,
            controller: _controller,
            frameRate: FrameRate(30),
            repeat: false,
            onLoaded: (composition) {
              print('Lottie onLoaded called, duration: ${composition.duration}');
              _controller.duration = composition.duration;
              _controller.forward().then((_) {
                print('Animation forward complete');
              });
            },
            errorBuilder: (context, error, stackTrace) {
              print('Error rendering animation: $error');
              Future.microtask(() => _onAnimationComplete());
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
