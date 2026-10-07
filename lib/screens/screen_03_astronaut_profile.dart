import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import '../widgets/cyber_button.dart';
import '../widgets/hud_container.dart';
import 'screen_04_suit_selection.dart';

class Screen03AstronautProfile extends StatefulWidget {
  const Screen03AstronautProfile({super.key});

  @override
  State<Screen03AstronautProfile> createState() =>
      _Screen03AstronautProfileState();
}

class _Screen03AstronautProfileState extends State<Screen03AstronautProfile> {
  void _navigateToSuitSelection() {
    AudioService.instance.playTransition();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Screen04SuitSelection(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showEditNameDialog() {
    AudioService.instance.playClick();
    final textController =
        TextEditingController(text: MissionState.instance.astronautName);

    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                "CHANGE ASTRONAUT NAME",
                style: AstroviaTheme.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.cyan,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Personalize your explorer callsign for the space mission:",
                style: AstroviaTheme.rajdhani(
                  fontSize: 13,
                  color: AstroviaTheme.secondary,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: textController,
                autofocus: true,
                style: AstroviaTheme.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.white,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AstroviaTheme.darkSpace,
                  labelText: "ASTRONAUT CALLSIGN",
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
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "CANCEL",
                      style: AstroviaTheme.rajdhani(
                        color: AstroviaTheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AstroviaTheme.cyan.withValues(alpha: 0.3),
                      side: const BorderSide(color: AstroviaTheme.cyan),
                    ),
                    onPressed: () {
                      if (textController.text.trim().isNotEmpty) {
                        MissionState.instance
                            .setAstronautName(textController.text);
                        AudioService.instance.playClick();
                        setState(() {});
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      "SAVE CALLSIGN",
                      style: AstroviaTheme.orbitron(
                        fontSize: 12,
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

  void _showHistoryDialog() {
    AudioService.instance.playClick();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AstroviaTheme.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AstroviaTheme.cyan, width: 1.5),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ASTRONAUT MISSION ARCHIVE",
                style: AstroviaTheme.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.cyan,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "• MISSION 00: Orbital Centrifuge Simulation (COMPLETED)\n"
                "• MISSION 01: Lunar Discovery & Regolith Analysis (ACTIVE)\n"
                "• MISSION 02: Deep Space Gateway Rendezvous (LOCKED)",
                style: AstroviaTheme.rajdhani(
                  fontSize: 15,
                  color: AstroviaTheme.white,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: CyberButton(
                  label: "DISMISS",
                  variant: CyberButtonVariant.transparent,
                  minWidth: 100,
                  height: 40,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = MissionState.instance;

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: AstroviaVideoBackground(
        videoAsset: 'assets/videos/astronaut_preparation.mp4',
        overlayOpacity: 0.45,
        loop: true,
        showMuteButton: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                // Top Bar with Back Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AstroviaTheme.cyan),
                      onPressed: () {
                        AudioService.instance.playClick();
                        Navigator.pop(context);
                      },
                      tooltip: "Back to Mission Control",
                    ),
                    Text(
                      "ASTRONAUT DOSSIER",
                      style: AstroviaTheme.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AstroviaTheme.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 12),

                // Main Content Area: Character HUD + Stats Card
                Expanded(
                  child: Row(
                    children: [
                      // Left: Astronaut Holographic Avatar & Scanning Frame
                      Expanded(
                        flex: 5,
                        child: HudContainer(
                          isSelected: true,
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glowing concentric orbital rings
                                Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AstroviaTheme.cyan.withValues(alpha: 0.25),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AstroviaTheme.cyan.withValues(alpha: 0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                ),

                                // Astronaut Portrait
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: SizedBox(
                                    width: 160,
                                    height: 160,
                                    child: Image.asset(
                                      'assets/images/card_astronaut.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.person_pin_circle_rounded,
                                        size: 96,
                                        color: AstroviaTheme.cyan,
                                      ),
                                    ),
                                  ),
                                ),

                                // Status badge
                                Positioned(
                                  bottom: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AstroviaTheme.darkSpace.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AstroviaTheme.green, width: 1),
                                    ),
                                    child: Text(
                                      "EVA READY",
                                      style: AstroviaTheme.rajdhani(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AstroviaTheme.green,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Right: Pilot Data & Stats
                      Expanded(
                        flex: 6,
                        child: HudContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          state.astronautName,
                                          style: AstroviaTheme.orbitron(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            color: AstroviaTheme.white,
                                            letterSpacing: 2.0,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          onPressed: _showEditNameDialog,
                                          icon: const Icon(Icons.edit_note_rounded,
                                              color: AstroviaTheme.cyan, size: 24),
                                          tooltip: "Change Astronaut Name",
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "ASTRONAUT LEVEL 0${state.level} • CHIEF EXPLORER",
                                      style: AstroviaTheme.rajdhani(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AstroviaTheme.cyan,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Stat Progress Bars
                                    _buildStatRow("MISSION EXPERIENCE", "${state.xp} XP", 0.65, AstroviaTheme.cyan),
                                    const SizedBox(height: 10),
                                    _buildStatRow("SCIENCE ARCHIVE", "${state.science} PTS", 0.45, AstroviaTheme.gold),
                                    const SizedBox(height: 10),
                                    _buildStatRow("EXPLORATION RATING", "${state.exploration} PTS", 0.80, AstroviaTheme.blue),
                                  ],
                                ),

                                // Action Buttons
                                Row(
                                  children: [
                                    CyberButton(
                                      label: "CUSTOMIZE SUIT",
                                      icon: Icons.tune_rounded,
                                      variant: CyberButtonVariant.cyan,
                                      minWidth: 160,
                                      height: 46,
                                      onPressed: _navigateToSuitSelection,
                                    ),
                                    const SizedBox(width: 14),
                                    CyberButton(
                                      label: "MISSION HISTORY",
                                      icon: Icons.history_edu_rounded,
                                      variant: CyberButtonVariant.transparent,
                                      minWidth: 160,
                                      height: 46,
                                      onPressed: _showHistoryDialog,
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
      ),
    );
  }

  Widget _buildStatRow(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AstroviaTheme.rajdhani(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AstroviaTheme.secondary,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              value,
              style: AstroviaTheme.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AstroviaTheme.panel,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
