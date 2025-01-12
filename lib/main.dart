
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'core/di/injection.dart';
import 'presentation/app.dart';

// Debug flag for development mode
const bool kIsDebug = kDebugMode;

void main() async {
  try {
    // Ensure Flutter bindings and platform channels are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Hide system UI completely
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));

    // Initialize dependencies
    await initializeDependencies();

    // Add a small delay to ensure platform channels are ready
    await Future.delayed(const Duration(milliseconds: 100));

    runApp(const App());
  } catch (e) {
    debugPrint('Initialization error: $e');
    rethrow;
  }
}
