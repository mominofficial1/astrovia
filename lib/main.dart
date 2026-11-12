import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player_win/video_player_win.dart';
import 'screens/screen_01_cinematic_entry.dart';
import 'services/save_manager.dart';
import 'state/mission_state.dart';
import 'theme/astrovia_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch unhandled Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print('FlutterError caught: ${details.exception}');
    }
  };

  // Catch unhandled asynchronous platform errors to prevent crashing
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print('PlatformDispatcher error caught: $error\n$stack');
    }
    return true;
  };

  // Register Windows Media Foundation video player plugin on Windows
  if (!kIsWeb && Platform.isWindows) {
    try {
      WindowsVideoPlayer.registerWith();
    } catch (_) {}
  }

  // Force Landscape Orientation for Spacecraft and Planetary Exploration Displays
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Full-screen immersive sticky mode
  try {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } catch (_) {}

  // Initialize offline persistent save system
  try {
    await SaveManager.instance.init();
    MissionState.instance.refreshFromSave();
  } catch (e) {
    if (kDebugMode) {
      print("SaveManager startup error: $e");
    }
  }

  runApp(const AstroviaApp());
}

class AstroviaApp extends StatelessWidget {
  const AstroviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASTRAVIA \u2014 THE JOURNEY THROUGH SPACE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AstroviaTheme.darkSpace,
        colorScheme: const ColorScheme.dark(
          primary: AstroviaTheme.cyan,
          secondary: AstroviaTheme.gold,
          surface: AstroviaTheme.panel,
        ),
      ),
      home: const Screen01CinematicEntry(),
    );
  }
}
