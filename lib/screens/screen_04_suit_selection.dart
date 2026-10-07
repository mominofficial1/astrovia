import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import '../widgets/cyber_button.dart';
import '../widgets/hud_container.dart';
import '../widgets/scanner_beam.dart';
import 'screen_05_rocket_selection.dart';

class SuitModel {
  final String name;
  final String description;
  final double protection;
  final double oxygen;
  final double mobility;
  final String imageAsset;
  final IconData icon;

  const SuitModel({
    required this.name,
    required this.description,
    required this.protection,
    required this.oxygen,
    required this.mobility,
    required this.imageAsset,
    required this.icon,
  });
}

class Screen04SuitSelection extends StatefulWidget {
  const Screen04SuitSelection({super.key});

  @override
  State<Screen04SuitSelection> createState() => _Screen04SuitSelectionState();
}

class _Screen04SuitSelectionState extends State<Screen04SuitSelection> {
  final List<SuitModel> suits = const [
    SuitModel(
      name: "EXPLORER SUIT",
      description: "Standard agile EVA mobility suit for planetary reconnaissance.",
      protection: 0.75,
      oxygen: 0.80,
      mobility: 0.90,
      imageAsset: "assets/images/suit_explorer.jpg",
      icon: Icons.accessibility_new_rounded,
    ),
    SuitModel(
      name: "LUNAR SUIT",
      description: "Reinforced titanium composite fabric against lunar abrasive dust.",
      protection: 0.92,
      oxygen: 0.85,
      mobility: 0.70,
      imageAsset: "assets/images/suit_lunar.jpg",
      icon: Icons.shield_rounded,
    ),
    SuitModel(
      name: "DEEP SPACE SUIT",
      description: "Extreme cryogenic insulation with quantum neural fiber mesh.",
      protection: 0.98,
      oxygen: 0.95,
      mobility: 0.60,
      imageAsset: "assets/images/suit_deepspace.jpg",
      icon: Icons.security_rounded,
    ),
  ];

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final current = MissionState.instance.selectedSuit;
    _selectedIndex = suits.indexWhere((s) => s.name == current);
    if (_selectedIndex < 0) _selectedIndex = 0;
  }

  void _proceedToRocketSelection() {
    MissionState.instance.selectSuit(suits[_selectedIndex].name);
    AudioService.instance.playTransition();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Screen05RocketSelection(),
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
        videoAsset: 'assets/videos/astronaut_preparation.mp4',
        overlayOpacity: 0.40,
        loop: true,
        showMuteButton: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Back Button and Title
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
                    ),
                    Text(
                      "SELECT YOUR SUIT",
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

                // Horizontal Suit Cards with Real Images
                Expanded(
                  child: Row(
                    children: List.generate(suits.length, (index) {
                      final suit = suits[index];
                      final isSelected = index == _selectedIndex;

                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: index < suits.length - 1 ? 16.0 : 0.0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              AudioService.instance.playScan();
                              setState(() => _selectedIndex = index);
                            },
                            child: HudContainer(
                              isSelected: isSelected,
                              padding: const EdgeInsets.all(12.0),
                              child: Stack(
                                children: [
                                  // Animated scanning line on selected suit card
                                  if (isSelected)
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: const ScannerBeam(),
                                      ),
                                    ),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Top: Suit Image Thumbnail
                                      Expanded(
                                        flex: 5,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.asset(
                                                suit.imageAsset,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) =>
                                                    Center(
                                                  child: Icon(suit.icon,
                                                      size: 48,
                                                      color: AstroviaTheme.cyan),
                                                ),
                                              ),
                                            ),
                                            // Glass cyber border over image
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AstroviaTheme.cyan
                                                      : Colors.white12,
                                                  width: 1.2,
                                                ),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    AstroviaTheme.panel
                                                        .withValues(alpha: 0.6),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Top Right Badge
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AstroviaTheme.darkSpace
                                                      .withValues(alpha: 0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? AstroviaTheme.cyan
                                                        : Colors.white24,
                                                  ),
                                                ),
                                                child: Text(
                                                  "MK-${index + 1}",
                                                  style:
                                                      AstroviaTheme.orbitron(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected
                                                        ? AstroviaTheme.cyan
                                                        : AstroviaTheme.secondary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Middle Details
                                      Text(
                                        suit.name,
                                        textAlign: TextAlign.center,
                                        style: AstroviaTheme.orbitron(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? AstroviaTheme.cyan
                                              : AstroviaTheme.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      // Stat Bars
                                      _buildBar("PROTECTION", suit.protection,
                                          AstroviaTheme.cyan),
                                      const SizedBox(height: 4),
                                      _buildBar("OXYGEN SYSTEM", suit.oxygen,
                                          AstroviaTheme.blue),
                                      const SizedBox(height: 4),
                                      _buildBar("MOBILITY", suit.mobility,
                                          AstroviaTheme.gold),
                                      const SizedBox(height: 6),

                                      // Bottom: Selection Tag
                                      Center(
                                        child: Text(
                                          isSelected
                                              ? "[ SUIT EQUIPPED ]"
                                              : "TAP TO EQUIP",
                                          style: AstroviaTheme.rajdhani(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? AstroviaTheme.cyan
                                                : AstroviaTheme.secondary
                                                    .withValues(alpha: 0.5),
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
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
                const SizedBox(height: 14),

                // Bottom-right: Select Suit button
                Align(
                  alignment: Alignment.centerRight,
                  child: CyberButton(
                    label: "SELECT SUIT",
                    icon: Icons.check_circle_outline_rounded,
                    variant: CyberButtonVariant.cyan,
                    minWidth: 200,
                    height: 48,
                    onPressed: _proceedToRocketSelection,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBar(String label, double value, Color color) {
    final pct = (value * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AstroviaTheme.rajdhani(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AstroviaTheme.secondary,
              ),
            ),
            Text(
              "$pct%",
              style: AstroviaTheme.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AstroviaTheme.panel,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
