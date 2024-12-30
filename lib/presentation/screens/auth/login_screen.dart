import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../../../core/di/injection.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../providers/background_color_provider.dart';

class DottedBorderPainter extends CustomPainter {
  final Color color;

  DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const spacing = 6.0;
    const dotSize = 3.0;

    // Draw top line
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawCircle(Offset(i, dotSize), 1, paint);
    }

    // Draw right line
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawCircle(Offset(size.width - dotSize, i), 1, paint);
    }

    // Draw bottom line
    for (double i = size.width; i > 0; i -= spacing) {
      canvas.drawCircle(Offset(i, size.height - dotSize), 1, paint);
    }

    // Draw left line
    for (double i = size.height; i > 0; i -= spacing) {
      canvas.drawCircle(Offset(dotSize, i), 1, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _navigationService = getIt<NavigationService>();

  late final AnimationController _elementsController;
  late final AnimationController _backgroundController;

  late final Animation<double> _usernameScale;
  late final Animation<double> _passwordScale;
  late final Animation<double> _buttonsScale;
  late final Animation<double> _titleScale;
  late final Animation<double> _backgroundFade;

  @override
  void initState() {
    super.initState();

    // Elements scale animation (starts immediately)
    _elementsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Background fade animation (starts after elements)
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Sequential animations for elements
    _usernameScale = CurvedAnimation(
      parent: _elementsController,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );

    _passwordScale = CurvedAnimation(
      parent: _elementsController,
      curve: const Interval(0.25, 0.5, curve: Curves.easeOut),
    );

    _buttonsScale = CurvedAnimation(
      parent: _elementsController,
      curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
    );

    _titleScale = CurvedAnimation(
      parent: _elementsController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _backgroundFade = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeIn,
    );

    // Set background color to black
    Future.microtask(() {
      if (!mounted) return;
      context.read<BackgroundColorProvider>().setBackgroundColor(Colors.black);
    });

    // Delay all animations slightly to ensure proper initialization
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _elementsController.forward();
      _backgroundController.forward();
    });
  }

  void _onElementsAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _backgroundController.forward();
    }
  }

  @override
  void dispose() {
    // Cancel any pending animations
    _elementsController.removeStatusListener(_onElementsAnimationComplete);
    
    // Stop animations before disposing
    _elementsController.stop();
    _backgroundController.stop();
    
    // Dispose controllers
    _elementsController.dispose();
    _backgroundController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputBorder _buildDottedBorder({Color color = Colors.white70}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(
        color: color,
        width: 2,
      ),
    );
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthSignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  void _onDebugLoginPressed() {
    context.read<AuthBloc>().add(
          const AuthSignInRequested(
            email: 'test@example.com',
            password: 'password123',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        children: [
          // Content
          Scaffold(
            backgroundColor: Colors.transparent,
            body: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state.isAuthenticated) {
                  _navigationService.navigateToAndReplace(AppRoutes.feed);
                } else if (state.hasError && state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          // Username field
                          ScaleTransition(
                            scale: _usernameScale,
                            child: SizedBox(
                              height: 56,
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Username, email, telephone, ...',
                                  prefixIcon:
                                      Icon(Icons.email, color: Colors.white70),
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  border: _buildDottedBorder(),
                                  enabledBorder: _buildDottedBorder(),
                                  focusedBorder:
                                      _buildDottedBorder(color: Colors.white),
                                  errorBorder:
                                      _buildDottedBorder(color: Colors.red),
                                  focusedErrorBorder:
                                      _buildDottedBorder(color: Colors.red),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  filled: true,
                                  fillColor: Colors.black45,
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Password field
                          ScaleTransition(
                            scale: _passwordScale,
                            child: SizedBox(
                              height: 56,
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password, fingerprint, ...',
                                  prefixIcon: const Icon(Icons.lock,
                                      color: Colors.white70),
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  border: _buildDottedBorder(),
                                  enabledBorder: _buildDottedBorder(),
                                  focusedBorder:
                                      _buildDottedBorder(color: Colors.white),
                                  errorBorder:
                                      _buildDottedBorder(color: Colors.red),
                                  focusedErrorBorder:
                                      _buildDottedBorder(color: Colors.red),
                                  filled: true,
                                  fillColor: Colors.black45,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Buttons
                          ScaleTransition(
                            scale: _buttonsScale,
                            child: Column(
                              children: [
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: state.isAuthenticating
                                            ? null
                                            : const LinearGradient(
                                                colors: [
                                                  Color(0xFF4CAF50),
                                                  Color(0xFF2E7D32)
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: state.isAuthenticating
                                            ? null
                                            : _onLoginPressed,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor: Colors.grey,
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                          minimumSize:
                                              const Size(double.infinity, 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                        ),
                                        child: state.isAuthenticating
                                            ? const CircularProgressIndicator()
                                            : const Text(
                                                'Login',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: state.isAuthenticating
                                            ? null
                                            : const LinearGradient(
                                                colors: [
                                                  Color(0xFF2196F3),
                                                  Color(0xFF1976D2)
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: state.isAuthenticating
                                            ? null
                                            : () => _navigationService
                                                .navigateTo(AppRoutes.signup),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                          minimumSize:
                                              const Size(double.infinity, 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add),
                                        label: const Text(
                                          'Create Account',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        border:
                                            Border.all(color: Colors.white30),
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: state.isAuthenticating
                                            ? null
                                            : _onDebugLoginPressed,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor: Colors.grey,
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                          minimumSize:
                                              const Size(double.infinity, 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                        ),
                                        icon: const Icon(Icons.bug_report),
                                        label: const Text(
                                          'Skip Login (Debug)',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Title
                          ScaleTransition(
                            scale: _titleScale,
                            child: const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Background animation with opacity
          Opacity(
            opacity: _backgroundFade.value,
            child: const AnimatedGradientBackground(child: SizedBox.expand()),
          ),
        ],
      ),
    );
  }
}
