import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import '../widgets/cyber_button.dart';
import '../widgets/hud_container.dart';
import 'screen_06_mission_briefing.dart';

class RocketModel {
  final String name;
  final String subtitle;
  final String fuel;
  final String range;
  final String capacity;
  final String difficulty;
  final IconData icon;

  const RocketModel({
    required this.name,
    required this.subtitle,
    required this.fuel,
    required this.range,
    required this.capacity,
    required this.difficulty,
    required this.icon,
  });
}

class Screen05RocketSelection extends StatefulWidget {
  const Screen05RocketSelection({super.key});

  @override
  State<Screen05RocketSelection> createState() =>
      _Screen05RocketSelectionState();
}

class _Screen05RocketSelectionState extends State<Screen05RocketSelection> {
  final List<RocketModel> rockets = const [
    RocketModel(
      name: "ORBITER",
      subtitle: "RAPID ATMOSPHERIC TRANSLATION",
      fuel: "Liquid Hydrolox (98%)",
      range: "Low Earth Orbit (480 KM)",
      capacity: "2 Crew / 5.2 Tons",
      difficulty: "CADET",
      icon: Icons.flight_takeoff_rounded,
    ),
    RocketModel(
      name: "LUNAR EXPLORER",
      subtitle: "HEAVY-LIFT TRANS-LUNAR INJECTION",
      fuel: "Cryo Methalox (100%)",
      range: "Translunar (384,400 KM)",
      capacity: "4 Crew + Rover / 22 Tons",
      difficulty: "VETERAN",
      icon: Icons.rocket_rounded,
    ),
    RocketModel(
      name: "DEEP SPACE VEHICLE",
      subtitle: "INTERPLANETARY ION TRANSPORT",
      fuel: "Xenon Ion Plasma (94%)",
      range: "Deep Cosmos (2.5 AU)",
      capacity: "6 Crew / 58 Tons",
      difficulty: "MASTER",
      icon: Icons.satellite_alt_rounded,
    ),
  ];

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final current = MissionState.instance.selectedRocket;
    _selectedIndex = rockets.indexWhere((r) => r.name == current);
    if (_selectedIndex < 0) _selectedIndex = 1; // Default to LUNAR EXPLORER
  }

  void _proceedToBriefing() {
    AudioService.instance.playTransition();
    MissionState.instance.selectRocket(rockets[_selectedIndex].name);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Screen06MissionBriefing(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: AstroviaVideoBackground(
        videoAsset: 'assets/videos/space_background.mp4',
        overlayOpacity: 0.38,
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
                      "ROCKET SELECTION",
                      style: AstroviaTheme.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AstroviaTheme.white,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 14),

                // Rocket Cards Grid / Row
                Expanded(
                  child: Row(
                    children: List.generate(rockets.length, (index) {
                      final rocket = rockets[index];
                      final isSelected = index == _selectedIndex;

                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: index < rockets.length - 1 ? 16.0 : 0.0,
                          ),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedIndex = index),
                            child: HudContainer(
                              isSelected: isSelected,
                              isGold: isSelected, // Gold + Cyan highlight per Section 10
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Header: Icon + Name
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AstroviaTheme.gold.withValues(alpha: 0.18)
                                              : AstroviaTheme.panel,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          rocket.icon,
                                          size: 32,
                                          color: isSelected
                                              ? AstroviaTheme.gold
                                              : AstroviaTheme.cyan,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              rocket.name,
                                              style: AstroviaTheme.orbitron(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? AstroviaTheme.gold
                                                    : AstroviaTheme.white,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              rocket.subtitle,
                                              style: AstroviaTheme.rajdhani(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AstroviaTheme.secondary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Specs Information
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AstroviaTheme.panel,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isSelected
                                            ? AstroviaTheme.gold.withValues(alpha: 0.4)
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildSpecRow("PROPULSION", rocket.fuel),
                                        const Divider(color: Colors.white10, height: 10),
                                        _buildSpecRow("OPERATIONAL RANGE", rocket.range),
                                        const Divider(color: Colors.white10, height: 10),
                                        _buildSpecRow("PAYLOAD CAP", rocket.capacity),
                                        const Divider(color: Colors.white10, height: 10),
                                        _buildSpecRow("PILOT LEVEL", rocket.difficulty,
                                            valueColor: isSelected
                                                ? AstroviaTheme.gold
                                                : AstroviaTheme.cyan),
                                      ],
                                    ),
                                  ),

                                  // Bottom Selector Tag
                                  Center(
                                    child: Text(
                                      isSelected
                                          ? "★ LAUNCH VEHICLE ASSIGNED ★"
                                          : "SELECT PROPULSION VEHICLE",
                                      style: AstroviaTheme.rajdhani(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AstroviaTheme.gold
                                            : AstroviaTheme.secondary.withValues(alpha: 0.6),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),

                // Primary Action Button: PREPARE FOR LAUNCH
                Align(
                  alignment: Alignment.centerRight,
                  child: CyberButton(
                    label: "PREPARE FOR LAUNCH",
                    icon: Icons.rocket_launch_rounded,
                    variant: CyberButtonVariant.gold,
                    minWidth: 240,
                    height: 50,
                    onPressed: _proceedToBriefing,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String key, String val, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          key,
          style: AstroviaTheme.rajdhani(
            fontSize: 11,
            color: AstroviaTheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          val,
          style: AstroviaTheme.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AstroviaTheme.white,
          ),
        ),
      ],
    );
  }
}
