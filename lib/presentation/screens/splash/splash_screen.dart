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
    final authState = context.read<AuthBloc>().state;
    if (authState.isAuthenticated) {
      getIt<NavigationService>().navigateToAndReplace(AppRoutes.feed);
    } else {
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
    if (_hasError) {
      return const SizedBox.shrink(); // Error case: immediately proceed to next screen
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Lottie.asset(
          'assets/videos/teeem-logo-in.mp4.lottie.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
          },
        ),
      ),
    );
  }
}
