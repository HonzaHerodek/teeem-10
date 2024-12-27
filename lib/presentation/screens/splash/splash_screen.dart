import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../core/di/injection.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      // Pre-cache the video file
      final videoBytes = await rootBundle.load('assets/videos/teeem-logo-in.mp4');
      await precacheImage(MemoryImage(videoBytes.buffer.asUint8List()), context);

      if (!mounted) return;

      // Create and initialize controller
      final controller = VideoPlayerController.asset('assets/videos/teeem-logo-in.mp4');
      
      // Wait for initialization
      await controller.initialize();
      
      if (!mounted) return;

      // Configure video
      controller.setVolume(1.0);
      controller.setLooping(false);
      
      // Setup completion callback
      controller.addListener(() {
        if (!mounted) return;
        if (controller.value.position >= controller.value.duration) {
          _onVideoComplete();
        }
      });

      // Update state
      setState(() {
        _controller = controller;
      });

      // Play video
      await controller.play();
    } catch (e) {
      print('Error loading video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        _onVideoComplete();
      }
    }
  }

  void _onVideoComplete() {
    final authState = context.read<AuthBloc>().state;
    if (authState.isAuthenticated) {
      getIt<NavigationService>().navigateToAndReplace(AppRoutes.feed);
    } else {
      getIt<NavigationService>().navigateToAndReplace(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (_hasError) {
      return const SizedBox.shrink(); // Error case: immediately proceed to next screen
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: controller != null && controller.value.isInitialized
          ? Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }
}
