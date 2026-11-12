import 'package:flutter/material.dart';
import '../models/astronaut_model.dart';
import '../rendering/astronaut_renderer.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/hud_container.dart';

class ScreenAstronautCustomization extends StatefulWidget {
  const ScreenAstronautCustomization({super.key});

  @override
  State<ScreenAstronautCustomization> createState() =>
      _ScreenAstronautCustomizationState();
}

class _ScreenAstronautCustomizationState
    extends State<ScreenAstronautCustomization>
    with SingleTickerProviderStateMixin {
  late AstronautProfile _profile;
  late AnimationController _animController;
  AstronautAnimState _previewAnim = AstronautAnimState.idle;
  int _activeCategoryIndex = 0; // 0=Character, 1=Suits, 2=Visor/Colors, 3=Gear, 4=Patches

  @override
  void initState() {
    super.initState();
    final current = MissionState.instance.saveData.playerProfile;
    _profile = AstronautProfile.fromJson(current.toJson());

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    AudioService.instance.playSuccess();
    MissionState.instance.updateAstronautProfile(_profile);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AstroviaTheme.panel,
        content: Text(
          "ASTRONAUT PROFILE & LOADOUT UPDATED AND PERSISTED.",
          style: AstroviaTheme.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AstroviaTheme.cyan,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final characters = AstronautCharacter.availableCharacters;
    final suits = SuitOutfit.availableSuits;

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Bar
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
                    "ASTRONAUT PROFILE & SPACESUIT CUSTOMIZATION",
                    style: AstroviaTheme.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AstroviaTheme.cyan.withValues(alpha: 0.25),
                      side: const BorderSide(color: AstroviaTheme.cyan),
                    ),
                    icon: const Icon(Icons.save_rounded,
                        size: 16, color: AstroviaTheme.cyan),
                    label: Text(
                      "SAVE LOADOUT",
                      style: AstroviaTheme.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AstroviaTheme.white,
                      ),
                    ),
                    onPressed: _saveProfile,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Main Customization Interface:
              // Left: Category Tabs & Selectors
              // Center: Live 360 Animated Astronaut Rendering Stage
              // Right: Active Stats & Call-sign Editor
              Expanded(
                child: Row(
                  children: [
                    // Left Column: Customization Options
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          // Tab Bar
                          SizedBox(
                            height: 38,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildTabChip("COMMANDER", 0),
                                _buildTabChip("SUITS", 1),
                                _buildTabChip("VISOR & COLORS", 2),
                                _buildTabChip("GEAR & PLSS", 3),
                                _buildTabChip("PATCHES", 4),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Tab Content Body
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AstroviaTheme.panelTranslucent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AstroviaTheme.cyan
                                        .withValues(alpha: 0.3)),
                              ),
                              child: _buildActiveTabContent(characters, suits),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Center Column: Live Animated Astronaut Canvas
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AstroviaTheme.panelTranslucent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AstroviaTheme.cyan.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Animation preview state selector
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildAnimButton("IDLE", AstronautAnimState.idle),
                                const SizedBox(width: 4),
                                _buildAnimButton("WALK", AstronautAnimState.walk),
                                const SizedBox(width: 4),
                                _buildAnimButton("RUN", AstronautAnimState.run),
                                const SizedBox(width: 4),
                                _buildAnimButton("JUMP", AstronautAnimState.jump),
                                const SizedBox(width: 4),
                                _buildAnimButton("ZERO-G", AstronautAnimState.zeroG),
                              ],
                            ),
                            const Spacer(),

                            // Live Procedural Humanoid Astronaut Rendering!
                            AnimatedBuilder(
                              animation: _animController,
                              builder: (ctx, child) {
                                return AstronautAvatarWidget(
                                  profile: _profile,
                                  animState: _previewAnim,
                                  animPhase: _animController.value,
                                  scale: 2.2,
                                  showHeadlampBeam: true,
                                );
                              },
                            ),
                            const Spacer(),

                            // Active Profile Callsign Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AstroviaTheme.darkSpace,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AstroviaTheme.cyan),
                              ),
                              child: Text(
                                "${_profile.character.name} [CALLSIGN: ${_profile.callsign}]",
                                style: AstroviaTheme.orbitron(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.cyan,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Right Column: Active Suit Stats & Callsign
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          HudContainer(
                            isSelected: true,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ASTRONAUT CREDENTIALS",
                                  style: AstroviaTheme.orbitron(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.cyan,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "CALLSIGN / NAME",
                                  style: AstroviaTheme.rajdhani(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.secondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: TextEditingController(
                                      text: _profile.callsign),
                                  style: AstroviaTheme.orbitron(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.white,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AstroviaTheme.darkSpace,
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AstroviaTheme.cyan
                                              .withValues(alpha: 0.4)),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AstroviaTheme.cyan,
                                          width: 1.5),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    if (val.trim().isNotEmpty) {
                                      _profile.callsign =
                                          val.trim().toUpperCase();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Active Suit Performance Ratings
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AstroviaTheme.panelTranslucent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AstroviaTheme.cyan
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "SUIT SPECIFICATIONS",
                                    style: AstroviaTheme.orbitron(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AstroviaTheme.gold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _profile.currentSuit.name,
                                    style: AstroviaTheme.orbitron(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AstroviaTheme.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _profile.currentSuit.description,
                                    style: AstroviaTheme.inter(
                                      fontSize: 11,
                                      color: AstroviaTheme.secondary,
                                    ),
                                  ),
                                  const Divider(
                                      color: Color(0x3319D9FF), height: 18),
                                  _buildStatBar("THERMAL SHIELD",
                                      _profile.currentSuit.thermalProtection,
                                      AstroviaTheme.cyan),
                                  const SizedBox(height: 8),
                                  _buildStatBar("MOBILITY RATING",
                                      _profile.currentSuit.mobility,
                                      AstroviaTheme.gold),
                                  const SizedBox(height: 8),
                                  _buildStatBar(
                                      "OXYGEN CAPACITY",
                                      _profile.currentSuit.baseOxygenMinutes /
                                          20.0,
                                      AstroviaTheme.green),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, int index) {
    final isSel = _activeCategoryIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSel,
        labelStyle: AstroviaTheme.orbitron(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isSel ? AstroviaTheme.darkSpace : AstroviaTheme.white,
        ),
        selectedColor: AstroviaTheme.cyan,
        backgroundColor: AstroviaTheme.panelTranslucent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
              color: isSel ? AstroviaTheme.cyan : Colors.transparent),
        ),
        onSelected: (_) {
          AudioService.instance.playClick();
          setState(() => _activeCategoryIndex = index);
        },
      ),
    );
  }

  Widget _buildAnimButton(String label, AstronautAnimState anim) {
    final isSel = _previewAnim == anim;
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        backgroundColor: isSel
            ? AstroviaTheme.cyan.withValues(alpha: 0.25)
            : AstroviaTheme.darkSpace,
        side: BorderSide(
          color: isSel
              ? AstroviaTheme.cyan
              : AstroviaTheme.cyan.withValues(alpha: 0.3),
        ),
      ),
      onPressed: () {
        setState(() => _previewAnim = anim);
      },
      child: Text(
        label,
        style: AstroviaTheme.orbitron(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isSel ? AstroviaTheme.cyan : AstroviaTheme.secondary,
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, double val, Color color) {
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
              "${(val * 100).toInt()}%",
              style: AstroviaTheme.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: val.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: AstroviaTheme.darkSpace,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTabContent(
      List<AstronautCharacter> characters, List<SuitOutfit> suits) {
    switch (_activeCategoryIndex) {
      case 0:
        // Commander Models & Skin Tone
        return ListView(
          children: [
            Text(
              "SELECT COMMANDER MODEL",
              style: AstroviaTheme.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AstroviaTheme.cyan,
              ),
            ),
            const SizedBox(height: 8),
            ...characters.map((char) {
              final isSel = _profile.characterId == char.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSel
                      ? AstroviaTheme.cyan.withValues(alpha: 0.15)
                      : AstroviaTheme.darkSpace,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSel
                        ? AstroviaTheme.cyan
                        : AstroviaTheme.cyan.withValues(alpha: 0.25),
                  ),
                ),
                child: ListTile(
                  title: Text(
                    char.name,
                    style: AstroviaTheme.rajdhani(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.white,
                    ),
                  ),
                  subtitle: Text(
                    char.title,
                    style: AstroviaTheme.inter(
                      fontSize: 11,
                      color: AstroviaTheme.secondary,
                    ),
                  ),
                  trailing: isSel
                      ? const Icon(Icons.check_circle_rounded,
                          color: AstroviaTheme.cyan)
                      : null,
                  onTap: () {
                    AudioService.instance.playClick();
                    setState(() {
                      _profile.characterId = char.id;
                      _profile.skinTone = char.defaultSkinTone;
                    });
                  },
                ),
              );
            }),
            const Divider(color: Color(0x3319D9FF), height: 16),
            Text(
              "SKIN TONE PALETTE",
              style: AstroviaTheme.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AstroviaTheme.gold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSkinToneButton("FAIR", "fair", const Color(0xFFF7CBB0)),
                const SizedBox(width: 8),
                _buildSkinToneButton(
                    "MEDIUM", "medium", const Color(0xFFD69A68)),
                const SizedBox(width: 8),
                _buildSkinToneButton(
                    "BRONZE", "bronze", const Color(0xFF9E653F)),
                const SizedBox(width: 8),
                _buildSkinToneButton("DEEP", "deep", const Color(0xFF5A3825)),
              ],
            ),
          ],
        );

      case 1:
        // Spacesuit Outfits
        return ListView(
          children: [
            Text(
              "AVAILABLE SPACESUITS",
              style: AstroviaTheme.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AstroviaTheme.cyan,
              ),
            ),
            const SizedBox(height: 8),
            ...suits.map((suit) {
              final isSel = _profile.suitId == suit.id;
              final isOwned =
                  MissionState.instance.saveData.ownedSuitIds.contains(suit.id) ||
                      suit.unlockCost == 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSel
                      ? AstroviaTheme.cyan.withValues(alpha: 0.15)
                      : AstroviaTheme.darkSpace,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSel
                        ? AstroviaTheme.cyan
                        : AstroviaTheme.cyan.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suit.name,
                            style: AstroviaTheme.rajdhani(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AstroviaTheme.white,
                            ),
                          ),
                          Text(
                            suit.description,
                            style: AstroviaTheme.inter(
                              fontSize: 10,
                              color: AstroviaTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isOwned)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSel
                              ? AstroviaTheme.cyan
                              : AstroviaTheme.panel,
                        ),
                        onPressed: () {
                          AudioService.instance.playClick();
                          setState(() => _profile.suitId = suit.id);
                        },
                        child: Text(
                          isSel ? "EQUIPPED" : "EQUIP",
                          style: AstroviaTheme.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSel
                                ? AstroviaTheme.darkSpace
                                : AstroviaTheme.white,
                          ),
                        ),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AstroviaTheme.gold,
                        ),
                        onPressed: () {
                          final bought =
                              MissionState.instance.buySuit(suit);
                          if (bought) {
                            AudioService.instance.playSuccess();
                            setState(() => _profile.suitId = suit.id);
                          }
                        },
                        child: Text(
                          "BUY ${suit.unlockCost}C",
                          style: AstroviaTheme.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AstroviaTheme.darkSpace,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        );

      case 2:
        // Visor & Suit Colorways
        return ListView(
          children: [
            Text(
              "HELMET VISOR REFLECTION TINT",
              style: AstroviaTheme.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AstroviaTheme.cyan,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildVisorButton("GOLD", "gold", const Color(0xFFFFC857)),
                const SizedBox(width: 8),
                _buildVisorButton("CYAN", "cyan", const Color(0xFF19D9FF)),
                const SizedBox(width: 8),
                _buildVisorButton("AMBER", "amber", const Color(0xFFFF9100)),
                const SizedBox(width: 8),
                _buildVisorButton(
                    "OBSIDIAN", "obsidian", const Color(0xFF1E293B)),
              ],
            ),
            const Divider(color: Color(0x3319D9FF), height: 20),
            Text(
              "SUIT PRIMARY COLORWAY",
              style: AstroviaTheme.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AstroviaTheme.gold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSuitColorButton("WHITE", 0xFFF0F4F8),
                const SizedBox(width: 8),
                _buildSuitColorButton("NAVY", 0xFF0D1B2A),
                const SizedBox(width: 8),
                _buildSuitColorButton("BLACK", 0xFF1A1A1A),
                const SizedBox(width: 8),
                _buildSuitColorButton("ORANGE", 0xFFE65100),
              ],
            ),
          ],
        );

      case 3:
        // Gear & PLSS
        return ListView(
          children: [
            Text(
              "PLSS LIFE SUPPORT BACKPACK",
              style: AstroviaTheme.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AstroviaTheme.cyan,
              ),
            ),
            const SizedBox(height: 8),
            _buildOptionRow("Compact PLSS Rig", "plss_compact",
                _profile.backpackType, (val) {
              setState(() => _profile.backpackType = val);
            }),
            _buildOptionRow("Extended O2 Tank Rig", "plss_extended",
                _profile.backpackType, (val) {
              setState(() => _profile.backpackType = val);
            }),
            _buildOptionRow(
                "MMU Nitrogen Thruster Jetpack", "mmu_thruster",
                _profile.backpackType, (val) {
              setState(() => _profile.backpackType = val);
            }),
            const Divider(color: Color(0x3319D9FF), height: 16),
            Text(
              "LUNAR TREAD BOOTS",
              style: AstroviaTheme.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AstroviaTheme.gold,
              ),
            ),
            const SizedBox(height: 8),
            _buildOptionRow("Apollo Lunar Tread Sole", "lunar_tread",
                _profile.bootsType, (val) {
              setState(() => _profile.bootsType = val);
            }),
            _buildOptionRow(
                "Magnetic Berthing Soles", "mag_grip", _profile.bootsType,
                (val) {
              setState(() => _profile.bootsType = val);
            }),
            _buildOptionRow("Mars High-Traction Cleats", "mars_trek",
                _profile.bootsType, (val) {
              setState(() => _profile.bootsType = val);
            }),
          ],
        );

      case 4:
      default:
        // Mission Patches
        return ListView(
          children: [
            Text(
              "SHOULDER MISSION EMBROIDERY PATCH",
              style: AstroviaTheme.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AstroviaTheme.cyan,
              ),
            ),
            const SizedBox(height: 8),
            _buildOptionRow(
                "Space Apps Challenge 2026", "spaceapps2026",
                _profile.missionPatch, (val) {
              setState(() => _profile.missionPatch = val);
            }),
            _buildOptionRow(
                "Apollo 11 Eagle Crest", "apollo11", _profile.missionPatch,
                (val) {
              setState(() => _profile.missionPatch = val);
            }),
            _buildOptionRow(
                "Artemis Lunar Gateway", "artemis", _profile.missionPatch,
                (val) {
              setState(() => _profile.missionPatch = val);
            }),
            _buildOptionRow(
                "Space Shuttle Discovery", "shuttle", _profile.missionPatch,
                (val) {
              setState(() => _profile.missionPatch = val);
            }),
          ],
        );
    }
  }

  Widget _buildSkinToneButton(String label, String tone, Color color) {
    final isSel = _profile.skinTone == tone;
    return InkWell(
      onTap: () {
        AudioService.instance.playClick();
        setState(() => _profile.skinTone = tone);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AstroviaTheme.darkSpace,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSel ? AstroviaTheme.cyan : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AstroviaTheme.rajdhani(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSel ? AstroviaTheme.cyan : AstroviaTheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisorButton(String label, String tint, Color color) {
    final isSel = _profile.helmetVisorTint == tint;
    return InkWell(
      onTap: () {
        AudioService.instance.playClick();
        setState(() => _profile.helmetVisorTint = tint);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AstroviaTheme.darkSpace,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSel ? AstroviaTheme.cyan : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AstroviaTheme.rajdhani(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSel ? AstroviaTheme.cyan : AstroviaTheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuitColorButton(String label, int colorVal) {
    final isSel = _profile.primaryColorValue == colorVal;
    return InkWell(
      onTap: () {
        AudioService.instance.playClick();
        setState(() => _profile.primaryColorValue = colorVal);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AstroviaTheme.darkSpace,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSel ? AstroviaTheme.cyan : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Color(colorVal)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AstroviaTheme.rajdhani(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSel ? AstroviaTheme.cyan : AstroviaTheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(String label, String val, String currentVal,
      Function(String) onSelect) {
    final isSel = currentVal == val;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: InkWell(
        onTap: () {
          AudioService.instance.playClick();
          onSelect(val);
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSel
                ? AstroviaTheme.cyan.withValues(alpha: 0.15)
                : AstroviaTheme.darkSpace,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSel
                  ? AstroviaTheme.cyan
                  : AstroviaTheme.cyan.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AstroviaTheme.rajdhani(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSel ? AstroviaTheme.cyan : AstroviaTheme.white,
                ),
              ),
              if (isSel)
                const Icon(Icons.check_circle_rounded,
                    color: AstroviaTheme.cyan, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
