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

    _elementsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final elementsCurve = CurvedAnimation(
      parent: _elementsController,
      curve: Curves.easeOut,
    );

    final backgroundCurve = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeIn,
    );

    _titleScale = Tween<double>(begin: 0.3, end: 1.0).animate(elementsCurve);
    _usernameScale = Tween<double>(begin: 0.3, end: 1.0).animate(elementsCurve);
    _passwordScale = Tween<double>(begin: 0.3, end: 1.0).animate(elementsCurve);
    _buttonsScale = Tween<double>(begin: 0.3, end: 1.0).animate(elementsCurve);
    _backgroundFade = Tween<double>(begin: 0.0, end: 1.0).animate(backgroundCurve);

    // Set background color and start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BackgroundColorProvider>().setBackgroundColor(Colors.black);
      _elementsController.forward();
      _backgroundController.forward();
    });
  }

  @override
  void dispose() {
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
    print('Login button pressed');
    if (_formKey.currentState?.validate() ?? false) {
      print('Form validation passed');
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      print('Attempting login with email: $email');
      
      context.read<AuthBloc>().add(
            AuthSignInRequested(
              email: email,
              password: password,
            ),
          );
    } else {
      print('Form validation failed');
    }
  }

  void _onDebugLoginPressed() {
    print('Debug login button pressed');
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
          // Background animation with opacity
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: _backgroundFade.value,
                child: const AnimatedGradientBackground(child: SizedBox.expand()),
              ),
            ),
          ),

          // Content
          Scaffold(
            backgroundColor: Colors.transparent,
            body: BlocConsumer<AuthBloc, AuthState>(
              listenWhen: (previous, current) {
                print('Previous state: ${previous.status}, Current state: ${current.status}');
                return previous.status != current.status || 
                       previous.error != current.error;
              },
              listener: (context, state) {
                print('Auth state changed: ${state.status}');
                if (state.isAuthenticated) {
                  print('User authenticated, navigating to feed');
                  _navigationService.navigateToAndReplace('/feed');
                } else if (state.hasError && state.error != null) {
                  print('Auth error: ${state.error!.message}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!.message),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              builder: (context, state) {
                return SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                  Container(
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
                                      onPressed: state.isAuthenticating ? null : _onLoginPressed,
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
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
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
                                      onPressed: state.isAuthenticating ? null : () => 
                                          _navigationService.navigateTo('/signup'),
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
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      border:
                                          Border.all(color: Colors.white30),
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: state.isAuthenticating ? null : _onDebugLoginPressed,
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
