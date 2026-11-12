import 'package:flutter/foundation.dart';
import '../models/astronaut_model.dart';
import '../models/inventory_model.dart';
import '../models/mission_model.dart';
import '../models/save_data.dart';
import '../models/spacecraft_model.dart';
import '../services/save_manager.dart';

class MissionValidationResult {
  final bool isValid;
  final String failureReason;
  final String attemptId;
  final int completedObjectivesCount;
  final int totalObjectivesCount;
  final Map<String, bool> objectiveStates;
  final int bagItemsCount;
  final int vaultItemsCount;
  final bool crewAboard;
  final bool spacecraftSecured;

  const MissionValidationResult({
    required this.isValid,
    required this.failureReason,
    required this.attemptId,
    required this.completedObjectivesCount,
    required this.totalObjectivesCount,
    required this.objectiveStates,
    required this.bagItemsCount,
    required this.vaultItemsCount,
    required this.crewAboard,
    required this.spacecraftSecured,
  });
}

class MissionState extends ChangeNotifier {
  static final MissionState instance = MissionState._internal();
  MissionState._internal() {
    _loadFromSave();
  }

  late AstraviaSaveData saveData;
  late InventoryBag bag;

  // Active mission run-state
  MissionModel? currentMission;
  String currentAttemptId = "";
  MissionPhase currentPhase = MissionPhase.briefing;
  ControlMode currentControlMode = ControlMode.none;
  bool isSuccessValidated = false;
  String? validationFailureReason;
  int apollo11SamplesCollectedCount = 0;

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

  bool buyShopItem({
    required String category,
    required String id,
    required int cost,
  }) {
    if (saveData.coins < cost) return false;

    bool isOwned = false;
    switch (category) {
      case "suit":
        isOwned = saveData.ownedSuitIds.contains(id);
        if (!isOwned) saveData.ownedSuitIds.add(id);
        saveData.playerProfile.suitId = id;
        break;
      case "visor":
        isOwned = saveData.ownedVisorIds.contains(id);
        if (!isOwned) saveData.ownedVisorIds.add(id);
        saveData.playerProfile.helmetVisorTint = id;
        break;
      case "backpack":
        isOwned = saveData.ownedBackpackIds.contains(id);
        if (!isOwned) saveData.ownedBackpackIds.add(id);
        saveData.playerProfile.backpackType = id;
        break;
      case "boots":
        isOwned = saveData.ownedBootsIds.contains(id);
        if (!isOwned) saveData.ownedBootsIds.add(id);
        saveData.playerProfile.bootsType = id;
        break;
      case "colorway":
        isOwned = saveData.ownedColorways.contains(id);
        if (!isOwned) saveData.ownedColorways.add(id);
        break;
      case "patch":
        isOwned = saveData.ownedPatches.contains(id);
        if (!isOwned) saveData.ownedPatches.add(id);
        saveData.playerProfile.missionPatch = id;
        break;
      case "livery":
        isOwned = saveData.ownedLiveries.contains(id);
        if (!isOwned) saveData.ownedLiveries.add(id);
        break;
    }

    if (isOwned) return false;
    saveData.coins -= cost;
    SaveManager.instance.save();
    notifyListeners();
    return true;
  }

  void equipShopItem({
    required String category,
    required String id,
  }) {
    switch (category) {
      case "suit":
        if (saveData.ownedSuitIds.contains(id) || id == "explorer") {
          saveData.playerProfile.suitId = id;
        }
        break;
      case "visor":
        if (saveData.ownedVisorIds.contains(id) || id == "gold") {
          saveData.playerProfile.helmetVisorTint = id;
        }
        break;
      case "backpack":
        if (saveData.ownedBackpackIds.contains(id) || id == "plss_compact") {
          saveData.playerProfile.backpackType = id;
        }
        break;
      case "boots":
        if (saveData.ownedBootsIds.contains(id) || id == "lunar_tread") {
          saveData.playerProfile.bootsType = id;
        }
        break;
      case "colorway":
        if (saveData.ownedColorways.contains(id) || id == "white") {
          if (id == "white") saveData.playerProfile.primaryColorValue = 0xFFF0F4F8;
          if (id == "navy") saveData.playerProfile.primaryColorValue = 0xFF0D1B2A;
          if (id == "black") saveData.playerProfile.primaryColorValue = 0xFF1A1A1A;
          if (id == "orange") saveData.playerProfile.primaryColorValue = 0xFFFF6F00;
        }
        break;
      case "patch":
        if (saveData.ownedPatches.contains(id) || id == "spaceapps2026") {
          saveData.playerProfile.missionPatch = id;
        }
        break;
      case "livery":
        if (saveData.ownedLiveries.contains(id) || id == "apollo_white") {
          // liveries equipped to vehicle
        }
        break;
    }
    SaveManager.instance.save();
    notifyListeners();
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
  void setMissionPhase(MissionPhase phase) {
    currentPhase = phase;
    notifyListeners();
  }

  void setControlMode(ControlMode mode) {
    currentControlMode = mode;
    notifyListeners();
  }

  void setHatchState(bool open) {
    isHatchOpen = open;
    notifyListeners();
  }

  void setCrewOutside(bool outside) {
    isOutsideVehicle = outside;
    notifyListeners();
  }

  void startMission(MissionModel mission) {
    currentMission = mission;
    currentAttemptId = "att_${DateTime.now().millisecondsSinceEpoch}_${mission.id}";
    currentPhase = MissionPhase.briefing;
    currentControlMode = ControlMode.none;
    isSuccessValidated = false;
    validationFailureReason = null;
    apollo11SamplesCollectedCount = 0;

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
      completeObjective("apollo11_transfer");
      completeObjective("store_in_lander");
      completeObjective("secure_equipment");
      notifyListeners();
    }
  }

  // Central Authoritative Success Validator
  MissionValidationResult validateMissionSuccess([String? attemptId]) {
    final effectiveAttemptId = attemptId ?? currentAttemptId;

    if (currentMission == null) {
      return MissionValidationResult(
        isValid: false,
        failureReason: "NO ACTIVE MISSION IN PROGRESS",
        attemptId: effectiveAttemptId,
        completedObjectivesCount: 0,
        totalObjectivesCount: 0,
        objectiveStates: {},
        bagItemsCount: bag.items.length,
        vaultItemsCount: activeVehicleStorage.length,
        crewAboard: !isOutsideVehicle,
        spacecraftSecured: !isHatchOpen,
      );
    }

    if (effectiveAttemptId.isEmpty || effectiveAttemptId != currentAttemptId) {
      return MissionValidationResult(
        isValid: false,
        failureReason: "ATTEMPT MISMATCH: Expected $currentAttemptId but received $effectiveAttemptId",
        attemptId: effectiveAttemptId,
        completedObjectivesCount: activeObjectiveStates.values.where((v) => v).length,
        totalObjectivesCount: currentMission!.objectives.length,
        objectiveStates: Map.from(activeObjectiveStates),
        bagItemsCount: bag.items.length,
        vaultItemsCount: activeVehicleStorage.length,
        crewAboard: !isOutsideVehicle,
        spacecraftSecured: !isHatchOpen,
      );
    }

    final missingObjectives = <String>[];
    int completedCount = 0;
    for (final obj in currentMission!.objectives) {
      final isDone = activeObjectiveStates[obj.key] == true;
      if (isDone) {
        completedCount++;
      } else if (!obj.isOptional) {
        missingObjectives.add(obj.description);
      }
    }

    if (missingObjectives.isNotEmpty) {
      return MissionValidationResult(
        isValid: false,
        failureReason: "INCOMPLETE REQUIRED OBJECTIVES: ${missingObjectives.join(', ')}",
        attemptId: effectiveAttemptId,
        completedObjectivesCount: completedCount,
        totalObjectivesCount: currentMission!.objectives.length,
        objectiveStates: Map.from(activeObjectiveStates),
        bagItemsCount: bag.items.length,
        vaultItemsCount: activeVehicleStorage.length,
        crewAboard: !isOutsideVehicle,
        spacecraftSecured: !isHatchOpen,
      );
    }

    // Check sample bag is empty (samples transferred to vault)
    if (bag.items.isNotEmpty) {
      return MissionValidationResult(
        isValid: false,
        failureReason: "${bag.items.length} SAMPLES REMAIN IN BACKPACK! TRANSFER ALL TO LANDER VAULT",
        attemptId: effectiveAttemptId,
        completedObjectivesCount: completedCount,
        totalObjectivesCount: currentMission!.objectives.length,
        objectiveStates: Map.from(activeObjectiveStates),
        bagItemsCount: bag.items.length,
        vaultItemsCount: activeVehicleStorage.length,
        crewAboard: !isOutsideVehicle,
        spacecraftSecured: !isHatchOpen,
      );
    }

    // Check crew aboard if crewed mission (level 9 is uncrewed probe)
    final isCrewed = currentMission!.levelNumber != 9;
    if (isCrewed && isOutsideVehicle) {
      return MissionValidationResult(
        isValid: false,
        failureReason: "ASTRONAUT OUTSIDE SPACECRAFT! INGRESS CABIN BEFORE COMPLETION",
        attemptId: effectiveAttemptId,
        completedObjectivesCount: completedCount,
        totalObjectivesCount: currentMission!.objectives.length,
        objectiveStates: Map.from(activeObjectiveStates),
        bagItemsCount: bag.items.length,
        vaultItemsCount: activeVehicleStorage.length,
        crewAboard: !isOutsideVehicle,
        spacecraftSecured: !isHatchOpen,
      );
    }

    // Check hatch is sealed if crewed mission
    if (isCrewed && isHatchOpen) {
      return MissionValidationResult(
        isValid: false,
        failureReason: "AIRLOCK HATCH UNSEALED! SEAL HATCH FOR SAFE ASCENT/RETURN",
        attemptId: effectiveAttemptId,
        completedObjectivesCount: completedCount,
        totalObjectivesCount: currentMission!.objectives.length,
        objectiveStates: Map.from(activeObjectiveStates),
        bagItemsCount: bag.items.length,
        vaultItemsCount: activeVehicleStorage.length,
        crewAboard: !isOutsideVehicle,
        spacecraftSecured: !isHatchOpen,
      );
    }

    return MissionValidationResult(
      isValid: true,
      failureReason: "",
      attemptId: effectiveAttemptId,
      completedObjectivesCount: completedCount,
      totalObjectivesCount: currentMission!.objectives.length,
      objectiveStates: Map.from(activeObjectiveStates),
      bagItemsCount: bag.items.length,
      vaultItemsCount: activeVehicleStorage.length,
      crewAboard: !isOutsideVehicle,
      spacecraftSecured: !isHatchOpen,
    );
  }

  // Mission Results: Success with Mandatory Validation Guard
  Map<String, dynamic> completeMissionSuccess({
    String? attemptId,
    required int baseScore,
    required int timeSeconds,
  }) {
    final validation = validateMissionSuccess(attemptId);
    if (!validation.isValid) {
      validationFailureReason = validation.failureReason;
      isSuccessValidated = false;
      notifyListeners();
      return {
        'success': false,
        'reason': validation.failureReason,
        'isFirstClear': false,
        'coinsAwarded': 0,
        'xpAwarded': 0,
        'stars': 0,
        'unlockedNext': false,
        'campaignCompleted': false,
      };
    }

    isSuccessValidated = true;
    validationFailureReason = null;
    currentPhase = MissionPhase.success;

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
      'success': true,
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
    isHatchOpen = false;
    isOutsideVehicle = false;
    isRoverMounted = false;
    isSuccessValidated = false;
    validationFailureReason = null;
    apollo11SamplesCollectedCount = 0;
    bag.clear();
    activeVehicleStorage.clear();
    if (currentMission != null) {
      currentAttemptId = "att_${DateTime.now().millisecondsSinceEpoch}_${currentMission!.id}";
      currentPhase = MissionPhase.briefing;
      currentControlMode = ControlMode.none;
      for (final obj in currentMission!.objectives) {
        activeObjectiveStates[obj.key] = false;
      }
    }
    notifyListeners();
  }
}
