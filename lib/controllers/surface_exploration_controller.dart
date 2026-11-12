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
  final String category; // "sample", "instrument", "vehicle", "rover", "target", "console"
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
    this.radius = 48.0,
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

  // Spatial coordinates & movement
  Offset playerWorldPos = const Offset(-140, 45); // Beside lander ladder
  Offset landerWorldPos = const Offset(-180, 40);
  Offset roverWorldPos = const Offset(-105, 45);
  Offset playerVelocity = Offset.zero;
  Offset rawInputVector = Offset.zero;
  Offset normalizedMovementVector = Offset.zero;
  bool facingRight = true;
  AstronautAnimState animState = AstronautAnimState.idle;
  double animPhase = 0.0;
  bool isRunning = false;
  bool isJumping = false;
  double jumpVerticalOffset = 0.0;
  double jumpVelocity = 0.0;

  bool get isGrounded => jumpVerticalOffset <= 0.001;
  MissionPhase get missionPhase => MissionState.instance.currentPhase;
  ControlMode get controlMode => MissionState.instance.currentControlMode;

  // Rover state
  bool isRoverDeployed = false;
  bool isRoverMounted = false;
  double roverBattery = 1.0;

  // Airlock & vehicle state
  bool isLanderHatchOpen = false; // Starts sealed after landing
  bool isAstronautOutside = false; // Astronaut starts in cabin, egresses through hatch
  bool isLanderSecured = false;

  // Timed action states (collection / drilling / connecting)
  bool isBusyCollecting = false;
  double actionProgress = 0.0;
  String currentActionName = "";

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
    final level = mission.levelNumber;

    // 1. Vehicle Airlock Hatch & Vault (for crewed missions)
    if (level != 9) {
      worldEntities.add(
        InteractableWorldEntity(
          id: "lander_airlock",
          name: level >= 6 && level <= 8 ? "Shuttle Airlock & Payload Bay" : "Lander Hatch & Storage Vault",
          category: "vehicle",
          position: landerWorldPos,
          radius: 70.0,
          promptText: "Interact with Hatch / Sample Vault",
          iconKey: "rocket",
        ),
      );
    }

    // 2. Rover (Apollo 15 & Mars Level 10)
    if (level == 4 || level == 10) {
      isRoverDeployed = true;
      worldEntities.add(
        InteractableWorldEntity(
          id: "exploration_rover",
          name: level == 4 ? "Lunar Roving Vehicle (LRV)" : "Martian Pressurized Delta Rover",
          category: "rover",
          position: roverWorldPos,
          radius: 55.0,
          promptText: "Mount / Dismount Rover",
          iconKey: "directions_car",
        ),
      );
    }

    // 3. Level-specific entities
    switch (level) {
      case 1:
        // Apollo 8: Translunar orbital flight & Earthrise observation
        worldEntities.addAll([
          InteractableWorldEntity(
            id: "lunar_insertion_node",
            name: "Lunar Orbit Insertion (LOI) Burn Vector",
            category: "instrument",
            position: const Offset(120, -40),
            radius: 80.0,
            promptText: "Execute LOI SPS Thruster Burn",
            iconKey: "speed",
          ),
          InteractableWorldEntity(
            id: "earthrise_photo_station",
            name: "Earthrise Telemetry Optical Cam",
            category: "target",
            position: const Offset(320, 60),
            radius: 80.0,
            promptText: "Capture Historic Earthrise Photo",
            iconKey: "camera_alt",
          ),
          InteractableWorldEntity(
            id: "trans_earth_burn_node",
            name: "Trans-Earth Injection (TEI) Return Vector",
            category: "instrument",
            position: const Offset(520, -20),
            radius: 80.0,
            promptText: "Execute Trans-Earth Return Burn",
            iconKey: "flight_takeoff",
          ),
        ]);
        break;

      case 2:
        // Apollo 11: First Lunar Steps
        worldEntities.addAll([
          InteractableWorldEntity(
            id: "apollo11_psep_site",
            name: "PSEP Seismic Deployment Station",
            category: "instrument",
            position: const Offset(90, 80),
            radius: 65.0,
            promptText: "Deploy Early Apollo Surface Experiments Package (PSEP)",
            iconKey: "sensors",
          ),
          InteractableWorldEntity(
            id: "sample_basalt_10017",
            name: "Mare Basalt #10017",
            category: "sample",
            position: const Offset(70, 35),
            promptText: "Collect Mare Basalt Rock",
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
            position: const Offset(190, 75),
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
            position: const Offset(130, 110),
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
        break;

      case 3:
        // Apollo 12: Precision landing & Surveyor 3
        worldEntities.addAll([
          InteractableWorldEntity(
            id: "surveyor_probe_target",
            name: "Surveyor 3 Robotic Probe",
            category: "target",
            position: const Offset(230, -30),
            radius: 65.0,
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
            name: "ALSEP Nuclear Seismic Station",
            category: "instrument",
            position: const Offset(110, 70),
            radius: 55.0,
            promptText: "Deploy ALSEP Passive Seismic Experiment",
            iconKey: "sensors",
          ),
        ]);
        break;

      case 4:
        // Apollo 15: Lunar Rover Expedition
        worldEntities.addAll([
          InteractableWorldEntity(
            id: "hadley_waypoint_station2",
            name: "Station 2 (Mt. Hadley Delta)",
            category: "target",
            position: const Offset(310, -90),
            radius: 60.0,
            promptText: "Waypoint Reached: Search for Genesis Rock",
            iconKey: "flag",
          ),
          InteractableWorldEntity(
            id: "genesis_rock_15415",
            name: "Genesis Rock Anorthosite #15415",
            category: "sample",
            position: const Offset(350, -115),
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
            id: "hadley_rille_rim",
            name: "Hadley Rille Gorge Rim Waypoint",
            category: "target",
            position: const Offset(490, 80),
            radius: 60.0,
            promptText: "Inspect 300m Hadley Rille Canyon",
            iconKey: "terrain",
          ),
          InteractableWorldEntity(
            id: "hadley_rille_basalt",
            name: "Hadley Rille Porphyritic Basalt",
            category: "sample",
            position: const Offset(520, 100),
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
        break;

      case 5:
        // Apollo 17: Field Scientist
        worldEntities.addAll([
          InteractableWorldEntity(
            id: "taurus_route_survey",
            name: "South Massif Landslide Route",
            category: "target",
            position: const Offset(140, -100),
            radius: 60.0,
            promptText: "Survey Valley Route & Photograph Landslide",
            iconKey: "photo_camera",
          ),
          InteractableWorldEntity(
            id: "orange_soil_74220",
            name: "Orange Volcanic Glass Soil #74220",
            category: "sample",
            position: const Offset(270, 50),
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
            position: const Offset(380, -70),
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
            position: const Offset(170, -110),
            radius: 50.0,
            promptText: "Arm & Plant Seismic Geophones",
            iconKey: "sensors",
          ),
        ]);
        break;

      case 6:
        // STS-31: Hubble Deployment
        worldEntities.addAll([
          InteractableWorldEntity(
            id: "hst_grapple_fixture",
            name: "Hubble Space Telescope (HST)",
            category: "instrument",
            position: const Offset(120, -15),
            radius: 70.0,
            promptText: "Activate RMS Robot Arm & Unlatch Hubble",
            iconKey: "precision_manufacturing",
          ),
          InteractableWorldEntity(
            id: "hst_solar_wing_telemetry",
            name: "HST Solar Array Telemetry Check",
            category: "target",
            position: const Offset(280, 20),
            radius: 70.0,
            promptText: "Verify Dual Solar Array Deployment",
            iconKey: "solar_power",
          ),
          InteractableWorldEntity(
            id: "separation_burn_station",
            name: "Orbital Separation Vector (120m)",
            category: "instrument",
            position: const Offset(420, -30),
            radius: 70.0,
            promptText: "Perform Gentle RCS Separation Burn",
            iconKey: "flight_takeoff",
          ),
        ]);
        break;

      case 7:
        // STS-61: Hubble Servicing
        worldEntities.addAll([
          InteractableWorldEntity(
            id: "hst_servicing_berth",
            name: "Hubble Servicing Flight Berth",
            category: "instrument",
            position: const Offset(80, -10),
            radius: 65.0,
            promptText: "Secure Telescope in Payload Berth",
            iconKey: "lock",
          ),
          InteractableWorldEntity(
            id: "hst_wfpc2_box",
            name: "WFPC2 Camera Optics Instrument Bay",
            category: "instrument",
            position: const Offset(160, 25),
            radius: 60.0,
            promptText: "Install WFPC2 Corrective Optics Box",
            iconKey: "build",
          ),
          InteractableWorldEntity(
            id: "goddard_telemetry_check",
            name: "Goddard Optical Telemetry Alignment",
            category: "target",
            position: const Offset(280, -20),
            radius: 65.0,
            promptText: "Verify Optical Alignment with Goddard",
            iconKey: "check_circle",
          ),
        ]);
        break;

      case 8:
        // STS-88: Space Station Assembly (Unity-Zarya)
        worldEntities.addAll([
          InteractableWorldEntity(
            id: "zarya_docking_target",
            name: "Zarya FGB Module APDS Docking Ring",
            category: "instrument",
            position: const Offset(100, 0),
            radius: 65.0,
            promptText: "Align Docking Ring & Complete Hard Latch",
            iconKey: "sensor_occupied",
          ),
          InteractableWorldEntity(
            id: "iss_umbilical_truss",
            name: "Unity-Zarya Umbilical Junction",
            category: "instrument",
            position: const Offset(180, 30),
            radius: 60.0,
            promptText: "Connect 4 High-Voltage Umbilical Cables",
            iconKey: "cable",
          ),
          InteractableWorldEntity(
            id: "unity_power_bus",
            name: "Unity Node 1 Station Electrical Bus",
            category: "target",
            position: const Offset(270, -25),
            radius: 60.0,
            promptText: "Verify Station Bus Electrical Telemetry",
            iconKey: "bolt",
          ),
        ]);
        break;

      case 9:
        // OSIRIS-REx: Bennu Sample Operation (Uncrewed console)
        worldEntities.addAll([
          InteractableWorldEntity(
            id: "nightingale_crater_site",
            name: "Nightingale Crater Sampling Zone",
            category: "target",
            position: const Offset(140, 20),
            radius: 70.0,
            promptText: "Descend Touch-and-Go Arm into Crater",
            iconKey: "track_changes",
          ),
          InteractableWorldEntity(
            id: "tagsam_nitrogen_burst",
            name: "TAGSAM Nitrogen Gas Contact Canister",
            category: "instrument",
            position: const Offset(240, -15),
            radius: 65.0,
            promptText: "Fire 5-Second Nitrogen Gas Burst",
            iconKey: "air",
          ),
          InteractableWorldEntity(
            id: "bennu_carbon_sample",
            name: "Pristine Carbonaceous Regolith (> 60g)",
            category: "sample",
            position: const Offset(250, 0),
            radius: 65.0,
            promptText: "Collect Carbonaceous Asteroid Regolith",
            iconKey: "diamond",
            sampleItem: InventoryItem(
              id: "bennu_carbon_sample",
              name: "Pristine Bennu Carbonaceous Regolith",
              category: "Extraterrestrial Sample",
              massKg: 0.25,
              description: "Pristine organic-rich carbonaceous chondrite regolith containing ancient amino acids and water-bearing clay minerals.",
              locationFound: "Nightingale Crater (Bennu)",
              missionRelevance: "Early solar system prebiotic building blocks.",
              iconKey: "diamond",
            ),
          ),
          InteractableWorldEntity(
            id: "src_capsule_stow",
            name: "Sample Return Capsule (SRC) Vault",
            category: "instrument",
            position: const Offset(360, 25),
            radius: 65.0,
            promptText: "Stow TAGSAM Head in Sample Return Capsule",
            iconKey: "lock",
          ),
          InteractableWorldEntity(
            id: "earth_return_burn_node",
            name: "Earth Return Trajectory Main Thruster",
            category: "instrument",
            position: const Offset(480, -20),
            radius: 70.0,
            promptText: "Ignite Engine for Earth Return Trajectory",
            iconKey: "flight_takeoff",
          ),
        ]);
        break;

      case 10:
        // Perseverance: Mars Expedition (Jezero Delta)
        worldEntities.addAll([
          InteractableWorldEntity(
            id: "mars_mudstone_tube1",
            name: "Delta Clay Mudstone (Tube #01)",
            category: "sample",
            position: const Offset(230, -80),
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
            position: const Offset(360, 45),
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
            position: const Offset(490, -40),
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
            position: const Offset(610, 20),
            radius: 65.0,
            promptText: "Deposit Sealed Sample Tubes in Cache",
            iconKey: "inventory_2",
          ),
          InteractableWorldEntity(
            id: "mars_final_report_station",
            name: "Lander High-Gain Comms Terminal",
            category: "instrument",
            position: const Offset(15, -45),
            radius: 60.0,
            promptText: "Transmit NASA Exploration Synthesis Report",
            iconKey: "cell_tower",
          ),
        ]);
        break;
    }
  }

  void startExploration() {
    MissionState.instance.setMissionPhase(MissionPhase.surfaceActivity);
    MissionState.instance.setControlMode(
      isRoverMounted
          ? ControlMode.rover
          : (isAstronautOutside ? ControlMode.astronaut : ControlMode.spacecraft),
    );
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
    rawInputVector = dir;
    if (isBusyCollecting) return; // Locked in collection animation
    isRunning = running;
    if (dir == Offset.zero) {
      normalizedMovementVector = Offset.zero;
      playerVelocity = Offset.zero;
      animState = isJumping ? AstronautAnimState.jump : AstronautAnimState.idle;
    } else {
      final len = dir.distance;
      final normDir = len > 0 ? Offset(dir.dx / len, dir.dy / len) : Offset.zero;
      normalizedMovementVector = normDir;

      final speedMultiplier = isRoverMounted ? 2.8 : (isRunning ? 1.7 : 1.0);
      final baseSpeed = 4.5 * speedMultiplier;
      playerVelocity = normDir * baseSpeed;
      if (normDir.dx > 0) facingRight = true;
      if (normDir.dx < 0) facingRight = false;
      animState = isJumping
          ? AstronautAnimState.jump
          : (isRunning ? AstronautAnimState.run : AstronautAnimState.walk);
    }
    notifyListeners();
  }

  void triggerJump() {
    if (isRoverMounted || isBusyCollecting || !isGrounded) return;
    isJumping = true;
    final g = mission.planetaryData.surfaceGravity;
    jumpVelocity = g < 2.0 ? 8.5 : (g < 4.0 ? 6.0 : 4.5);
    animState = AstronautAnimState.jump;
    notifyListeners();
  }

  void _tick(double dt) {
    // 1. Action timer for collection / drilling animation
    if (isBusyCollecting) {
      actionProgress += dt / 1.2;
      if (actionProgress >= 1.0) {
        _finishCollectionAction();
      }
      notifyListeners();
      return;
    }

    // 2. Spatial movement & collision
    if (playerVelocity != Offset.zero) {
      Offset nextPos = playerWorldPos + playerVelocity;
      final isSurfaceMission = mission.gameplayMode == MissionGameplayMode.surfaceExploration ||
          mission.gameplayMode == MissionGameplayMode.roverExpedition;
      final double minY = isSurfaceMission ? 12.0 : -300.0;
      final double maxY = isSurfaceMission ? 240.0 : 300.0;

      nextPos = Offset(
        nextPos.dx.clamp(-350.0, 1500.0),
        nextPos.dy.clamp(minY, maxY),
      );

      // Collision with lander body when walking on foot
      if (isSurfaceMission && isAstronautOutside && !isRoverMounted) {
        final landerBounds = Rect.fromCenter(center: landerWorldPos, width: 85.0, height: 65.0);
        if (landerBounds.contains(nextPos)) {
          final testX = Offset(nextPos.dx, playerWorldPos.dy);
          final testY = Offset(playerWorldPos.dx, nextPos.dy);
          if (!landerBounds.contains(testX)) {
            nextPos = testX;
          } else if (!landerBounds.contains(testY)) {
            nextPos = testY;
          } else {
            nextPos = playerWorldPos; // completely blocked
          }
        }
      }

      playerWorldPos = nextPos;
      animPhase = (animPhase + (isRunning ? 0.08 : 0.05)) % 1.0;

      // Oxygen exertion consumption
      final drainRate = isRunning ? 0.0016 : 0.0007;
      oxygenLevel = (oxygenLevel - (drainRate * dt)).clamp(0.0, 1.0);

      if (isRunning) {
        stamina = (stamina - 0.08 * dt).clamp(0.0, 1.0);
        if (stamina <= 0.05) isRunning = false;
      } else {
        stamina = (stamina + 0.12 * dt).clamp(0.0, 1.0);
      }

      if (isRoverMounted) {
        roverWorldPos = playerWorldPos;
        roverBattery = (roverBattery - 0.0012 * dt).clamp(0.0, 1.0);
      }
    } else {
      animPhase = (animPhase + 0.02) % 1.0;
      stamina = (stamina + 0.2 * dt).clamp(0.0, 1.0);
    }

    // 3. Jump physics
    if (isJumping) {
      final g = mission.planetaryData.surfaceGravity;
      jumpVerticalOffset += jumpVelocity * dt * 25.0;
      jumpVelocity -= (g * 1.5 * dt);
      if (jumpVerticalOffset <= 0.0) {
        jumpVerticalOffset = 0.0;
        jumpVelocity = 0.0;
        isJumping = false;
        animState = playerVelocity == Offset.zero
            ? AstronautAnimState.idle
            : (isRunning ? AstronautAnimState.run : AstronautAnimState.walk);
      }
    }

    // 4. Proximity detection to nearest interactable entity
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

    // 5. Oxygen alerts
    if (oxygenLevel < 0.20 && oxygenLevel > 0.18) {
      onMissionAlert?.call("WARNING: OXYGEN AT 20% • RETURN TO VEHICLE AIRLOCK");
    } else if (oxygenLevel <= 0.0) {
      stopExploration();
      onOxygenDepleted?.call();
    }

    notifyListeners();
  }

  // Handle Hatch Open / Egress / Ingress sequence
  void openVehicleHatch() {
    isLanderHatchOpen = true;
    MissionState.instance.setHatchState(true);
    onMissionAlert?.call("AIRLOCK EQUALIZED • VEHICLE HATCH OPENED");
    MissionState.instance.completeObjective("apollo11_hatch_exit");
    MissionState.instance.completeObjective("open_hatch_exit");
    MissionState.instance.completeObjective("airlock_depress_eva");
    MissionState.instance.completeObjective("open_payload_bay");
    notifyListeners();
  }

  void egressAstronaut() {
    isAstronautOutside = true;
    MissionState.instance.setCrewOutside(true);
    MissionState.instance.setControlMode(ControlMode.astronaut);
    playerWorldPos = Offset(landerWorldPos.dx + 48, landerWorldPos.dy + 15);
    onMissionAlert?.call("ASTRONAUT EGRESSED TO SURFACE BESIDE LADDER");
    MissionState.instance.completeObjective("apollo11_hatch_exit");
    MissionState.instance.completeObjective("open_hatch_exit");
    MissionState.instance.completeObjective("airlock_depress_eva");
    MissionState.instance.completeObjective("exit_assembly_eva");
    MissionState.instance.completeObjective("astronaut_egress_mars");
    notifyListeners();
  }

  void ingressAstronaut() {
    // Only permit ingress if required samples are secured
    if (MissionState.instance.bag.items.isNotEmpty) {
      onMissionAlert?.call("TRANSFER SAMPLES TO VAULT BEFORE INGRESS!");
      return;
    }
    isAstronautOutside = false;
    isLanderHatchOpen = false;
    MissionState.instance.setCrewOutside(false);
    MissionState.instance.setHatchState(false);
    MissionState.instance.setControlMode(ControlMode.spacecraft);
    playerWorldPos = landerWorldPos;
    onMissionAlert?.call("ASTRONAUT INSIDE CABIN • HATCH SEALED");
    MissionState.instance.completeObjective("apollo11_ingress");
    MissionState.instance.completeObjective("ingress_vehicle");
    MissionState.instance.completeObjective("reenter_airlock");
    MissionState.instance.completeObjective("safe_return");
    notifyListeners();
  }

  void executeAscentReturn() {
    if (isAstronautOutside) {
      onMissionAlert?.call("CREW MUST INGRESS BEFORE ASCENT RETURN!");
      return;
    }
    MissionState.instance.setMissionPhase(MissionPhase.returnPhase);
    MissionState.instance.completeObjective("apollo11_return");
    MissionState.instance.completeObjective("safe_return");
    MissionState.instance.completeObjective("return_burn");
    onMissionAlert?.call("ASCENT PROPULSION FIRED • LUNAR ORBIT RETURN CONFIRMED!");
    notifyListeners();
  }

  // Primary Interaction Handler ('E' key or on-screen Interact button)
  bool interactWithNearest() {
    if (nearestEntity == null) return false;

    final entity = nearestEntity!;
    animState = AstronautAnimState.interact;

    if (entity.category == "vehicle") {
      if (isAstronautOutside) {
        if (!isLanderHatchOpen) {
          openVehicleHatch();
        } else {
          // Transfer all samples in player bag to vehicle storage
          if (MissionState.instance.bag.items.isNotEmpty) {
            final count = MissionState.instance.bag.items.length;
            MissionState.instance.transferSamplesToVehicleStorage();
            onMissionAlert?.call("TRANSFERRED $count SAMPLES TO LANDER VAULT.");
            MissionState.instance.completeObjective("apollo11_transfer");
            MissionState.instance.completeObjective("store_in_lander");
            MissionState.instance.completeObjective("secure_equipment");
          } else {
            // If samples are already transferred, ingress
            ingressAstronaut();
          }
        }
      } else {
        // Astronaut inside cabin
        final allPrimaryDone = MissionState.instance.areAllPrimaryObjectivesCompleted;
        if (allPrimaryDone) {
          executeAscentReturn();
        } else {
          openVehicleHatch();
          egressAstronaut();
        }
      }
      notifyListeners();
      return true;
    } else if (entity.category == "rover") {
      isRoverMounted = !isRoverMounted;
      MissionState.instance.setControlMode(
        isRoverMounted ? ControlMode.rover : ControlMode.astronaut,
      );
      onMissionAlert?.call(isRoverMounted
          ? "MOUNTED EXPLORATION ROVER • HIGH-SPEED MOBILITY ACTIVE"
          : "DISMOUNTED ROVER • ASTRONAUT ON FOOT");
      MissionState.instance.completeObjective("deploy_lrv");
      notifyListeners();
      return true;
    } else if (entity.category == "instrument" || entity.category == "target") {
      entity.isInteractedWith = true;

      // Map verified objectives
      switch (entity.id) {
        case "apollo11_psep_site":
          MissionState.instance.completeObjective("apollo11_deploy_psep");
          onMissionAlert?.call("EARLY APOLLO PSEP SEISMIC PACKAGE DEPLOYED ON LUNAR REGOLITH.");
          break;
        case "lunar_insertion_node":
          MissionState.instance.completeObjective("lunar_injection");
          onMissionAlert?.call("LUNAR ORBIT INSERTION BURN COMPLETE.");
          break;
        case "earthrise_photo_station":
          MissionState.instance.completeObjective("earthrise_photo");
          onMissionAlert?.call("HISTORIC EARTHRISE PHOTOGRAPH CAPTURED!");
          break;
        case "trans_earth_burn_node":
          MissionState.instance.completeObjective("return_burn");
          onMissionAlert?.call("TRANS-EARTH RETURN TRAJECTORY CONFIRMED.");
          break;
        case "surveyor_probe_target":
          MissionState.instance.completeObjective("inspect_surveyor");
          onMissionAlert?.call("SURVEYOR 3 STRUCTURE INSPECTED & PHOTOGRAPHED.");
          break;
        case "alsep_deployment_site":
          MissionState.instance.completeObjective("deploy_alsep");
          onMissionAlert?.call("ALSEP NUCLEAR SEISMIC STATION DEPLOYED.");
          break;
        case "hadley_waypoint_station2":
          MissionState.instance.completeObjective("drive_waypoint1");
          onMissionAlert?.call("STATION 2 REACHED (MT. HADLEY DELTA).");
          break;
        case "hadley_rille_rim":
          MissionState.instance.completeObjective("drive_rille_edge");
          onMissionAlert?.call("HADLEY RILLE GORGE RIM WAYPOINT LOGGED.");
          break;
        case "taurus_route_survey":
          MissionState.instance.completeObjective("survey_route");
          onMissionAlert?.call("TAURUS-LITTROW VALLEY ROUTE SURVEY COMPLETE.");
          break;
        case "seismic_geophone_array":
          MissionState.instance.completeObjective("deploy_seismic_geophone");
          onMissionAlert?.call("EXPLOSIVE SEISMIC GEOPHONE ARRAY ARMED.");
          break;
        case "hst_grapple_fixture":
          MissionState.instance.completeObjective("grapple_unlatch");
          onMissionAlert?.call("REMOTE MANIPULATOR UNLATCHED HUBBLE TELESCOPE.");
          break;
        case "hst_solar_wing_telemetry":
          MissionState.instance.completeObjective("verify_arrays");
          onMissionAlert?.call("DUAL SOLAR ARRAY DEPLOYMENT VERIFIED.");
          break;
        case "separation_burn_station":
          MissionState.instance.completeObjective("separation_burn");
          onMissionAlert?.call("RCS SEPARATION BURN COMPLETE • 120M STAND-OFF.");
          break;
        case "hst_servicing_berth":
          MissionState.instance.completeObjective("rendezvous_berth");
          onMissionAlert?.call("HUBBLE SECURED IN PAYLOAD SERVICING BERTH.");
          break;
        case "hst_wfpc2_box":
          MissionState.instance.completeObjective("replace_wfpc2");
          onMissionAlert?.call("WFPC2 OPTICS MODULE INSTALLED.");
          break;
        case "goddard_telemetry_check":
          MissionState.instance.completeObjective("verify_telemetry");
          onMissionAlert?.call("GODDARD CONFIRMED OPTICAL ALIGNMENT.");
          break;
        case "zarya_docking_target":
          MissionState.instance.completeObjective("approach_zarya");
          MissionState.instance.completeObjective("docking_capture");
          onMissionAlert?.call("UNITY-ZARYA HARD DOCKING LATCH CONFIRMED!");
          break;
        case "iss_umbilical_truss":
          MissionState.instance.completeObjective("connect_umbilicals");
          onMissionAlert?.call("HIGH-VOLTAGE POWER UMBILICALS CONNECTED.");
          break;
        case "unity_power_bus":
          MissionState.instance.completeObjective("station_power_on");
          onMissionAlert?.call("STATION BUS ACTIVE • POWER TELEMETRY NOMINAL.");
          break;
        case "nightingale_crater_site":
          MissionState.instance.completeObjective("descent_nightingale");
          onMissionAlert?.call("TAGSAM ARM POSITIONED IN NIGHTINGALE CRATER.");
          break;
        case "tagsam_nitrogen_burst":
          MissionState.instance.completeObjective("fire_nitrogen_tag");
          onMissionAlert?.call("NITROGEN BURST FIRED • REGOLITH STIRRED!");
          break;
        case "src_capsule_stow":
          MissionState.instance.completeObjective("stow_src_capsule");
          onMissionAlert?.call("TAGSAM HEAD SECURED INSIDE RETURN CAPSULE.");
          break;
        case "earth_return_burn_node":
          MissionState.instance.completeObjective("earth_return_trajectory");
          onMissionAlert?.call("MAIN ENGINE FIRED FOR 2.5-YR EARTH RETURN.");
          break;
        case "mars_sample_cache_depot":
          MissionState.instance.completeObjective("cache_samples_depot");
          onMissionAlert?.call("SEALED SAMPLE TUBES DEPOSITED IN MARS DEPOT.");
          break;
        case "mars_final_report_station":
          MissionState.instance.completeObjective("transmit_final_report");
          onMissionAlert?.call("SYNTHESIS EXPLORATION REPORT TRANSMITTED TO NASA!");
          break;
      }
      notifyListeners();
      return true;
    }

    return false;
  }

  // Sample Pick-up Handler ('F' key or on-screen Collect button)
  bool startCollectionProcess() {
    if (nearestEntity == null || nearestEntity!.sampleItem == null) return false;
    if (isBusyCollecting) return false;

    final item = nearestEntity!.sampleItem!;
    // Enforce 15 kg bag capacity
    if (MissionState.instance.bag.currentMassKg + item.massKg > MissionState.instance.bag.maxCapacityKg) {
      onMissionAlert?.call("BAG FULL! (${MissionState.instance.bag.currentMassKg.toStringAsFixed(1)}/15.0 kg) • TRANSFER SAMPLES TO LANDER");
      return false;
    }

    isBusyCollecting = true;
    actionProgress = 0.0;
    currentActionName = "COLLECTING ${item.name.toUpperCase()}...";
    animState = AstronautAnimState.collect;
    notifyListeners();
    return true;
  }

  void _finishCollectionAction() {
    isBusyCollecting = false;
    actionProgress = 0.0;
    animState = AstronautAnimState.idle;

    if (nearestEntity != null && nearestEntity!.sampleItem != null) {
      final entity = nearestEntity!;
      final item = entity.sampleItem!;
      final added = MissionState.instance.pickupWorldItem(item);
      if (added) {
        entity.isCollected = true;
        onMissionAlert?.call("COLLECTED: ${item.name} (${item.massKg} kg)");

        // Objective checkmarks
        if (entity.id == "sample_basalt_10017") {
          MissionState.instance.completeObjective("collect_basalt");
        } else if (entity.id == "sample_breccia_10021") {
          MissionState.instance.completeObjective("collect_breccia");
        } else if (entity.id == "sample_regolith_10005") {
          MissionState.instance.completeObjective("collect_regolith");
        }

        // Apollo 11 3-sample progress tracking
        if (entity.id == "sample_basalt_10017" ||
            entity.id == "sample_breccia_10021" ||
            entity.id == "sample_regolith_10005") {
          MissionState.instance.apollo11SamplesCollectedCount++;
          final c = MissionState.instance.apollo11SamplesCollectedCount;
          onMissionAlert?.call("APOLLO 11 SAMPLE ACQUIRED ($c/3 DESIGNATED SAMPLES)");
          if (c >= 3) {
            MissionState.instance.completeObjective("apollo11_samples");
            onMissionAlert?.call("ALL 3 SAMPLES COLLECTED (4.8 KG) • RETURN TO LUNAR MODULE VAULT");
          }
        }

        if (entity.id == "surveyor_probe_target") {
          MissionState.instance.completeObjective("recover_camera");
        } else if (entity.id == "genesis_rock_15415") {
          MissionState.instance.completeObjective("collect_genesis_rock");
        } else if (entity.id == "hadley_rille_basalt") {
          MissionState.instance.completeObjective("collect_rille_basalt");
        } else if (entity.id == "orange_soil_74220") {
          MissionState.instance.completeObjective("find_orange_soil");
        } else if (entity.id == "troctolite_76535") {
          MissionState.instance.completeObjective("sample_troctolite");
        } else if (entity.id == "bennu_carbon_sample") {
          MissionState.instance.completeObjective("collect_bennu_sample");
        } else if (entity.id == "mars_mudstone_tube1") {
          MissionState.instance.completeObjective("core_clay_sample");
        } else if (entity.id == "mars_igneous_tube2") {
          MissionState.instance.completeObjective("core_igneous_sample");
        } else if (entity.id == "mars_carbonate_tube3") {
          MissionState.instance.completeObjective("core_carbonate_sample");
        }
      }
    }
    notifyListeners();
  }

  bool canCompleteMission() {
    return MissionState.instance.validateMissionSuccess().isValid;
  }

  @override
  void dispose() {
    stopExploration();
    super.dispose();
  }
}
