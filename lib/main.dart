import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'core/di/injection.dart';
import 'presentation/app.dart';

// Debug flag for development mode
const bool kIsDebug = kDebugMode;

void main() async {
  try {
    // Initialize Flutter binding
    WidgetsFlutterBinding.ensureInitialized();
    
    // Configure system UI
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));

    // Enable system overlays but make them transparent
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    SystemChannels.platform.invokeMethod('SystemChrome.setApplicationSwitcherDescription', {
      'label': '',
      'primaryColor': 0xFF000000,
    });

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
