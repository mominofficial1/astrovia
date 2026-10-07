import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player_win/video_player_win.dart';
import 'screens/screen_01_cinematic_entry.dart';
import 'theme/astrovia_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch any unhandled Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print('FlutterError caught: ${details.exception}');
    }
  };

  // Catch any unhandled asynchronous platform errors to prevent application closing
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print('PlatformDispatcher error caught: $error\n$stack');
    }
    return true; // Return true to prevent app crash
  };

  // Register Windows Media Foundation video player plugin on Windows
  if (!kIsWeb && Platform.isWindows) {
    try {
      WindowsVideoPlayer.registerWith();
    } catch (_) {}
  }

  // Force Landscape Orientation for Android & Mobile (Section 6, 13, 21)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Full-screen immersive mode (no Android system navigation bars obstructing the game)
  try {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } catch (_) {}

  runApp(const AstroviaApp());
}

class AstroviaApp extends StatelessWidget {
  const AstroviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASTROVIA — The Journey Through Space',
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
