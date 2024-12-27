import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'core/di/injection.dart';
import 'presentation/app.dart';

// Debug flag for development mode
const bool kIsDebug = kDebugMode;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide system UI completely
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  // Initialize dependencies
  await initializeDependencies();

  runApp(const App());
}
