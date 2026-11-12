import 'astronaut_model.dart';
import 'inventory_model.dart';
import 'spacecraft_model.dart';

class LevelProgressRecord {
  final int levelNumber;
  final bool isCompleted;
  final int starsEarned; // 1, 2, or 3 stars
  final int bestScore;
  final int bestTimeSeconds;
  final bool firstRewardClaimed;

  const LevelProgressRecord({
    required this.levelNumber,
    this.isCompleted = false,
    this.starsEarned = 0,
    this.bestScore = 0,
    this.bestTimeSeconds = 0,
    this.firstRewardClaimed = false,
  });

  Map<String, dynamic> toJson() => {
        'levelNumber': levelNumber,
        'isCompleted': isCompleted,
        'starsEarned': starsEarned,
        'bestScore': bestScore,
        'bestTimeSeconds': bestTimeSeconds,
        'firstRewardClaimed': firstRewardClaimed,
      };

  factory LevelProgressRecord.fromJson(Map<String, dynamic> json) => LevelProgressRecord(
        levelNumber: json['levelNumber'] as int,
        isCompleted: json['isCompleted'] as bool? ?? false,
        starsEarned: json['starsEarned'] as int? ?? 0,
        bestScore: json['bestScore'] as int? ?? 0,
        bestTimeSeconds: json['bestTimeSeconds'] as int? ?? 0,
        firstRewardClaimed: json['firstRewardClaimed'] as bool? ?? false,
      );
}

class GameSettings {
  double masterVolume;
  double sfxVolume;
  double musicVolume;
  bool isMuted;
  bool touchControlsEnabled;
  bool reducedMotion;
  double cameraSensitivity;
  bool highQualityGraphics;

  GameSettings({
    this.masterVolume = 0.85,
    this.sfxVolume = 0.85,
    this.musicVolume = 0.65,
    this.isMuted = false,
    this.touchControlsEnabled = true,
    this.reducedMotion = false,
    this.cameraSensitivity = 1.0,
    this.highQualityGraphics = true,
  });

  Map<String, dynamic> toJson() => {
        'masterVolume': masterVolume,
        'sfxVolume': sfxVolume,
        'musicVolume': musicVolume,
        'isMuted': isMuted,
        'touchControlsEnabled': touchControlsEnabled,
        'reducedMotion': reducedMotion,
        'cameraSensitivity': cameraSensitivity,
        'highQualityGraphics': highQualityGraphics,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
        masterVolume: (json['masterVolume'] as num?)?.toDouble() ?? 0.85,
        sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 0.85,
        musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.65,
        isMuted: json['isMuted'] as bool? ?? false,
        touchControlsEnabled: json['touchControlsEnabled'] as bool? ?? true,
        reducedMotion: json['reducedMotion'] as bool? ?? false,
        cameraSensitivity: (json['cameraSensitivity'] as num?)?.toDouble() ?? 1.0,
        highQualityGraphics: json['highQualityGraphics'] as bool? ?? true,
      );
}

class AstraviaSaveData {
  static const int currentVersion = 2;

  int version;
  AstronautProfile playerProfile;
  int coins;
  int xp;
  int unlockedCampaignLevel; // Initially 1; completing level N unlocks N+1
  bool isCampaignCompleted;
  Map<int, LevelProgressRecord> levelRecords;
  List<String> ownedSuitIds;
  List<String> ownedVisorIds;
  List<String> ownedBackpackIds;
  List<String> ownedBootsIds;
  List<String> ownedColorways;
  List<String> ownedPatches;
  List<String> ownedLiveries;
  List<SpacecraftBuild> savedSpacecraftBuilds;
  String activeSpacecraftBuildName;
  List<InventoryItem> persistentInventory;
  GameSettings settings;
  bool tutorialCompleted;

  AstraviaSaveData({
    this.version = currentVersion,
    AstronautProfile? playerProfile,
    this.coins = 250, // Initial starting coins
    this.xp = 0,
    this.unlockedCampaignLevel = 1,
    this.isCampaignCompleted = false,
    Map<int, LevelProgressRecord>? levelRecords,
    List<String>? ownedSuitIds,
    List<String>? ownedVisorIds,
    List<String>? ownedBackpackIds,
    List<String>? ownedBootsIds,
    List<String>? ownedColorways,
    List<String>? ownedPatches,
    List<String>? ownedLiveries,
    List<SpacecraftBuild>? savedSpacecraftBuilds,
    this.activeSpacecraftBuildName = "Saturn V / CSM Apollo",
    List<InventoryItem>? persistentInventory,
    GameSettings? settings,
    this.tutorialCompleted = false,
  })  : playerProfile = playerProfile ?? AstronautProfile(),
        levelRecords = levelRecords ?? {1: const LevelProgressRecord(levelNumber: 1)},
        ownedSuitIds = ownedSuitIds ?? ["explorer"],
        ownedVisorIds = ownedVisorIds ?? ["gold"],
        ownedBackpackIds = ownedBackpackIds ?? ["plss_compact"],
        ownedBootsIds = ownedBootsIds ?? ["lunar_tread"],
        ownedColorways = ownedColorways ?? ["white"],
        ownedPatches = ownedPatches ?? ["spaceapps2026", "apollo11"],
        ownedLiveries = ownedLiveries ?? ["apollo_white"],
        savedSpacecraftBuilds = savedSpacecraftBuilds ?? [
          SpacecraftBuild.starterApollo,
          SpacecraftBuild.starterLunarLander,
          SpacecraftBuild.starterRoboticProbe,
        ],
        persistentInventory = persistentInventory ?? [],
        settings = settings ?? GameSettings();

  // XP rank calculation (independent of campaign progression)
  int get astronautRank {
    if (xp >= 10000) return 5; // Master Astronaut / Flight Director
    if (xp >= 5000) return 4; // Senior Commander
    if (xp >= 2500) return 3; // Mission Specialist
    if (xp >= 1000) return 2; // Flight Officer
    return 1; // Cadet Astronaut
  }

  String get rankTitle {
    switch (astronautRank) {
      case 5:
        return "COMMANDER GENERAL (RANK V)";
      case 4:
        return "SENIOR COMMANDER (RANK IV)";
      case 3:
        return "MISSION SPECIALIST (RANK III)";
      case 2:
        return "FLIGHT OFFICER (RANK II)";
      case 1:
      default:
        return "CADET ASTRONAUT (RANK I)";
    }
  }

  bool isLevelUnlocked(int levelNumber) {
    if (levelNumber == 1) return true;
    return levelNumber <= unlockedCampaignLevel;
  }

  bool isLevelCompleted(int levelNumber) {
    return levelRecords[levelNumber]?.isCompleted ?? false;
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'playerProfile': playerProfile.toJson(),
        'coins': coins,
        'xp': xp,
        'unlockedCampaignLevel': unlockedCampaignLevel,
        'isCampaignCompleted': isCampaignCompleted,
        'levelRecords': levelRecords.map((k, v) => MapEntry(k.toString(), v.toJson())),
        'ownedSuitIds': ownedSuitIds,
        'ownedVisorIds': ownedVisorIds,
        'ownedBackpackIds': ownedBackpackIds,
        'ownedBootsIds': ownedBootsIds,
        'ownedColorways': ownedColorways,
        'ownedPatches': ownedPatches,
        'ownedLiveries': ownedLiveries,
        'savedSpacecraftBuilds': savedSpacecraftBuilds.map((b) => b.toJson()).toList(),
        'activeSpacecraftBuildName': activeSpacecraftBuildName,
        'persistentInventory': persistentInventory.map((i) => i.toJson()).toList(),
        'settings': settings.toJson(),
        'tutorialCompleted': tutorialCompleted,
      };

  factory AstraviaSaveData.fromJson(Map<String, dynamic> json) {
    final rawRecords = json['levelRecords'] as Map<String, dynamic>? ?? {};
    final parsedRecords = <int, LevelProgressRecord>{};
    rawRecords.forEach((k, v) {
      final intKey = int.tryParse(k) ?? 1;
      parsedRecords[intKey] = LevelProgressRecord.fromJson(v as Map<String, dynamic>);
    });
    if (!parsedRecords.containsKey(1)) {
      parsedRecords[1] = const LevelProgressRecord(levelNumber: 1);
    }

    final rawBuilds = json['savedSpacecraftBuilds'] as List<dynamic>?;
    final parsedBuilds = rawBuilds != null
        ? rawBuilds.map((e) => SpacecraftBuild.fromJson(e as Map<String, dynamic>)).toList()
        : [
            SpacecraftBuild.starterApollo,
            SpacecraftBuild.starterLunarLander,
            SpacecraftBuild.starterRoboticProbe,
          ];

    final rawInv = json['persistentInventory'] as List<dynamic>?;
    final parsedInv = rawInv != null
        ? rawInv.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>)).toList()
        : <InventoryItem>[];

    return AstraviaSaveData(
      version: json['version'] as int? ?? currentVersion,
      playerProfile: json['playerProfile'] != null
          ? AstronautProfile.fromJson(json['playerProfile'] as Map<String, dynamic>)
          : AstronautProfile(),
      coins: json['coins'] as int? ?? 250,
      xp: json['xp'] as int? ?? 0,
      unlockedCampaignLevel: json['unlockedCampaignLevel'] as int? ?? 1,
      isCampaignCompleted: json['isCampaignCompleted'] as bool? ?? false,
      levelRecords: parsedRecords,
      ownedSuitIds: (json['ownedSuitIds'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      ownedVisorIds: (json['ownedVisorIds'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      ownedBackpackIds: (json['ownedBackpackIds'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      ownedBootsIds: (json['ownedBootsIds'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      ownedColorways: (json['ownedColorways'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      ownedPatches: (json['ownedPatches'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      ownedLiveries: (json['ownedLiveries'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      savedSpacecraftBuilds: parsedBuilds,
      activeSpacecraftBuildName: json['activeSpacecraftBuildName'] as String? ?? "Saturn V / CSM Apollo",
      persistentInventory: parsedInv,
      settings: json['settings'] != null
          ? GameSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : GameSettings(),
      tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
    );
  }
}

