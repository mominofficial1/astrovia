import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
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

  void _proceedToMissionControl() {
    AudioService.instance.playTransition();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Screen02MissionControl(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeAnim = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(opacity: fadeAnim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _showFirstTimeSetupDialog() {
    AudioService.instance.playClick();
    final textController =
        TextEditingController(text: MissionState.instance.astronautName);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AstroviaTheme.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AstroviaTheme.cyan, width: 1.5),
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MISSION CALLSIGN REGISTRATION",
                style: AstroviaTheme.orbitron(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.cyan,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Welcome to ASTRAVIA! Enter your explorer commander name to initialize flight credentials. No account required.",
                style: AstroviaTheme.inter(
                  fontSize: 12,
                  color: AstroviaTheme.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: textController,
                autofocus: true,
                style: AstroviaTheme.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.white,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AstroviaTheme.darkSpace,
                  labelText: "COMMANDER CALLSIGN",
                  labelStyle: AstroviaTheme.rajdhani(
                    color: AstroviaTheme.cyan,
                    fontWeight: FontWeight.bold,
                  ),
                  prefixIcon: const Icon(Icons.person_pin_rounded,
                      color: AstroviaTheme.cyan),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: AstroviaTheme.cyan.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AstroviaTheme.cyan, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AstroviaTheme.cyan.withValues(alpha: 0.3),
                      side: const BorderSide(color: AstroviaTheme.cyan),
                    ),
                    onPressed: () {
                      if (textController.text.trim().isNotEmpty) {
                        MissionState.instance
                            .setAstronautName(textController.text);
                      }
                      Navigator.pop(ctx);
                      _proceedToMissionControl();
                    },
                    child: Text(
                      "LAUNCH COMMAND HUB",
                      style: AstroviaTheme.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AstroviaTheme.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: AstroviaVideoBackground(
        videoAsset: 'assets/videos/astrovia_intro.mp4',
        overlayOpacity: 0.38,
        loop: true,
        showMuteButton: true,
        child: SafeArea(
          child: Stack(
            children: [
              // Skip Video button in top-right
              Positioned(
                top: 16,
                right: 20,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: AstroviaTheme.panelGlass,
                    side: BorderSide(
                        color: AstroviaTheme.cyan.withValues(alpha: 0.4)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  icon: const Icon(Icons.skip_next_rounded,
                      color: AstroviaTheme.cyan, size: 16),
                  label: Text(
                    "SKIP INTRO",
                    style: AstroviaTheme.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.cyan,
                    ),
                  ),
                  onPressed: _proceedToMissionControl,
                ),
              ),

              // NASA Space Apps 2026 Challenge Identification Tag
              Positioned(
                top: 16,
                left: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AstroviaTheme.panelGlass,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AstroviaTheme.gold.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.public_rounded,
                          size: 14, color: AstroviaTheme.gold),
                      const SizedBox(width: 6),
                      Text(
                        "NASA INTERNATIONAL SPACE APPS CHALLENGE 2026",
                        style: AstroviaTheme.orbitron(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AstroviaTheme.gold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Central Title and Launch Button
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Official ASTRAVIA Insignia Emblem
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: Container(
                        width: 140,
                        height: 140,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AstroviaTheme.cyan.withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AstroviaTheme.cyan.withValues(alpha: 0.25),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            'assets/images/astravia_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // ASTRAVIA Title
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: Text(
                        "ASTRAVIA",
                        style: AstroviaTheme.orbitron(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: AstroviaTheme.white,
                          letterSpacing: 6.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Tagline
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: Text(
                        "THE JOURNEY THROUGH SPACE",
                        style: AstroviaTheme.rajdhani(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AstroviaTheme.cyan,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Enter Mission Control / First-time Launch Button
                    SlideTransition(
                      position: _buttonSlide,
                      child: FadeTransition(
                        opacity: _buttonOpacity,
                        child: CyberButton(
                          label: "INITIALIZE MISSION CONTROL",
                          icon: Icons.rocket_launch_rounded,
                          variant: CyberButtonVariant.cyan,
                          minWidth: 320,
                          height: 52,
                          onPressed: () {
                            if (MissionState.instance.saveData.tutorialCompleted) {
                              _proceedToMissionControl();
                            } else {
                              _showFirstTimeSetupDialog();
                            }
                          },
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
    );
  }
}
