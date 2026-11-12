import 'package:flutter/foundation.dart';
import '../models/astronaut_model.dart';
import '../models/inventory_model.dart';
import '../models/mission_model.dart';
import '../models/save_data.dart';
import '../models/spacecraft_model.dart';
import '../services/save_manager.dart';

class MissionState extends ChangeNotifier {
  static final MissionState instance = MissionState._internal();
  MissionState._internal() {
    _loadFromSave();
  }

  late AstraviaSaveData saveData;
  late InventoryBag bag;

  // Active mission run-state
  MissionModel? currentMission;
  Map<String, bool> activeObjectiveStates = {};
  double currentOxygen = 1.0;
  double currentStamina = 1.0;
  double currentBattery = 1.0;
  double currentFuel = 1.0;
  double currentHull = 1.0;
  List<InventoryItem> activeVehicleStorage = [];
  bool isHatchOpen = false;
  bool isOutsideVehicle = false;
  bool isRoverMounted = false;
  int missionElapsedTimeSeconds = 0;
  String missionAlertMessage = "MISSION CONTROL READY • ALL SYSTEMS NOMINAL";

  // Backward compatibility fields
  String get astronautName => saveData.playerProfile.callsign;
  set astronautName(String val) => setAstronautName(val);

  int get level => saveData.unlockedCampaignLevel;
  int get xp => saveData.xp;
  int get coins => saveData.coins;
  int get science => saveData.xp;
  int get exploration => saveData.unlockedCampaignLevel * 100;

  String get selectedSuit => saveData.playerProfile.currentSuit.name;
  String get selectedRocket => saveData.activeSpacecraftBuildName;
  bool get soundMuted => saveData.settings.isMuted;

  bool roverScanned = false;
  bool sampleCollected = false;

  void _loadFromSave() {
    saveData = SaveManager.instance.data;
    bag = InventoryBag(maxCapacityKg: 15.0);
  }

  void refreshFromSave() {
    _loadFromSave();
    notifyListeners();
  }

  // --- Callsign & Profile ---
  void setAstronautName(String name) {
    if (name.trim().isNotEmpty) {
      saveData.playerProfile.callsign = name.trim().toUpperCase();
      SaveManager.instance.save();
      notifyListeners();
    }
  }

  void updateAstronautProfile(AstronautProfile profile) {
    saveData.playerProfile = profile;
    SaveManager.instance.save();
    notifyListeners();
  }

  // --- Suits & Cosmetics ---
  void selectSuit(String suitName) {
    final match = SuitOutfit.availableSuits.firstWhere(
      (s) => s.name == suitName,
      orElse: () => SuitOutfit.availableSuits.first,
    );
    saveData.playerProfile.suitId = match.id;
    SaveManager.instance.save();
    notifyListeners();
  }

  bool buySuit(SuitOutfit suit) {
    if (saveData.coins >= suit.unlockCost) {
      saveData.coins -= suit.unlockCost;
      if (!saveData.ownedSuitIds.contains(suit.id)) {
        saveData.ownedSuitIds.add(suit.id);
      }
      saveData.playerProfile.suitId = suit.id;
      SaveManager.instance.save();
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- Spacecraft Selection & Builder ---
  void selectRocket(String rocketName) {
    saveData.activeSpacecraftBuildName = rocketName;
    SaveManager.instance.save();
    notifyListeners();
  }

  SpacecraftBuild get activeSpacecraft {
    return saveData.savedSpacecraftBuilds.firstWhere(
      (b) => b.name == saveData.activeSpacecraftBuildName,
      orElse: () => saveData.savedSpacecraftBuilds.first,
    );
  }

  void saveSpacecraftBuild(SpacecraftBuild build) {
    final idx = saveData.savedSpacecraftBuilds.indexWhere((b) => b.name == build.name);
    if (idx >= 0) {
      saveData.savedSpacecraftBuilds[idx] = build;
    } else {
      saveData.savedSpacecraftBuilds.add(build);
    }
    saveData.activeSpacecraftBuildName = build.name;
    SaveManager.instance.save();
    notifyListeners();
  }

  // --- Audio Toggle ---
  void toggleSound() {
    saveData.settings.isMuted = !saveData.settings.isMuted;
    SaveManager.instance.save();
    notifyListeners();
  }

  // --- Mission Lifecycle ---
  void startMission(MissionModel mission) {
    currentMission = mission;
    activeObjectiveStates.clear();
    for (final obj in mission.objectives) {
      activeObjectiveStates[obj.key] = false;
    }
    currentOxygen = 1.0;
    currentStamina = 1.0;
    currentBattery = 1.0;
    currentFuel = 1.0;
    currentHull = 1.0;
    missionElapsedTimeSeconds = 0;
    isHatchOpen = false;
    isOutsideVehicle = false;
    isRoverMounted = false;
    bag.clear();
    activeVehicleStorage.clear();
    missionAlertMessage = "MISSION INITIALIZED: ${mission.title}";
    roverScanned = false;
    sampleCollected = false;
    notifyListeners();
  }

  void setMissionAlert(String message) {
    missionAlertMessage = message;
    notifyListeners();
  }

  bool isObjectiveCompleted(String key) {
    return activeObjectiveStates[key] ?? false;
  }

  void completeObjective(String key) {
    if (activeObjectiveStates.containsKey(key) && activeObjectiveStates[key] == false) {
      activeObjectiveStates[key] = true;
      if (kDebugMode) {
        print("Objective completed: $key");
      }
      notifyListeners();
    }
  }

  bool get areAllPrimaryObjectivesCompleted {
    if (currentMission == null) return false;
    for (final obj in currentMission!.objectives) {
      if (!obj.isOptional && (activeObjectiveStates[obj.key] != true)) {
        return false;
      }
    }
    return true;
  }

  // Pick up world item into bag
  bool pickupWorldItem(InventoryItem item) {
    if (bag.addItem(item)) {
      setMissionAlert("COLLECTED: ${item.name} (${item.massKg} kg)");
      notifyListeners();
      return true;
    } else {
      setMissionAlert("WARNING: Astronaut sample bag is full! Transfer items to vehicle.");
      notifyListeners();
      return false;
    }
  }

  // Transfer all samples in bag to lander storage
  void transferSamplesToVehicleStorage() {
    if (bag.items.isNotEmpty) {
      final count = bag.items.length;
      bag.transferAllToVehicle(activeVehicleStorage);
      setMissionAlert("TRANSFERRED $count SAMPLES TO LANDER VAULT.");
      completeObjective("store_in_lander");
      completeObjective("secure_equipment");
      notifyListeners();
    }
  }

  // Mission Results: Success
  Map<String, dynamic> completeMissionSuccess({
    required int baseScore,
    required int timeSeconds,
  }) {
    if (currentMission == null) return {};

    final mission = currentMission!;
    final levelNum = mission.levelNumber;
    final existingRecord = saveData.levelRecords[levelNum];

    // Star rating evaluation: 3 stars if done efficiently, 2 stars standard, 1 star minimal
    int stars = 3;
    if (currentOxygen < 0.20 || currentFuel < 0.20) stars = 2;
    if (timeSeconds > 360) stars = 1;

    int coinPayout = mission.coinReward;
    int xpPayout = mission.xpReward;
    bool isFirstClear = existingRecord == null || !existingRecord.isCompleted;

    if (!isFirstClear) {
      // Replay rewards are 25% of first-time clear per specification
      coinPayout = (coinPayout * 0.25).toInt();
      xpPayout = (xpPayout * 0.25).toInt();
    }

    saveData.coins += coinPayout;
    saveData.xp += xpPayout;

    // Record best score
    final bestScore = existingRecord != null && existingRecord.bestScore > baseScore
        ? existingRecord.bestScore
        : baseScore;
    final bestStars = existingRecord != null && existingRecord.starsEarned > stars
        ? existingRecord.starsEarned
        : stars;

    saveData.levelRecords[levelNum] = LevelProgressRecord(
      levelNumber: levelNum,
      isCompleted: true,
      starsEarned: bestStars,
      bestScore: bestScore,
      bestTimeSeconds: timeSeconds,
      firstRewardClaimed: true,
    );

    // Progression: Unlock level N+1
    if (levelNum < 10) {
      if (saveData.unlockedCampaignLevel <= levelNum) {
        saveData.unlockedCampaignLevel = levelNum + 1;
      }
    } else if (levelNum == 10) {
      saveData.isCampaignCompleted = true;
    }

    // Persist to disk
    SaveManager.instance.save();
    notifyListeners();

    return {
      'mission': mission,
      'coinsAwarded': coinPayout,
      'xpAwarded': xpPayout,
      'stars': stars,
      'isFirstClear': isFirstClear,
      'unlockedNext': levelNum < 10 && saveData.unlockedCampaignLevel == levelNum + 1,
      'campaignCompleted': saveData.isCampaignCompleted,
    };
  }

  // Backward compatibility helper
  void completeSampleScan() {
    roverScanned = true;
    saveData.xp += 250;
    saveData.coins += 50;
    SaveManager.instance.save();
    notifyListeners();
  }

  void resetMission() {
    roverScanned = false;
    sampleCollected = false;
    currentOxygen = 1.0;
    currentStamina = 1.0;
    currentBattery = 1.0;
    currentFuel = 1.0;
    currentHull = 1.0;
    bag.clear();
    activeVehicleStorage.clear();
    notifyListeners();
  }
}
