import 'dart:async';
import 'package:flutter/material.dart';
import '../models/astronaut_model.dart';
import '../models/inventory_model.dart';
import '../models/mission_model.dart';
import '../rendering/astronaut_renderer.dart';
import '../state/mission_state.dart';

class InteractableWorldEntity {
  final String id;
  final String name;
  final String category; // "sample", "instrument", "vehicle", "rover", "target"
  final Offset position;
  final double radius;
  final String promptText;
  final String iconKey;
  final InventoryItem? sampleItem;
  bool isInteractedWith;
  bool isCollected;

  InteractableWorldEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.position,
    this.radius = 45.0,
    required this.promptText,
    required this.iconKey,
    this.sampleItem,
    this.isInteractedWith = false,
    this.isCollected = false,
  });
}

class SurfaceExplorationController extends ChangeNotifier {
  final MissionModel mission;
  final AstronautProfile astronautProfile;

  // Spatial coordinates
  Offset playerWorldPos = const Offset(0, 0);
  Offset landerWorldPos = const Offset(-180, 0);
  Offset roverWorldPos = const Offset(-110, 0);
  Offset playerVelocity = Offset.zero;
  bool facingRight = true;
  AstronautAnimState animState = AstronautAnimState.idle;
  double animPhase = 0.0;
  bool isRunning = false;
  bool isJumping = false;
  double jumpVerticalOffset = 0.0;
  double jumpVelocity = 0.0;

  // Rover state
  bool isRoverDeployed = false;
  bool isRoverMounted = false;
  double roverBattery = 1.0;

  // Airlock state
  bool isLanderHatchOpen = true;
  bool isAstronautOutside = true;

  // Suit consumables
  double oxygenLevel = 1.0;
  double stamina = 1.0;
  double suitBattery = 1.0;

  // World interactable entities
  List<InteractableWorldEntity> worldEntities = [];
  InteractableWorldEntity? nearestEntity;
  double nearestDistance = 9999.0;

  Timer? _gameLoopTimer;
  VoidCallback? onOxygenDepleted;
  Function(String alert)? onMissionAlert;

  SurfaceExplorationController({
    required this.mission,
    required this.astronautProfile,
    this.onOxygenDepleted,
    this.onMissionAlert,
  }) {
    _populateWorldEntitiesForMission();
  }

  void _populateWorldEntitiesForMission() {
    worldEntities.clear();

    // 1. Lander / Spacecraft Airlock
    worldEntities.add(
      InteractableWorldEntity(
        id: "lander_airlock",
        name: "Lander Airlock & Storage Vault",
        category: "vehicle",
        position: landerWorldPos,
        radius: 65.0,
        promptText: "Open Hatch / Transfer Samples",
        iconKey: "rocket",
      ),
    );

    // 2. Rover if mission supports it
    if (mission.levelNumber == 4 || mission.levelNumber == 10) {
      isRoverDeployed = true;
      worldEntities.add(
        InteractableWorldEntity(
          id: "exploration_rover",
          name: "Lunar Roving Vehicle (LRV)",
          category: "rover",
          position: roverWorldPos,
          radius: 50.0,
          promptText: "Mount / Drive Rover",
          iconKey: "directions_car",
        ),
      );
    }

    // 3. Mission-specific geological samples & scientific targets
    final level = mission.levelNumber;
    if (level == 2) {
      // Apollo 11
      worldEntities.addAll([
        InteractableWorldEntity(
          id: "sample_basalt_10017",
          name: "Mare Basalt #10017",
          category: "sample",
          position: const Offset(80, -60),
          promptText: "Collect Basalt Rock",
          iconKey: "terrain",
          sampleItem: InventoryItem(
            id: "sample_basalt_10017",
            name: "Mare Basalt (Apollo 11 #10017)",
            category: "Geological Sample",
            massKg: 1.8,
            description: "Fine-grained vesicular basalt rich in ilmenite and pyroxene.",
            locationFound: "Sea of Tranquility",
            missionRelevance: "Early lunar volcanic crust crystallization proof.",
            iconKey: "landscape",
          ),
        ),
        InteractableWorldEntity(
          id: "sample_breccia_10021",
          name: "Impact Breccia #10021",
          category: "sample",
          position: const Offset(210, 40),
          promptText: "Collect Breccia Sample",
          iconKey: "terrain",
          sampleItem: InventoryItem(
            id: "sample_breccia_10021",
            name: "Lunar Breccia (Apollo 11 #10021)",
            category: "Geological Sample",
            massKg: 2.1,
            description: "Shock-lithified regolith breccia composed of fused glass beads.",
            locationFound: "Tranquility Base North Crater",
            missionRelevance: "Impact crater bombardment history evidence.",
            iconKey: "landscape",
          ),
        ),
        InteractableWorldEntity(
          id: "sample_regolith_10005",
          name: "Core Tube Regolith #10005",
          category: "sample",
          position: const Offset(140, 120),
          promptText: "Drive Core Tube & Sample Soil",
          iconKey: "science",
          sampleItem: InventoryItem(
            id: "sample_regolith_10005",
            name: "Regolith Core Sample #10005",
            category: "Geological Sample",
            massKg: 0.9,
            description: "Fine-grained lunar soil core preserving solar wind helium and argon.",
            locationFound: "Sub-surface Core Station",
            missionRelevance: "Solar wind implantation history record.",
            iconKey: "science",
          ),
        ),
      ]);
    } else if (level == 3) {
      // Apollo 12: Surveyor 3
      worldEntities.addAll([
        InteractableWorldEntity(
          id: "surveyor_probe_target",
          name: "Surveyor 3 Robotic Probe",
          category: "target",
          position: const Offset(260, -40),
          radius: 60.0,
          promptText: "Inspect & Recover TV Camera",
          iconKey: "camera_alt",
          sampleItem: InventoryItem(
            id: "surveyor_camera_hardware",
            name: "Surveyor 3 Optical TV Camera",
            category: "Recovered Component",
            massKg: 4.5,
            description: "Television camera exposed to 2.5 years of lunar vacuum and solar radiation.",
            locationFound: "Surveyor Crater Rim",
            missionRelevance: "NASA material durability study in hard vacuum.",
            iconKey: "precision_manufacturing",
          ),
        ),
        InteractableWorldEntity(
          id: "alsep_deployment_site",
          name: "ALSEP Deployment Zone",
          category: "instrument",
          position: const Offset(120, 80),
          radius: 50.0,
          promptText: "Deploy Passive Seismic Station",
          iconKey: "sensors",
        ),
      ]);
    } else if (level == 4) {
      // Apollo 15: Rover expedition
      worldEntities.addAll([
        InteractableWorldEntity(
          id: "hadley_waypoint_station2",
          name: "Station 2 (Mt. Hadley Delta)",
          category: "target",
          position: const Offset(320, -110),
          radius: 55.0,
          promptText: "Waypoint Reached: Search for Genesis Rock",
          iconKey: "flag",
        ),
        InteractableWorldEntity(
          id: "genesis_rock_15415",
          name: "Genesis Rock Anorthosite #15415",
          category: "sample",
          position: const Offset(360, -130),
          promptText: "Collect Genesis Rock Anorthosite",
          iconKey: "diamond",
          sampleItem: InventoryItem(
            id: "genesis_rock_15415",
            name: "Genesis Rock (Apollo 15 #15415)",
            category: "Geological Sample",
            massKg: 1.2,
            description: "4.1-billion-year-old ferroan anorthosite from early lunar magma ocean crust.",
            locationFound: "Hadley Delta Spur Crater",
            missionRelevance: "Critical proof of primordial lunar magma ocean theory.",
            iconKey: "diamond",
          ),
        ),
        InteractableWorldEntity(
          id: "hadley_rille_basalt",
          name: "Hadley Rille Vesicular Basalt",
          category: "sample",
          position: const Offset(480, 90),
          promptText: "Sample Volcanic Lava Flow Rock",
          iconKey: "terrain",
          sampleItem: InventoryItem(
            id: "hadley_rille_basalt",
            name: "Hadley Rille Porphyritic Basalt",
            category: "Geological Sample",
            massKg: 2.4,
            description: "Vesicular basalt formed in ancient sinuous rille lava channel.",
            locationFound: "Hadley Rille Rim",
            missionRelevance: "Lunar vulcanism and channel collapse dynamics.",
            iconKey: "landscape",
          ),
        ),
      ]);
    } else if (level == 5) {
      // Apollo 17: Orange Soil
      worldEntities.addAll([
        InteractableWorldEntity(
          id: "orange_soil_74220",
          name: "Orange Volcanic Glass Soil #74220",
          category: "sample",
          position: const Offset(280, 60),
          promptText: "Trench & Sample Orange Soil",
          iconKey: "colorize",
          sampleItem: InventoryItem(
            id: "orange_soil_74220",
            name: "Shorty Crater Orange Glass Soil (#74220)",
            category: "Geological Sample",
            massKg: 1.5,
            description: "Titanium-rich orange glass beads formed in ancient pyroclastic fire fountaining.",
            locationFound: "Shorty Crater Rim",
            missionRelevance: "Discovery of lunar volatile degassing and deep mantle vulcanism.",
            iconKey: "colorize",
          ),
        ),
        InteractableWorldEntity(
          id: "troctolite_76535",
          name: "Plutonic Troctolite Rock #76535",
          category: "sample",
          position: const Offset(390, -80),
          promptText: "Collect Ancient Troctolite",
          iconKey: "terrain",
          sampleItem: InventoryItem(
            id: "troctolite_76535",
            name: "Coarse-Grained Troctolite (#76535)",
            category: "Geological Sample",
            massKg: 2.0,
            description: "Unshocked deep plutonic olivine-plagioclase rock dated at 4.25 Ga.",
            locationFound: "North Massif Base",
            missionRelevance: "Oldest unshocked lunar deep-crustal sample in NASA collection.",
            iconKey: "terrain",
          ),
        ),
        InteractableWorldEntity(
          id: "seismic_geophone_array",
          name: "Explosive Seismic Geophone Array",
          category: "instrument",
          position: const Offset(160, -120),
          promptText: "Arm & Plant Geophone Sensors",
          iconKey: "sensors",
        ),
      ]);
    } else if (level == 7) {
      // STS-61: Hubble Servicing
      worldEntities.addAll([
        InteractableWorldEntity(
          id: "hst_wfpc2_box",
          name: "Hubble WFPC2 Instrument Bay",
          category: "instrument",
          position: const Offset(120, -10),
          radius: 65.0,
          promptText: "Replace WFPC2 Optics Box",
          iconKey: "build",
        ),
      ]);
    } else if (level == 8) {
      // STS-88: ISS Unity & Zarya
      worldEntities.addAll([
        InteractableWorldEntity(
          id: "iss_umbilical_truss",
          name: "Unity-Zarya Umbilical Junction",
          category: "instrument",
          position: const Offset(140, 0),
          radius: 65.0,
          promptText: "Connect High-Voltage Umbilicals",
          iconKey: "cable",
        ),
      ]);
    } else if (level == 10) {
      // Mars Jezero Delta
      worldEntities.addAll([
        InteractableWorldEntity(
          id: "mars_mudstone_tube1",
          name: "Delta Clay Mudstone (Tube #01)",
          category: "sample",
          position: const Offset(240, -90),
          promptText: "Drill & Seal Delta Clay Core",
          iconKey: "science",
          sampleItem: InventoryItem(
            id: "mars_mudstone_tube1",
            name: "Jezero Delta Mudstone Core (Tube #01)",
            category: "Geological Sample",
            massKg: 1.1,
            description: "Fine-grained phyllosilicate clay with high biosignature preservation potential.",
            locationFound: "Jezero Ancient River Delta",
            missionRelevance: "Search for ancient microbial biosignatures on Mars.",
            iconKey: "science",
          ),
        ),
        InteractableWorldEntity(
          id: "mars_igneous_tube2",
          name: "Crater Floor Olivine Igneous (Tube #02)",
          category: "sample",
          position: const Offset(380, 50),
          promptText: "Drill & Seal Igneous Floor Core",
          iconKey: "terrain",
          sampleItem: InventoryItem(
            id: "mars_igneous_tube2",
            name: "Crater Floor Olivine Core (Tube #02)",
            category: "Geological Sample",
            massKg: 1.3,
            description: "Cumulate igneous rock rich in olivine formed by lava pond crystallization.",
            locationFound: "Séítah Geological Unit",
            missionRelevance: "Geochronological radiometric age calibration of Mars.",
            iconKey: "terrain",
          ),
        ),
        InteractableWorldEntity(
          id: "mars_carbonate_tube3",
          name: "Lacustrine Carbonate (Tube #03)",
          category: "sample",
          position: const Offset(520, -40),
          promptText: "Drill & Seal Carbonate Core",
          iconKey: "diamond",
          sampleItem: InventoryItem(
            id: "mars_carbonate_tube3",
            name: "Lacustrine Carbonate Core (Tube #03)",
            category: "Geological Sample",
            massKg: 1.0,
            description: "Precipitated carbonate minerals recording ancient neutral pH lake water.",
            locationFound: "Marginal Carbonate Band",
            missionRelevance: "Ancient Martian lake water chemistry records.",
            iconKey: "diamond",
          ),
        ),
        InteractableWorldEntity(
          id: "mars_sample_cache_depot",
          name: "Sample Cache Depot Drop Zone",
          category: "target",
          position: const Offset(620, 20),
          radius: 60.0,
          promptText: "Deposit Sealed Sample Tubes in Cache",
          iconKey: "inventory_2",
        ),
      ]);
    }
  }

  void startExploration() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      _tick(0.033);
    });
  }

  void stopExploration() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = null;
  }

  void setMovementVector(Offset dir, {bool running = false}) {
    isRunning = running;
    if (dir == Offset.zero) {
      playerVelocity = Offset.zero;
      animState = isJumping ? AstronautAnimState.jump : AstronautAnimState.idle;
    } else {
      final speedMultiplier = isRoverMounted ? 2.8 : (isRunning ? 1.7 : 1.0);
      final baseSpeed = 4.5 * speedMultiplier;
      playerVelocity = dir * baseSpeed;
      if (dir.dx > 0) facingRight = true;
      if (dir.dx < 0) facingRight = false;
      animState = isJumping
          ? AstronautAnimState.jump
          : (isRunning ? AstronautAnimState.run : AstronautAnimState.walk);
    }
    notifyListeners();
  }

  void triggerJump() {
    if (isRoverMounted) return; // cannot jump inside rover
    if (!isJumping) {
      isJumping = true;
      // Celestial gravity scale: on Moon, jumps are floaty and higher!
      final g = mission.planetaryData.surfaceGravity;
      jumpVelocity = g < 2.0 ? 8.5 : (g < 4.0 ? 6.0 : 4.5);
      animState = AstronautAnimState.jump;
      notifyListeners();
    }
  }

  void _tick(double dt) {
    // 1. Move player/rover
    if (playerVelocity != Offset.zero) {
      playerWorldPos += playerVelocity;
      // Bound checking inside 2000m exploration zone
      playerWorldPos = Offset(
        playerWorldPos.dx.clamp(-400.0, 1600.0),
        playerWorldPos.dy.clamp(-600.0, 600.0),
      );
      animPhase = (animPhase + (isRunning ? 0.08 : 0.05)) % 1.0;

      // Exertion oxygen consumption
      final drainRate = isRunning ? 0.0018 : 0.0008;
      oxygenLevel = (oxygenLevel - (drainRate * dt)).clamp(0.0, 1.0);

      if (isRunning) {
        stamina = (stamina - 0.08 * dt).clamp(0.0, 1.0);
        if (stamina <= 0.05) isRunning = false;
      } else {
        stamina = (stamina + 0.12 * dt).clamp(0.0, 1.0);
      }

      if (isRoverMounted) {
        roverWorldPos = playerWorldPos;
        roverBattery = (roverBattery - 0.0015 * dt).clamp(0.0, 1.0);
      }
    } else {
      animPhase = (animPhase + 0.02) % 1.0;
      stamina = (stamina + 0.2 * dt).clamp(0.0, 1.0);
    }

    // 2. Jump physics
    if (isJumping) {
      final g = mission.planetaryData.surfaceGravity;
      jumpVerticalOffset += jumpVelocity * dt * 25.0;
      jumpVelocity -= (g * 1.5 * dt);
      if (jumpVerticalOffset <= 0.0) {
        jumpVerticalOffset = 0.0;
        isJumping = false;
        animState = playerVelocity == Offset.zero
            ? AstronautAnimState.idle
            : (isRunning ? AstronautAnimState.run : AstronautAnimState.walk);
      }
    }

    // 3. Proximity detection to nearest interactable entity
    nearestEntity = null;
    nearestDistance = 9999.0;
    for (final entity in worldEntities) {
      if (entity.isCollected) continue;
      final dist = (playerWorldPos - entity.position).distance;
      if (dist < nearestDistance) {
        nearestDistance = dist;
        if (dist <= entity.radius) {
          nearestEntity = entity;
        }
      }
    }

    // 4. Oxygen warnings
    if (oxygenLevel < 0.20 && oxygenLevel > 0.18) {
      onMissionAlert?.call("WARNING: OXYGEN RESERVE AT 20% • RETURN TO VEHICLE");
    } else if (oxygenLevel <= 0.0) {
      stopExploration();
      onOxygenDepleted?.call();
    }

    notifyListeners();
  }

  // Primary Interaction Handler (Triggered by 'E' key or on-screen Interact button)
  bool interactWithNearest() {
    if (nearestEntity == null) return false;

    final entity = nearestEntity!;
    animState = AstronautAnimState.interact;

    if (entity.category == "vehicle") {
      // Transfer samples to lander
      MissionState.instance.transferSamplesToVehicleStorage();
      onMissionAlert?.call("ALL COLLECTED SAMPLES SECURED IN LANDER VAULT.");
      notifyListeners();
      return true;
    } else if (entity.category == "rover") {
      // Mount / Dismount rover
      isRoverMounted = !isRoverMounted;
      onMissionAlert?.call(isRoverMounted
          ? "MOUNTED LUNAR ROVING VEHICLE (LRV) • HIGH-SPEED MOBILITY ACTIVE"
          : "DISMOUNTED ROVER • ASTRONAUT ON FOOT");
      MissionState.instance.completeObjective("deploy_lrv");
      notifyListeners();
      return true;
    } else if (entity.category == "instrument") {
      entity.isInteractedWith = true;
      if (entity.id == "alsep_deployment_site") {
        MissionState.instance.completeObjective("deploy_alsep");
        onMissionAlert?.call("ALSEP SEISMIC EXPERIMENT DEPLOYED AND OPERATIONAL.");
      } else if (entity.id == "seismic_geophone_array") {
        MissionState.instance.completeObjective("deploy_seismic_geophone");
        onMissionAlert?.call("EXPLOSIVE SEISMIC GEOPHONE ARRAY ARMED.");
      } else if (entity.id == "hst_wfpc2_box") {
        MissionState.instance.completeObjective("replace_wfpc2");
        onMissionAlert?.call("WFPC2 OPTICS MODULE SECURED • TELEMETRY VERIFIED.");
      } else if (entity.id == "iss_umbilical_truss") {
        MissionState.instance.completeObjective("connect_umbilicals");
        MissionState.instance.completeObjective("station_power_on");
        onMissionAlert?.call("UNITY-ZARYA POWER UMBILICALS SECURED • STATION POWER ON.");
      }
      notifyListeners();
      return true;
    } else if (entity.id == "mars_sample_cache_depot") {
      MissionState.instance.completeObjective("cache_samples_depot");
      onMissionAlert?.call("MARS CACHE DEPOT DEPOSITED • READY FOR NASA SAMPLE RETURN RETRIEVAL.");
      notifyListeners();
      return true;
    } else if (entity.id == "hadley_waypoint_station2") {
      MissionState.instance.completeObjective("drive_waypoint1");
      onMissionAlert?.call("STATION 2 REACHED • SEARCH FOR ANCIENT MAGMA OCEAN CRUST.");
      notifyListeners();
      return true;
    }

    return false;
  }

  // Sample Pick-up Handler (Triggered by 'F' key or on-screen Pick Up button)
  bool collectNearestSample() {
    if (nearestEntity == null || nearestEntity!.sampleItem == null) return false;

    final entity = nearestEntity!;
    final item = entity.sampleItem!;

    // Play collection animation
    animState = AstronautAnimState.collect;

    final added = MissionState.instance.pickupWorldItem(item);
    if (added) {
      entity.isCollected = true;
      onMissionAlert?.call("COLLECTED: ${item.name} (${item.massKg} kg)");

      // Mark objective progress
      if (entity.id == "sample_basalt_10017") {
        MissionState.instance.completeObjective("collect_basalt");
      } else if (entity.id == "sample_breccia_10021") {
        MissionState.instance.completeObjective("collect_breccia");
      } else if (entity.id == "sample_regolith_10005") {
        MissionState.instance.completeObjective("collect_regolith");
      } else if (entity.id == "surveyor_probe_target") {
        MissionState.instance.completeObjective("recover_camera");
      } else if (entity.id == "genesis_rock_15415") {
        MissionState.instance.completeObjective("collect_genesis_rock");
      } else if (entity.id == "hadley_rille_basalt") {
        MissionState.instance.completeObjective("collect_rille_basalt");
      } else if (entity.id == "orange_soil_74220") {
        MissionState.instance.completeObjective("find_orange_soil");
      } else if (entity.id == "troctolite_76535") {
        MissionState.instance.completeObjective("sample_troctolite");
      } else if (entity.id == "mars_mudstone_tube1") {
        MissionState.instance.completeObjective("core_clay_sample");
      } else if (entity.id == "mars_igneous_tube2") {
        MissionState.instance.completeObjective("core_igneous_sample");
      } else if (entity.id == "mars_carbonate_tube3") {
        MissionState.instance.completeObjective("core_carbonate_sample");
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    stopExploration();
    super.dispose();
  }
}
