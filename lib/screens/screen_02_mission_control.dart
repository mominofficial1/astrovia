import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import '../widgets/hud_container.dart';
import 'screen_06_mission_briefing.dart';
import 'screen_astronaut_customization.dart';
import 'screen_equipment_inventory.dart';
import 'screen_mission_map.dart';
import 'screen_nasa_credits.dart';
import 'screen_rocket_builder.dart';
import 'screen_settings.dart';
import 'screen_suit_shop.dart';

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
            begin: const Offset(0.06, 0.0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
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
                      backgroundColor:
                          AstroviaTheme.cyan.withValues(alpha: 0.3),
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

  void _continueActiveMission() {
    final state = MissionState.instance;
    final levelNum = state.saveData.unlockedCampaignLevel;
    final targetMission = MissionModel.allMissions[levelNum - 1];
    state.startMission(targetMission);
    _navTo(context, const Screen06MissionBriefing());
  }

  @override
  Widget build(BuildContext context) {
    final state = MissionState.instance;
    final activeLevelNum = state.saveData.unlockedCampaignLevel;
    final activeMission = MissionModel.allMissions[activeLevelNum - 1];

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: AstroviaVideoBackground(
        videoAsset: 'assets/videos/space_background.mp4',
        overlayOpacity: 0.45,
        loop: true,
        showMuteButton: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header HUD Bar
                _buildHeader(context, state),
                const SizedBox(height: 14),

                // Main 7 Options Navigation Grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: (constraints.maxWidth / 4) /
                            ((constraints.maxHeight - 20) / 2),
                        children: [
                          // 1. Continue Mission
                          _buildNavCard(
                            context: context,
                            title: "CONTINUE MISSION",
                            subtitle:
                                "L$activeLevelNum: ${activeMission.codeName}",
                            imageAsset: "assets/images/card_continue.jpg",
                            icon: Icons.play_arrow_rounded,
                            isPrimary: true,
                            onTap: _continueActiveMission,
                          ),

                          // 2. Mission Map (Winding progression road)
                          _buildNavCard(
                            context: context,
                            title: "MISSION MAP",
                            subtitle: "10 CELESTIAL TARGET NODES",
                            imageAsset: "assets/images/card_missions.jpg",
                            icon: Icons.map_rounded,
                            isGold: true,
                            onTap: () =>
                                _navTo(context, const ScreenMissionMap()),
                          ),

                          // 3. Rocket Builder
                          _buildNavCard(
                            context: context,
                            title: "ROCKET BUILDER",
                            subtitle: "ASSEMBLY HANGAR & STAGING",
                            imageAsset: "assets/images/card_launch.jpg",
                            icon: Icons.rocket_rounded,
                            onTap: () =>
                                _navTo(context, const ScreenRocketBuilder()),
                          ),

                          // 4. Astronaut Customization
                          _buildNavCard(
                            context: context,
                            title: "ASTRONAUT",
                            subtitle: "CUSTOMIZE CREW & SUITS",
                            imageAsset: "assets/images/card_astronaut.jpg",
                            icon: Icons.person_pin_rounded,
                            onTap: () => _navTo(
                                context, const ScreenAstronautCustomization()),
                          ),

                          // 5. Equipment & Inventory
                          _buildNavCard(
                            context: context,
                            title: "EQUIPMENT & BAG",
                            subtitle: "GEOLOGY VAULT & TOOLS",
                            imageAsset: "assets/images/card_equipment.jpg",
                            icon: Icons.backpack_rounded,
                            onTap: () => _navTo(
                                context, const ScreenEquipmentInventory()),
                          ),

                          // 6. NASA Data & Credits
                          _buildNavCard(
                            context: context,
                            title: "NASA DATA & CREDITS",
                            subtitle: "8 VERIFIED CITATION ARCHIVES",
                            imageAsset: "assets/images/card_achievements.jpg",
                            icon: Icons.science_rounded,
                            onTap: () =>
                                _navTo(context, const ScreenNasaCredits()),
                          ),

                          // 7. Settings & Accessibility
                          _buildNavCard(
                            context: context,
                            title: "SETTINGS",
                            subtitle: "AUDIO, CONTROLS & DISPLAY",
                            imageAsset: "assets/images/card_continue.jpg",
                            icon: Icons.settings_rounded,
                            onTap: () =>
                                _navTo(context, const ScreenSettings()),
                          ),

                          // 8. Suit & Equipment Shop
                          _buildNavCard(
                            context: context,
                            title: "SUIT & OUTFIT SHOP",
                            subtitle: "BUY SUITS, VISORS & RIGS",
                            imageAsset: "assets/images/suit_explorer.jpg",
                            icon: Icons.storefront_rounded,
                            isGold: true,
                            onTap: () =>
                                _navTo(context, const ScreenSuitShop()),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
          // Left: ASTRAVIA BRAND & Tagline
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: AstroviaTheme.cyan.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AstroviaTheme.cyan.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/astravia_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "ASTRAVIA",
                    style: AstroviaTheme.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AstroviaTheme.white,
                      letterSpacing: 2.5,
                    ),
                  ),
                  Text(
                    "THE JOURNEY THROUGH SPACE • NASA SPACE APPS 2026",
                    style: AstroviaTheme.rajdhani(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.cyan,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Astronaut Callsign, Rank Badge & Economy
          Row(
            children: [
              InkWell(
                onTap: _showChangeNameDialog,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AstroviaTheme.panelGlass,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AstroviaTheme.cyan.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.badge_rounded,
                          color: AstroviaTheme.cyan, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "CDR: ${state.astronautName}",
                        style: AstroviaTheme.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AstroviaTheme.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_rounded,
                          size: 12, color: AstroviaTheme.secondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AstroviaTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AstroviaTheme.gold.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded,
                        color: AstroviaTheme.gold, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${state.saveData.coins}",
                      style: AstroviaTheme.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AstroviaTheme.gold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AstroviaTheme.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AstroviaTheme.cyan.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.military_tech_rounded,
                        color: AstroviaTheme.cyan, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${state.saveData.xp} XP",
                      style: AstroviaTheme.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AstroviaTheme.cyan,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    bool isPrimary = false,
    bool isGold = false,
    required VoidCallback onTap,
  }) {
    return HudContainer(
      isSelected: isPrimary,
      isGold: isGold,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Visual image background
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) {
                    return Container(color: AstroviaTheme.panel);
                  },
                ),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AstroviaTheme.darkSpace.withValues(alpha: 0.25),
                      AstroviaTheme.panelTranslucent.withValues(alpha: 0.88),
                      AstroviaTheme.darkSpace.withValues(alpha: 0.96),
                    ],
                  ),
                ),
              ),

              // Card Contents
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon Badge
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isGold
                            ? AstroviaTheme.gold.withValues(alpha: 0.25)
                            : (isPrimary
                                ? AstroviaTheme.cyan.withValues(alpha: 0.25)
                                : AstroviaTheme.panelGlass),
                        border: Border.all(
                          color: isGold
                              ? AstroviaTheme.gold
                              : (isPrimary
                                  ? AstroviaTheme.cyan
                                  : AstroviaTheme.cyan.withValues(alpha: 0.4)),
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: isGold
                            ? AstroviaTheme.gold
                            : (isPrimary
                                ? AstroviaTheme.cyan
                                : AstroviaTheme.white),
                      ),
                    ),

                    // Title & Subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AstroviaTheme.orbitron(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isGold
                                ? AstroviaTheme.gold
                                : (isPrimary
                                    ? AstroviaTheme.cyan
                                    : AstroviaTheme.white),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AstroviaTheme.rajdhani(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AstroviaTheme.secondary,
                            letterSpacing: 0.8,
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
    );
  }
}
