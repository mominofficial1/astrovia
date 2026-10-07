import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import '../widgets/cyber_button.dart';
import '../widgets/hud_container.dart';
import 'screen_07_launch_sequence.dart';

class Screen06MissionBriefing extends StatelessWidget {
  const Screen06MissionBriefing({super.key});

  void _acceptMission(BuildContext context) {
    AudioService.instance.playTransition();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Screen07LaunchSequence(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Dark fade transition per Section 24
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final objectives = [
      "01  LAND SAFELY IN SOUTH POLE CRATER",
      "02  DEPLOY AUTONOMOUS SCIENCE ROVER",
      "03  SCAN ANOMALOUS GEOLOGICAL SAMPLE",
      "04  COLLECT SPECTRAL SCIENTIFIC DATA",
      "05  COMPLETE MISSION & TRANSMIT ARCHIVE",
    ];

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: AstroviaVideoBackground(
        videoAsset: 'assets/videos/astrovia_intro.mp4',
        overlayOpacity: 0.40,
        loop: true,
        showMuteButton: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Navigation Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AstroviaTheme.cyan),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "AEROSPACE MISSION BRIEFING",
                      style: AstroviaTheme.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AstroviaTheme.white,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 12),

                // Main Mission Layout (Left: Directives, Right: Flight Metrics)
                Expanded(
                  child: Row(
                    children: [
                      // Left: Objectives List
                      Expanded(
                        flex: 7,
                        child: HudContainer(
                          isSelected: true,
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Mission Badge
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AstroviaTheme.cyan.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: AstroviaTheme.cyan, width: 1),
                                    ),
                                    child: Text(
                                      "MISSION 01",
                                      style: AstroviaTheme.orbitron(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AstroviaTheme.cyan,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "LUNAR DISCOVERY",
                                    style: AstroviaTheme.orbitron(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AstroviaTheme.white,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Primary Directive
                              Text(
                                "EXPLORE THE LUNAR SURFACE AND COLLECT SCIENTIFIC DATA.",
                                style: AstroviaTheme.rajdhani(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.cyan,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),

                              Text(
                                "OPERATIONAL FLIGHT OBJECTIVES:",
                                style: AstroviaTheme.rajdhani(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.secondary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Objectives Check-list
                              Expanded(
                                child: ListView.separated(
                                  itemCount: objectives.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 6),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AstroviaTheme.panel,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: AstroviaTheme.cyan
                                              .withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.radio_button_unchecked_rounded,
                                            size: 16,
                                            color: AstroviaTheme.cyan,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            objectives[index],
                                            style: AstroviaTheme.rajdhani(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AstroviaTheme.white,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Right: Metrics Panel + Acceptance Button
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            Expanded(
                              child: HudContainer(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildMetricBlock(
                                      "DIFFICULTY",
                                      "MEDIUM",
                                      AstroviaTheme.gold,
                                      Icons.speed_rounded,
                                    ),
                                    _buildMetricBlock(
                                      "ESTIMATED TIME",
                                      "08:00",
                                      AstroviaTheme.white,
                                      Icons.timer_outlined,
                                    ),
                                    _buildMetricBlock(
                                      "SCIENTIFIC VALUE",
                                      "HIGH",
                                      AstroviaTheme.cyan,
                                      Icons.science_outlined,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Accept Mission Button
                            SizedBox(
                              width: double.infinity,
                              child: CyberButton(
                                label: "ACCEPT MISSION",
                                icon: Icons.flight_takeoff_rounded,
                                variant: CyberButtonVariant.cyan,
                                height: 50,
                                fontSize: 15,
                                onPressed: () => _acceptMission(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBlock(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AstroviaTheme.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
