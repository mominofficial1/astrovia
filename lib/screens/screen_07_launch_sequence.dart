import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import 'screen_08_planetary_exploration.dart';

class Screen07LaunchSequence extends StatefulWidget {
  const Screen07LaunchSequence({super.key});

  @override
  State<Screen07LaunchSequence> createState() => _Screen07LaunchSequenceState();
}

class _Screen07LaunchSequenceState extends State<Screen07LaunchSequence>
    with SingleTickerProviderStateMixin {
  int _secondsLeft = 10;
  Timer? _countdownTimer;
  bool _liftoffTriggered = false;
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _flashAnimation = CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOut,
    );

    _startCountdown();
  }

  void _startCountdown() {
    AudioService.instance.playCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
        AudioService.instance.playCountdown();
      } else {
        timer.cancel();
        _triggerLiftoff();
      }
    });
  }

  void _triggerLiftoff() {
    if (_liftoffTriggered) return;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    setState(() {
      _liftoffTriggered = true;
    });

    // White/cyan flash + fade transition per Section 24
    _flashController.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Screen08PlanetaryExploration(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 900),
        ),
      );
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: Stack(
        children: [
          // Background Video: Astronaut cockpit & launch environment
          AstroviaVideoBackground(
            videoAsset: 'assets/videos/astronaut_preparation.mp4',
            overlayOpacity: 0.32,
            loop: true,
            showMuteButton: true,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top HUD row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top-left: MISSION 01 / LUNAR DISCOVERY
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MISSION 01",
                              style: AstroviaTheme.rajdhani(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.cyan,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              "LUNAR DISCOVERY",
                              style: AstroviaTheme.orbitron(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),

                        // Skip to Gameplay Button (Hackathon convenience)
                        TextButton(
                          onPressed: _triggerLiftoff,
                          child: Text(
                            "SKIP TO GAMEPLAY ►",
                            style: AstroviaTheme.rajdhani(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AstroviaTheme.secondary,
                            ),
                          ),
                        ),

                        // Top-right: SYSTEMS NOMINAL
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AstroviaTheme.green,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AstroviaTheme.green,
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "SYSTEMS",
                                  style: AstroviaTheme.rajdhani(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.secondary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "NOMINAL",
                              style: AstroviaTheme.orbitron(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.green,
                                letterSpacing: 1.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Center Countdown: T-10 ... T-1, LIFTOFF!
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _liftoffTriggered ? "MAIN ENGINE IGNITION" : "TERMINAL COUNTDOWN",
                          style: AstroviaTheme.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _liftoffTriggered
                                ? AstroviaTheme.gold
                                : AstroviaTheme.cyan,
                            letterSpacing: 3.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _liftoffTriggered ? "LIFTOFF" : "T-$_secondsLeft",
                          style: AstroviaTheme.orbitron(
                            fontSize: 78,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6.0,
                            color: _liftoffTriggered
                                ? AstroviaTheme.gold
                                : AstroviaTheme.white,
                          ).copyWith(
                            shadows: [
                              Shadow(
                                color: _liftoffTriggered
                                    ? AstroviaTheme.goldGlow
                                    : AstroviaTheme.cyanGlow,
                                blurRadius: 36,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Bottom Telemetry Bar: FUEL, OXYGEN, SYSTEM READY
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AstroviaTheme.panelTranslucent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AstroviaTheme.cyan.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildGauge("FUEL", "100%", 1.0, AstroviaTheme.cyan),
                          _buildGauge("OXYGEN", "100%", 1.0, AstroviaTheme.blue),
                          _buildGauge("THRUST VECTOR", "ACTIVE", 0.95, AstroviaTheme.gold),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "SYSTEM",
                                style: AstroviaTheme.rajdhani(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.secondary,
                                ),
                              ),
                              Text(
                                "READY",
                                style: AstroviaTheme.orbitron(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.green,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Cinematic Flash Transition Layer (Section 24: white/cyan flash + fade)
          if (_liftoffTriggered)
            AnimatedBuilder(
              animation: _flashAnimation,
              builder: (context, child) {
                return IgnorePointer(
                  child: Container(
                    color: Color.lerp(
                      AstroviaTheme.cyan,
                      Colors.white,
                      0.6,
                    )!.withValues(alpha: _flashAnimation.value.clamp(0.0, 1.0)),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildGauge(String label, String value, double pct, Color color) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AstroviaTheme.rajdhani(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.secondary,
                ),
              ),
              Text(
                value,
                style: AstroviaTheme.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: AstroviaTheme.panel,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
