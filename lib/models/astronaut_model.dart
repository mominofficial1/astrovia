import 'package:flutter/material.dart';

enum Gender { male, female }

class AstronautCharacter {
  final String id;
  final String name;
  final String title;
  final Gender gender;
  final String defaultSkinTone;
  final String bio;
  final String avatarAsset;

  const AstronautCharacter({
    required this.id,
    required this.name,
    required this.title,
    required this.gender,
    required this.defaultSkinTone,
    required this.bio,
    required this.avatarAsset,
  });

  static const List<AstronautCharacter> availableCharacters = [
    AstronautCharacter(
      id: "alex",
      name: "ALEX MERCER",
      title: "Mission Commander & Test Pilot",
      gender: Gender.male,
      defaultSkinTone: "fair",
      bio: "Former naval aviator and veteran of 3 orbital training expeditions.",
      avatarAsset: "assets/images/card_astronaut.jpg",
    ),
    AstronautCharacter(
      id: "maya",
      name: "MAYA LIN",
      title: "Robotics & Payload Specialist",
      gender: Gender.female,
      defaultSkinTone: "medium",
      bio: "Aerospace engineer with expertise in autonomous rover systems.",
      avatarAsset: "assets/images/card_astronaut.jpg",
    ),
    AstronautCharacter(
      id: "marcus",
      name: "MARCUS VANCE",
      title: "Propulsion & EVA Specialist",
      gender: Gender.male,
      defaultSkinTone: "deep",
      bio: "Specialist in spacewalk operations and deep-space trajectory docking.",
      avatarAsset: "assets/images/card_astronaut.jpg",
    ),
    AstronautCharacter(
      id: "elena",
      name: "ELENA ROSTOVA",
      title: "Planetary Field Geologist",
      gender: Gender.female,
      defaultSkinTone: "bronze",
      bio: "Geochemist dedicated to extraterrestrial regolith and volatile analysis.",
      avatarAsset: "assets/images/card_astronaut.jpg",
    ),
  ];
}

class SuitOutfit {
  final String id;
  final String name;
  final String description;
  final double thermalProtection; // 0.0 - 1.0
  final double mobility; // 0.0 - 1.0
  final double baseOxygenMinutes;
  final int unlockCost;
  final String imageAsset;

  const SuitOutfit({
    required this.id,
    required this.name,
    required this.description,
    required this.thermalProtection,
    required this.mobility,
    required this.baseOxygenMinutes,
    required this.unlockCost,
    required this.imageAsset,
  });

  static const List<SuitOutfit> availableSuits = [
    SuitOutfit(
      id: "explorer",
      name: "EXPLORER SUIT",
      description: "Agile, multi-layer EVA suit suited for general planetary surface mobility.",
      thermalProtection: 0.80,
      mobility: 0.90,
      baseOxygenMinutes: 12.0,
      unlockCost: 0, // Free starter
      imageAsset: "assets/images/suit_explorer.jpg",
    ),
    SuitOutfit(
      id: "lunar_a7l",
      name: "LUNAR A7L SUIT",
      description: "Classic Apollo-inspired reinforced 21-layer Beta cloth and Chromel-R fabric.",
      thermalProtection: 0.90,
      mobility: 0.75,
      baseOxygenMinutes: 14.0,
      unlockCost: 150,
      imageAsset: "assets/images/suit_lunar.jpg",
    ),
    SuitOutfit(
      id: "deepspace",
      name: "DEEP SPACE MK-IV",
      description: "Advanced cryogenic-shielded micro-meteoroid exoskeleton with integrated neural telemetry.",
      thermalProtection: 0.98,
      mobility: 0.65,
      baseOxygenMinutes: 18.0,
      unlockCost: 300,
      imageAsset: "assets/images/suit_deepspace.jpg",
    ),
    SuitOutfit(
      id: "mars_biosuit",
      name: "MARS BIO-PRESSURE SUIT",
      description: "Second-skin mechanical counter-pressure suit designed for Martian gravitational trekking.",
      thermalProtection: 0.88,
      mobility: 0.95,
      baseOxygenMinutes: 15.0,
      unlockCost: 450,
      imageAsset: "assets/images/suit_explorer.jpg",
    ),
  ];
}

class AstronautProfile {
  String characterId;
  String callsign;
  String skinTone; // "fair", "medium", "bronze", "deep"
  String hairStyle; // "crew", "pixie", "ponytail", "textured"
  String hairColor; // "black", "brown", "blonde", "silver"
  String suitId;
  String helmetVisorTint; // "gold", "cyan", "amber", "obsidian"
  String glovesType; // "standard", "heavy_duty", "tactile"
  String bootsType; // "lunar_tread", "mag_grip", "mars_trek"
  String backpackType; // "plss_compact", "plss_extended", "mmu_thruster"
  int primaryColorValue; // ARGB color
  int secondaryColorValue; // ARGB color
  String missionPatch; // "apollo11", "artemis", "shuttle", "spaceapps2026"
  List<String> accessories; // ["headlamp", "arm_pad", "chest_cam"]

  AstronautProfile({
    this.characterId = "alex",
    this.callsign = "MOMIN",
    this.skinTone = "fair",
    this.hairStyle = "crew",
    this.hairColor = "black",
    this.suitId = "explorer",
    this.helmetVisorTint = "gold",
    this.glovesType = "standard",
    this.bootsType = "lunar_tread",
    this.backpackType = "plss_compact",
    this.primaryColorValue = 0xFFF0F4F8, // Crisp White
    this.secondaryColorValue = 0xFF19D9FF, // Cyan
    this.missionPatch = "spaceapps2026",
    List<String>? accessories,
  }) : accessories = accessories ?? ["headlamp", "arm_pad"];

  Color get primaryColor => Color(primaryColorValue);
  Color get secondaryColor => Color(secondaryColorValue);

  Color get visorColor {
    switch (helmetVisorTint) {
      case "cyan":
        return const Color(0xFF19D9FF);
      case "amber":
        return const Color(0xFFFF9100);
      case "obsidian":
        return const Color(0xFF1E293B);
      case "gold":
      default:
        return const Color(0xFFFFC857);
    }
  }

  Color get skinColor {
    switch (skinTone) {
      case "deep":
        return const Color(0xFF5A3825);
      case "bronze":
        return const Color(0xFF9E653F);
      case "medium":
        return const Color(0xFFD69A68);
      case "fair":
      default:
        return const Color(0xFFF7CBB0);
    }
  }

  Color get hairColorActual {
    switch (hairColor) {
      case "blonde":
        return const Color(0xFFE2C482);
      case "brown":
        return const Color(0xFF4A3319);
      case "silver":
        return const Color(0xFFB0BEC5);
      case "black":
      default:
        return const Color(0xFF1A1A1A);
    }
  }

  SuitOutfit get currentSuit {
    return SuitOutfit.availableSuits.firstWhere(
      (s) => s.id == suitId,
      orElse: () => SuitOutfit.availableSuits.first,
    );
  }

  AstronautCharacter get character {
    return AstronautCharacter.availableCharacters.firstWhere(
      (c) => c.id == characterId,
      orElse: () => AstronautCharacter.availableCharacters.first,
    );
  }

  Map<String, dynamic> toJson() => {
        'characterId': characterId,
        'callsign': callsign,
        'skinTone': skinTone,
        'hairStyle': hairStyle,
        'hairColor': hairColor,
        'suitId': suitId,
        'helmetVisorTint': helmetVisorTint,
        'glovesType': glovesType,
        'bootsType': bootsType,
        'backpackType': backpackType,
        'primaryColorValue': primaryColorValue,
        'secondaryColorValue': secondaryColorValue,
        'missionPatch': missionPatch,
        'accessories': accessories,
      };

  factory AstronautProfile.fromJson(Map<String, dynamic> json) => AstronautProfile(
        characterId: json['characterId'] as String? ?? "alex",
        callsign: json['callsign'] as String? ?? "MOMIN",
        skinTone: json['skinTone'] as String? ?? "fair",
        hairStyle: json['hairStyle'] as String? ?? "crew",
        hairColor: json['hairColor'] as String? ?? "black",
        suitId: json['suitId'] as String? ?? "explorer",
        helmetVisorTint: json['helmetVisorTint'] as String? ?? "gold",
        glovesType: json['glovesType'] as String? ?? "standard",
        bootsType: json['bootsType'] as String? ?? "lunar_tread",
        backpackType: json['backpackType'] as String? ?? "plss_compact",
        primaryColorValue: json['primaryColorValue'] as int? ?? 0xFFF0F4F8,
        secondaryColorValue: json['secondaryColorValue'] as int? ?? 0xFF19D9FF,
        missionPatch: json['missionPatch'] as String? ?? "spaceapps2026",
        accessories: (json['accessories'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      );
}
