import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import '../widgets/cyber_button.dart';
import 'screen_02_mission_control.dart';

class Screen01CinematicEntry extends StatefulWidget {
  const Screen01CinematicEntry({super.key});

  @override
  State<Screen01CinematicEntry> createState() => _Screen01CinematicEntryState();
}

class _Screen01CinematicEntryState extends State<Screen01CinematicEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToMissionControl() {
    AudioService.instance.playTransition();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Screen02MissionControl(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: AstroviaVideoBackground(
        videoAsset: 'assets/videos/astrovia_intro.mp4',
        overlayOpacity: 0.28,
        loop: true,
        showMuteButton: true,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Official Logo Icon
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AstroviaTheme.cyan.withValues(alpha: 0.4),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/astrovia_logo.png',
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Badge: Deep Space Exploration Archive
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AstroviaTheme.panelGlass,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AstroviaTheme.cyan.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "DEEP SPACE EXPLORATION ARCHIVE",
                          style: AstroviaTheme.rajdhani(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.2,
                            color: AstroviaTheme.cyan,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Main Title: ASTROVIA with soft white and cyan glow
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: Text(
                        "ASTROVIA",
                        textAlign: TextAlign.center,
                        style: AstroviaTheme.orbitron(
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8.0,
                          color: AstroviaTheme.white,
                        ).copyWith(
                          shadows: [
                            Shadow(
                              color: AstroviaTheme.cyan.withValues(alpha: 0.8),
                              blurRadius: 28,
                            ),
                            Shadow(
                              color: AstroviaTheme.blue.withValues(alpha: 0.5),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle: THE JOURNEY THROUGH SPACE
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: Text(
                        "THE JOURNEY THROUGH SPACE",
                        textAlign: TextAlign.center,
                        style: AstroviaTheme.rajdhani(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4.5,
                          color: AstroviaTheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Action Buttons: BEGIN MISSION & SKIP INTRO
                    SlideTransition(
                      position: _buttonSlide,
                      child: FadeTransition(
                        opacity: _buttonOpacity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CyberButton(
                              label: "BEGIN MISSION",
                              icon: Icons.rocket_launch_outlined,
                              variant: CyberButtonVariant.cyan,
                              minWidth: 220,
                              height: 52,
                              fontSize: 15,
                              onPressed: _navigateToMissionControl,
                            ),
                            const SizedBox(width: 20),
                            CyberButton(
                              label: "SKIP INTRO",
                              variant: CyberButtonVariant.transparent,
                              minWidth: 150,
                              height: 52,
                              fontSize: 14,
                              onPressed: _navigateToMissionControl,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
