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
    
    // Remove the Flutter splash screen immediately
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChannels.platform.invokeMethod('SystemChrome.setApplicationSwitcherDescription', {
      'label': '',
      'primaryColor': 0xFF000000,
    });

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
