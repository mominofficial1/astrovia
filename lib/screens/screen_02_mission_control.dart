import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import '../widgets/hud_container.dart';
import 'screen_03_astronaut_profile.dart';
import 'screen_04_suit_selection.dart';
import 'screen_06_mission_briefing.dart';
import 'screen_08_planetary_exploration.dart';
import 'screen_10_mission_results.dart';

class Screen02MissionControl extends StatefulWidget {
  const Screen02MissionControl({super.key});

  @override
  State<Screen02MissionControl> createState() => _Screen02MissionControlState();
}

class _Screen02MissionControlState extends State<Screen02MissionControl> {
  void _navTo(BuildContext context, Widget screen) {
    AudioService.instance.playTransition();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0.08, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showChangeNameDialog() {
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
                "ASTRONAUT CREDENTIALS",
                style: AstroviaTheme.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.cyan,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your official mission commander callsign / name:",
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
                  labelText: "CALLSIGN / NAME",
                  labelStyle: AstroviaTheme.rajdhani(
                    color: AstroviaTheme.cyan,
                    fontWeight: FontWeight.bold,
                  ),
                  prefixIcon: const Icon(Icons.badge_rounded,
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
                      "CONFIRM CALLSIGN",
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

  @override
  Widget build(BuildContext context) {
    final state = MissionState.instance;

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: AstroviaVideoBackground(
        videoAsset: 'assets/videos/space_background.mp4',
        overlayOpacity: 0.45,
        loop: true,
        showMuteButton: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header HUD Bar
                _buildHeader(context, state),
                const SizedBox(height: 16),

                // Main Grid of Futuristic Navigation Cards with rich visual images
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio:
                            (constraints.maxWidth / 3) / ((constraints.maxHeight - 20) / 2),
                        children: [
                          _buildNavCard(
                            context: context,
                            title: "CONTINUE MISSION",
                            subtitle: "ACTIVE SECTOR: LUNAR CRATER",
                            imageAsset: "assets/images/card_continue.jpg",
                            icon: Icons.play_arrow_rounded,
                            isPrimary: true,
                            onTap: () => _navTo(
                                context, const Screen08PlanetaryExploration()),
                          ),
                          _buildNavCard(
                            context: context,
                            title: "NEW MISSION",
                            subtitle: "INITIALIZE LAUNCH ARCHIVE",
                            imageAsset: "assets/images/card_launch.jpg",
                            icon: Icons.rocket_launch_rounded,
                            isGold: true,
                            onTap: () => _navTo(
                                context, const Screen03AstronautProfile()),
                          ),
                          _buildNavCard(
                            context: context,
                            title: "ASTRONAUT",
                            subtitle: "PILOT DOSSIER: ${state.astronautName}",
                            imageAsset: "assets/images/card_astronaut.jpg",
                            icon: Icons.person_pin_rounded,
                            onTap: () => _navTo(
                                context, const Screen03AstronautProfile()),
                          ),
                          _buildNavCard(
                            context: context,
                            title: "EQUIPMENT",
                            subtitle: "SUITS & PROPULSION MODULES",
                            imageAsset: "assets/images/card_equipment.jpg",
                            icon: Icons.shield_rounded,
                            onTap: () => _navTo(
                                context, const Screen04SuitSelection()),
                          ),
                          _buildNavCard(
                            context: context,
                            title: "MISSIONS",
                            subtitle: "LUNAR DISCOVERY BRIEFING",
                            imageAsset: "assets/images/card_missions.jpg",
                            icon: Icons.explore_rounded,
                            onTap: () => _navTo(
                                context, const Screen06MissionBriefing()),
                          ),
                          _buildNavCard(
                            context: context,
                            title: "ACHIEVEMENTS",
                            subtitle: "DATA LOGS & SAMPLES",
                            imageAsset: "assets/images/card_achievements.jpg",
                            icon: Icons.military_tech_rounded,
                            onTap: () => _navTo(
                                context, const Screen10MissionResults()),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MissionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AstroviaTheme.panelTranslucent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AstroviaTheme.cyan.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: ASTROVIA MISSION CONTROL
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AstroviaTheme.cyan,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AstroviaTheme.cyan,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "ASTROVIA",
                    style: AstroviaTheme.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AstroviaTheme.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Text(
                    "MISSION CONTROL COMMAND",
                    style: AstroviaTheme.rajdhani(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AstroviaTheme.cyan,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Telemetry data tags
          Row(
            children: [
              // Tap astronaut badge to edit name
              InkWell(
                onTap: _showChangeNameDialog,
                borderRadius: BorderRadius.circular(6),
                child: _buildTelemetryBadge(
                  "ASTRONAUT ✎",
                  state.astronautName,
                  AstroviaTheme.cyan,
                  isInteractive: true,
                ),
              ),
              const SizedBox(width: 12),
              _buildTelemetryBadge(
                  "STATUS", "READY", AstroviaTheme.green),
              const SizedBox(width: 12),
              _buildTelemetryBadge(
                  "LEVEL", "0${state.level}", AstroviaTheme.cyan),
              const SizedBox(width: 12),
              _buildTelemetryBadge(
                  "SCIENCE", "${state.science}".padLeft(3, '0'), AstroviaTheme.gold),
              const SizedBox(width: 12),
              _buildTelemetryBadge(
                  "EXPLORATION", "${state.exploration}".padLeft(3, '0'), AstroviaTheme.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryBadge(String label, String value, Color valueColor,
      {bool isInteractive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isInteractive
            ? AstroviaTheme.cyan.withValues(alpha: 0.15)
            : AstroviaTheme.panelGlass,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isInteractive
              ? AstroviaTheme.cyan
              : AstroviaTheme.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AstroviaTheme.rajdhani(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isInteractive ? AstroviaTheme.cyan : AstroviaTheme.secondary,
              letterSpacing: 1.0,
            ),
          ),
          Text(
            value,
            style: AstroviaTheme.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String imageAsset,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isGold = false,
  }) {
    return HudContainer(
      isSelected: isPrimary,
      isGold: isGold,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background rich image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(),
            ),
          ),

          // Cyber Glass Gradient Overlay (keeps text extremely readable and stylish)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AstroviaTheme.darkSpace.withValues(alpha: 0.45),
                  AstroviaTheme.panel.withValues(alpha: 0.88),
                  AstroviaTheme.darkSpace.withValues(alpha: 0.95),
                ],
              ),
            ),
          ),

          // Foreground Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isGold
                            ? AstroviaTheme.gold.withValues(alpha: 0.2)
                            : AstroviaTheme.cyan.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: isGold
                            ? AstroviaTheme.gold
                            : (isPrimary ? AstroviaTheme.cyan : AstroviaTheme.white),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: isGold
                          ? AstroviaTheme.gold
                          : AstroviaTheme.secondary.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AstroviaTheme.orbitron(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isGold
                            ? AstroviaTheme.gold
                            : (isPrimary ? AstroviaTheme.cyan : AstroviaTheme.white),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AstroviaTheme.rajdhani(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AstroviaTheme.secondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
