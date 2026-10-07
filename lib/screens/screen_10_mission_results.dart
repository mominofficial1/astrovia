import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import '../widgets/cyber_button.dart';
import '../widgets/hud_container.dart';
import 'screen_02_mission_control.dart';

class Screen10MissionResults extends StatefulWidget {
  const Screen10MissionResults({super.key});

  @override
  State<Screen10MissionResults> createState() => _Screen10MissionResultsState();
}

class _Screen10MissionResultsState extends State<Screen10MissionResults>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreAnimController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    AudioService.instance.playSuccess();
    _scoreAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scoreAnimation = CurvedAnimation(
      parent: _scoreAnimController,
      curve: Curves.easeOutCubic,
    );
    _scoreAnimController.forward();
  }

  @override
  void dispose() {
    _scoreAnimController.dispose();
    super.dispose();
  }

  void _returnToMissionControl() {
    MissionState.instance.resetMission();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Screen02MissionControl(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: AstroviaVideoBackground(
        videoAsset: 'assets/videos/astrovia_intro.mp4',
        overlayOpacity: 0.42,
        loop: true,
        showMuteButton: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: AstroviaTheme.green.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AstroviaTheme.green, width: 1.5),
                    ),
                    child: Text(
                      "★ MISSION SUCCESSFUL ★",
                      style: AstroviaTheme.orbitron(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AstroviaTheme.green,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Main Title: MISSION COMPLETE - LUNAR DISCOVERY
                Center(
                  child: Text(
                    "MISSION COMPLETE",
                    style: AstroviaTheme.orbitron(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AstroviaTheme.white,
                      letterSpacing: 3.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "SECTOR: LUNAR DISCOVERY • MOMIN COMMANDING",
                    style: AstroviaTheme.rajdhani(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.cyan,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Middle: Telemetry Statistics + Educational Debriefing
                Expanded(
                  child: Row(
                    children: [
                      // Left: Animated Statistics
                      Expanded(
                        flex: 5,
                        child: HudContainer(
                          isSelected: true,
                          isGold: true,
                          padding: const EdgeInsets.all(16.0),
                          child: AnimatedBuilder(
                            animation: _scoreAnimation,
                            builder: (context, child) {
                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatItem(
                                      "MISSION SCORE",
                                      "${(87 * _scoreAnimation.value).toInt()}%",
                                      AstroviaTheme.gold),
                                  const Divider(
                                      color: Colors.white12, height: 10),
                                  _buildStatItem(
                                      "SCIENTIFIC DATA",
                                      "+${(250 * _scoreAnimation.value).toInt()}",
                                      AstroviaTheme.cyan),
                                  const Divider(
                                      color: Colors.white12, height: 10),
                                  _buildStatItem(
                                      "EXPLORATION POINTS",
                                      "+${(180 * _scoreAnimation.value).toInt()}",
                                      AstroviaTheme.blue),
                                  const Divider(
                                      color: Colors.white12, height: 10),
                                  _buildStatItem(
                                      "ACCURACY RATING",
                                      "${(92 * _scoreAnimation.value).toInt()}%",
                                      AstroviaTheme.green),
                                  const Divider(
                                      color: Colors.white12, height: 10),
                                  _buildStatItem(
                                      "TOTAL MISSION TIME",
                                      "08:42",
                                      AstroviaTheme.white),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Right: What You Discovered & What You Learned
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            // WHAT YOU DISCOVERED
                            Expanded(
                              child: HudContainer(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                            Icons.military_tech_rounded,
                                            color: AstroviaTheme.gold,
                                            size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "WHAT YOU DISCOVERED",
                                          style: AstroviaTheme.orbitron(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AstroviaTheme.gold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "• Ilmenite Lunar Regolith containing high-yield Helium-3.\n"
                                      "• Sub-surface volcanic lava tube ideal for lunar habitat shielding.\n"
                                      "• Trace water-ice crystals located in permanently shadowed crater rims.",
                                      style: AstroviaTheme.inter(
                                        fontSize: 12,
                                        color: AstroviaTheme.white,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // WHAT YOU LEARNED
                            Expanded(
                              child: HudContainer(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.school_rounded,
                                            color: AstroviaTheme.cyan,
                                            size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "WHAT YOU LEARNED",
                                          style: AstroviaTheme.orbitron(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AstroviaTheme.cyan,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Planetary exploration relies on remote autonomous spectrometers to identify mineralogy before human crew deployment. In-situ resource utilization (ISRU) reduces mission launch mass by 70%.",
                                      style: AstroviaTheme.inter(
                                        fontSize: 12,
                                        color: AstroviaTheme.secondary,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Bottom Action: NEXT MISSION & RETURN TO MISSION CONTROL
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CyberButton(
                      label: "NEXT MISSION: MARS RECON",
                      icon: Icons.rocket_launch_rounded,
                      variant: CyberButtonVariant.gold,
                      minWidth: 260,
                      height: 48,
                      fontSize: 14,
                      onPressed: _returnToMissionControl,
                    ),
                    const SizedBox(width: 18),
                    CyberButton(
                      label: "RETURN TO MISSION CONTROL",
                      icon: Icons.home_rounded,
                      variant: CyberButtonVariant.transparent,
                      minWidth: 240,
                      height: 48,
                      fontSize: 13,
                      onPressed: _returnToMissionControl,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AstroviaTheme.rajdhani(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AstroviaTheme.secondary,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          value,
          style: AstroviaTheme.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
