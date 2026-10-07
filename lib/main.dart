import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player_win/video_player_win.dart';
import 'screens/screen_01_cinematic_entry.dart';
import 'theme/astrovia_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register Windows Media Foundation video player plugin on Windows
  if (!kIsWeb && Platform.isWindows) {
    WindowsVideoPlayer.registerWith();
  }

  // Force Landscape Orientation for Android & Mobile (Section 6, 13, 21)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Full-screen immersive mode (no Android system navigation bars obstructing the game)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
