import 'package:flutter/material.dart';
import '../rendering/astronaut_renderer.dart';
import '../rendering/spacecraft_renderer.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';

class ShopItemData {
  final String id;
  final String category; // "suit", "visor", "backpack", "boots", "colorway", "patch", "livery"
  final String title;
  final String description;
  final int cost;
  final IconData icon;
  final String? effectStat;

  const ShopItemData({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.cost,
    required this.icon,
    this.effectStat,
  });
}

class ScreenSuitShop extends StatefulWidget {
  const ScreenSuitShop({super.key});

  @override
  State<ScreenSuitShop> createState() => _ScreenSuitShopState();
}

class _ScreenSuitShopState extends State<ScreenSuitShop>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _activeCategoryIndex = 0;

  final List<String> _categories = [
    "SPACESUITS",
    "HELMET VISORS",
    "PLSS BACKPACKS",
    "BOOTS & GLOVES",
    "SUIT COLORWAYS",
    "MISSION PATCHES",
    "SPACECRAFT LIVERIES",
  ];

  static const List<ShopItemData> _allShopItems = [
    // 1. SPACESUITS
    ShopItemData(
      id: "explorer",
      category: "suit",
      title: "EXPLORER EVA SUIT",
      description: "Agile, multi-layer EVA suit engineered for general surface mobility.",
      cost: 0,
      icon: Icons.accessibility_new_rounded,
      effectStat: "OXYGEN: 12 MINS • MOBILITY: 90%",
    ),
    ShopItemData(
      id: "lunar_a7l",
      category: "suit",
      title: "LUNAR A7L SUIT",
      description: "Classic Apollo-inspired 21-layer Beta cloth and Chromel-R abrasive protection.",
      cost: 150,
      icon: Icons.shield_rounded,
      effectStat: "OXYGEN: 14 MINS • THERMAL: 90%",
    ),
    ShopItemData(
      id: "deepspace",
      category: "suit",
      title: "DEEP SPACE MK-IV",
      description: "Cryogenic-shielded micro-meteoroid exoskeleton with integrated neural telemetry.",
      cost: 300,
      icon: Icons.security_rounded,
      effectStat: "OXYGEN: 18 MINS • THERMAL: 98%",
    ),
    ShopItemData(
      id: "mars_biosuit",
      category: "suit",
      title: "MARS BIO-PRESSURE SUIT",
      description: "Second-skin mechanical counter-pressure suit designed for Martian trekking.",
      cost: 450,
      icon: Icons.biotech_rounded,
      effectStat: "OXYGEN: 15 MINS • MOBILITY: 95%",
    ),

    // 2. HELMET VISORS
    ShopItemData(
      id: "gold",
      category: "visor",
      title: "SOLAR GOLD REFLECTIVE",
      description: "Vapor-deposited pure gold thin film blocking extreme solar UV & infrared.",
      cost: 0,
      icon: Icons.remove_red_eye_rounded,
      effectStat: "GLARE FILTER: 100% (STANDARD)",
    ),
    ShopItemData(
      id: "cyan",
      category: "visor",
      title: "POLARIZED CYAN HUD",
      description: "Heads-Up Display optic coating with augmented reality hazard highlighting.",
      cost: 100,
      icon: Icons.visibility_rounded,
      effectStat: "CONTRAST BOOST: +15%",
    ),
    ShopItemData(
      id: "amber",
      category: "visor",
      title: "AMBER RADIATION TINT",
      description: "Enhanced optical contrast for low-light lunar crater rim operations.",
      cost: 150,
      icon: Icons.wb_sunny_rounded,
      effectStat: "SHADOW CLARITY: +20%",
    ),
    ShopItemData(
      id: "obsidian",
      category: "visor",
      title: "OBSIDIAN STEALTH VISOR",
      description: "High-density polarized composite for deep solar observation expeditions.",
      cost: 200,
      icon: Icons.nightlight_round,
      effectStat: "THERMAL DEFLECTION: +10%",
    ),

    // 3. PLSS BACKPACKS
    ShopItemData(
      id: "plss_compact",
      category: "backpack",
      title: "COMPACT LUNAR PLSS",
      description: "Standard primary life support rig with closed-loop sublimator cooling.",
      cost: 0,
      icon: Icons.backpack_rounded,
      effectStat: "CAPACITY: STANDARD",
    ),
    ShopItemData(
      id: "plss_extended",
      category: "backpack",
      title: "EXTENDED DURATION PLSS",
      description: "Dual oxygen bottles and enlarged lithium hydroxide carbon dioxide scrubbers.",
      cost: 180,
      icon: Icons.medical_services_rounded,
      effectStat: "OXYGEN CAPACITY: +25%",
    ),
    ShopItemData(
      id: "mmu_thruster",
      category: "backpack",
      title: "MMU ZERO-G NITROGEN RIG",
      description: "Manned Maneuvering Unit with 24 nitrogen gas translation thrusters.",
      cost: 350,
      icon: Icons.air_rounded,
      effectStat: "ZERO-G RCS MOBILITY: +40%",
    ),

    // 4. BOOTS & GLOVES
    ShopItemData(
      id: "lunar_tread",
      category: "boots",
      title: "CHROMEL-R LUNAR OVERSHOES",
      description: "Woven metal wire fabric boots resistant to sharp basalt rock shards.",
      cost: 0,
      icon: Icons.snowshoeing_rounded,
      effectStat: "TRACTION: LUNAR REGOLITH",
    ),
    ShopItemData(
      id: "mars_trek",
      category: "boots",
      title: "MARTIAN HIGH-TRACTION TREAD",
      description: "Vulcanized ribbed sole designed for sandy dunes and crater delta slopes.",
      cost: 120,
      icon: Icons.hiking_rounded,
      effectStat: "STAMINA DRAIN: -15% ON SLOPES",
    ),
    ShopItemData(
      id: "mag_grip",
      category: "boots",
      title: "MAGNETIC MICROGRAVITY GRIPPERS",
      description: "High-flux electromagnetic soles for uncrewed hull and asteroid anchor.",
      cost: 160,
      icon: Icons.electric_bolt_rounded,
      effectStat: "ZERO-G ANCHOR LOCK",
    ),

    // 5. SUIT COLORWAYS
    ShopItemData(
      id: "white",
      category: "colorway",
      title: "ALPHA NASA CRISP WHITE",
      description: "High albedo thermal reflective white finish.",
      cost: 0,
      icon: Icons.palette_rounded,
      effectStat: "THERMAL EMISSIVITY: 0.85",
    ),
    ShopItemData(
      id: "navy",
      category: "colorway",
      title: "ORBITAL DEEP NAVY",
      description: "Midnight aerospace commander composite finish.",
      cost: 100,
      icon: Icons.palette_rounded,
      effectStat: "COSMETIC STYLE",
    ),
    ShopItemData(
      id: "black",
      category: "colorway",
      title: "STEALTH CARBON BLACK",
      description: "Matte carbon-fiber ballistic weave finish.",
      cost: 150,
      icon: Icons.palette_rounded,
      effectStat: "COSMETIC STYLE",
    ),
    ShopItemData(
      id: "orange",
      category: "colorway",
      title: "LAUNCH FLIGHT HAZARD ORANGE",
      description: "High-visibility telemetry ascent & entry colorway.",
      cost: 200,
      icon: Icons.palette_rounded,
      effectStat: "COSMETIC STYLE",
    ),

    // 6. MISSION PATCHES
    ShopItemData(
      id: "spaceapps2026",
      category: "patch",
      title: "NASA SPACE APPS 2026",
      description: "Official NASA International Space Apps Challenge insignia.",
      cost: 0,
      icon: Icons.military_tech_rounded,
      effectStat: "SPECIAL COMMENDATION",
    ),
    ShopItemData(
      id: "apollo11",
      category: "patch",
      title: "APOLLO 11 EAGLE PATCH",
      description: "Historic Apollo 11 lunar landing mission patch.",
      cost: 75,
      icon: Icons.military_tech_rounded,
      effectStat: "HISTORICAL COMMEMORATIVE",
    ),
    ShopItemData(
      id: "shuttle",
      category: "patch",
      title: "SPACE SHUTTLE STS INSIGNIA",
      description: "Commemorating 30 years of winged human spaceflight.",
      cost: 125,
      icon: Icons.military_tech_rounded,
      effectStat: "HISTORICAL COMMEMORATIVE",
    ),
    ShopItemData(
      id: "perseverance",
      category: "patch",
      title: "PERSEVERANCE JEZERO 2026",
      description: "Mars Exploration Program ancient delta sample caching badge.",
      cost: 150,
      icon: Icons.military_tech_rounded,
      effectStat: "EXPLORATION BADGE",
    ),

    // 7. SPACECRAFT LIVERIES
    ShopItemData(
      id: "apollo_white",
      category: "livery",
      title: "SATURN / APOLLO MONOCHROME",
      description: "Classic Apollo Command/Service Module black and white roll markings.",
      cost: 0,
      icon: Icons.rocket_rounded,
      effectStat: "VEHICLE LIVERY",
    ),
    ShopItemData(
      id: "discovery_shuttle",
      category: "livery",
      title: "DISCOVERY THERMAL TILE",
      description: "Black silica glass tiles on belly with reinforced carbon-carbon wing edges.",
      cost: 150,
      icon: Icons.rocket_rounded,
      effectStat: "VEHICLE LIVERY",
    ),
    ShopItemData(
      id: "mars_terrarust",
      category: "livery",
      title: "MARTIAN TERRA-RUST",
      description: "High-temperature iron-oxide pigmented thermal skin.",
      cost: 200,
      icon: Icons.rocket_rounded,
      effectStat: "VEHICLE LIVERY",
    ),
    ShopItemData(
      id: "cyber_cyan",
      category: "livery",
      title: "CYBER CYAN LUMINESCENT",
      description: "Electroluminescent titanium matrix for deep vacuum navigation.",
      cost: 300,
      icon: Icons.rocket_rounded,
      effectStat: "VEHICLE LIVERY",
    ),
  ];

  @override
  void initState() {
    super.initState();
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

  bool _isItemOwned(ShopItemData item) {
    if (item.cost == 0) return true;
    final save = MissionState.instance.saveData;
    switch (item.category) {
      case "suit":
        return save.ownedSuitIds.contains(item.id);
      case "visor":
        return save.ownedVisorIds.contains(item.id);
      case "backpack":
        return save.ownedBackpackIds.contains(item.id);
      case "boots":
        return save.ownedBootsIds.contains(item.id);
      case "colorway":
        return save.ownedColorways.contains(item.id);
      case "patch":
        return save.ownedPatches.contains(item.id);
      case "livery":
        return save.ownedLiveries.contains(item.id);
      default:
        return false;
    }
  }

  bool _isItemEquipped(ShopItemData item) {
    final profile = MissionState.instance.saveData.playerProfile;
    switch (item.category) {
      case "suit":
        return profile.suitId == item.id;
      case "visor":
        return profile.helmetVisorTint == item.id;
      case "backpack":
        return profile.backpackType == item.id;
      case "boots":
        return profile.bootsType == item.id;
      case "patch":
        return profile.missionPatch == item.id;
      case "colorway":
        if (item.id == "white") return profile.primaryColorValue == 0xFFF0F4F8;
        if (item.id == "navy") return profile.primaryColorValue == 0xFF0D1B2A;
        if (item.id == "black") return profile.primaryColorValue == 0xFF1A1A1A;
        if (item.id == "orange") return profile.primaryColorValue == 0xFFFF6F00;
        return false;
      default:
        return false;
    }
  }

  void _buyItem(ShopItemData item) {
    AudioService.instance.playClick();
    final bought = MissionState.instance.buyShopItem(
      category: item.category,
      id: item.id,
      cost: item.cost,
    );
    if (bought) {
      AudioService.instance.playSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AstroviaTheme.panel,
          content: Text(
            "PURCHASED: ${item.title} FOR ${item.cost} COINS!",
            style: AstroviaTheme.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AstroviaTheme.cyan,
            ),
          ),
        ),
      );
      setState(() {});
    } else {
      AudioService.instance.playScan();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AstroviaTheme.panel,
          content: Text(
            "INSUFFICIENT COINS! COMPLETE MISSIONS TO EARN MORE.",
            style: AstroviaTheme.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AstroviaTheme.red,
            ),
          ),
        ),
      );
    }
  }

  void _equipItem(ShopItemData item) {
    AudioService.instance.playClick();
    MissionState.instance.equipShopItem(
      category: item.category,
      id: item.id,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = MissionState.instance;
    final categoryKey = [
      "suit",
      "visor",
      "backpack",
      "boots",
      "colorway",
      "patch",
      "livery",
    ][_activeCategoryIndex];

    final categoryItems = _allShopItems.where((i) => i.category == categoryKey).toList();

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // 1. Header Bar: Title, Back, Persistent Coins
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AstroviaTheme.cyan),
                        onPressed: () {
                          AudioService.instance.playClick();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ASTRAVIA EQUIPMENT & SUIT PROVING SHOP",
                            style: AstroviaTheme.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AstroviaTheme.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            "NASA FLIGHT-QUALIFIED SPACESUITS, VISORS, PLSS PACKS & MISSION COSMETICS",
                            style: AstroviaTheme.rajdhani(
                              fontSize: 11,
                              color: AstroviaTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Persistent Coin & Rank Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AstroviaTheme.gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AstroviaTheme.gold, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_rounded, color: AstroviaTheme.gold, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              "${state.coins} COINS",
                              style: AstroviaTheme.orbitron(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Category Tab Row
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (ctx, idx) {
                    final isSel = _activeCategoryIndex == idx;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(_categories[idx]),
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
                          side: BorderSide(color: isSel ? AstroviaTheme.cyan : Colors.transparent),
                        ),
                        onSelected: (_) {
                          AudioService.instance.playClick();
                          setState(() => _activeCategoryIndex = idx);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // 3. Main Body: Left Items List, Right Live 360 Preview
              Expanded(
                child: Row(
                  children: [
                    // Items Grid / List
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AstroviaTheme.panelTranslucent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AstroviaTheme.cyan.withValues(alpha: 0.3)),
                        ),
                        child: ListView.builder(
                          itemCount: categoryItems.length,
                          itemBuilder: (ctx, idx) {
                            final item = categoryItems[idx];
                            final isOwned = _isItemOwned(item);
                            final isEquipped = _isItemEquipped(item);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isEquipped
                                    ? AstroviaTheme.cyan.withValues(alpha: 0.15)
                                    : AstroviaTheme.darkSpace,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isEquipped
                                      ? AstroviaTheme.cyan
                                      : AstroviaTheme.cyan.withValues(alpha: 0.25),
                                  width: isEquipped ? 1.6 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AstroviaTheme.panel,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AstroviaTheme.cyan.withValues(alpha: 0.4)),
                                    ),
                                    child: Icon(item.icon, color: AstroviaTheme.cyan, size: 26),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              item.title,
                                              style: AstroviaTheme.orbitron(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AstroviaTheme.white,
                                              ),
                                            ),
                                            if (isEquipped) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: AstroviaTheme.cyan,
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                                child: Text(
                                                  "ACTIVE LOADOUT",
                                                  style: AstroviaTheme.orbitron(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: AstroviaTheme.darkSpace,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          item.description,
                                          style: AstroviaTheme.inter(
                                            fontSize: 11,
                                            color: AstroviaTheme.secondary,
                                          ),
                                        ),
                                        if (item.effectStat != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            item.effectStat!,
                                            style: AstroviaTheme.rajdhani(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AstroviaTheme.gold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (isOwned)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isEquipped
                                            ? AstroviaTheme.cyan
                                            : AstroviaTheme.panel,
                                        side: BorderSide(
                                          color: isEquipped ? AstroviaTheme.cyan : AstroviaTheme.secondary,
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      ),
                                      onPressed: isEquipped ? null : () => _equipItem(item),
                                      child: Text(
                                        isEquipped ? "EQUIPPED" : "EQUIP",
                                        style: AstroviaTheme.orbitron(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isEquipped
                                              ? AstroviaTheme.darkSpace
                                              : AstroviaTheme.white,
                                        ),
                                      ),
                                    )
                                  else
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AstroviaTheme.gold,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      ),
                                      icon: const Icon(Icons.monetization_on_rounded, size: 16, color: AstroviaTheme.darkSpace),
                                      label: Text(
                                        "BUY ${item.cost}C",
                                        style: AstroviaTheme.orbitron(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AstroviaTheme.darkSpace,
                                        ),
                                      ),
                                      onPressed: () => _buyItem(item),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Right Side: Live Visual 3D Character Preview Canvas
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
                            Text(
                              "LIVE LOADOUT INSPECTION",
                              style: AstroviaTheme.orbitron(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.cyan,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Changes apply in real-time to active playable astronaut & spacecraft.",
                              textAlign: TextAlign.center,
                              style: AstroviaTheme.rajdhani(
                                fontSize: 10,
                                color: AstroviaTheme.secondary,
                              ),
                            ),
                            const Spacer(),

                            if (_activeCategoryIndex == 6)
                              // Spacecraft preview for livery category
                              SpacecraftWidget(
                                buildData: state.activeSpacecraft,
                                scale: 1.0,
                                landingLegsExtended: true,
                              )
                            else
                              // Live Procedural Humanoid Astronaut Preview
                              AnimatedBuilder(
                                animation: _animController,
                                builder: (ctx, child) {
                                  return AstronautAvatarWidget(
                                    profile: state.saveData.playerProfile,
                                    animState: AstronautAnimState.idle,
                                    animPhase: _animController.value,
                                    scale: 2.3,
                                    showHeadlampBeam: true,
                                  );
                                },
                              ),

                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AstroviaTheme.darkSpace,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AstroviaTheme.cyan),
                              ),
                              child: Text(
                                "COMMANDER: ${state.astronautName} • RANK ${state.saveData.astronautRank}",
                                style: AstroviaTheme.orbitron(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.cyan,
                                ),
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
      ),
    );
  }
}

