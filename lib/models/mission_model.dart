import 'planetary_data.dart';

enum MissionPhase {
  briefing,
  preparation,
  countdown,
  flight,
  landed,
  surfaceActivity,
  returnPhase,
  success,
  failure,
}

enum ControlMode {
  none,
  spacecraft,
  astronaut,
  rover,
  roboticProbe,
}

enum MissionGameplayMode {
  orbitalFlight, // Spacecraft flight & maneuvers (Level 1)
  surfaceExploration, // Astronaut on foot on surface (Level 2, 3, 5)
  roverExpedition, // Astronaut + Driveable Rover (Level 4, 10)
  orbitalDeployment, // Spacecraft payload release & separation (Level 6)
  zeroGravityEva, // Astronaut spacewalk with RCS & tether (Level 7, 8)
  roboticConsole, // Uncrewed robotic touch-and-go probe console (Level 9)
}

class MissionObjective {
  final String key;
  final String description;
  final bool isOptional;
  bool isCompleted;

  MissionObjective({
    required this.key,
    required this.description,
    this.isOptional = false,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'description': description,
        'isOptional': isOptional,
        'isCompleted': isCompleted,
      };

  factory MissionObjective.fromJson(Map<String, dynamic> json) => MissionObjective(
        key: json['key'] as String,
        description: json['description'] as String,
        isOptional: json['isOptional'] as bool? ?? false,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class MissionModel {
  final int levelNumber;
  final String id;
  final String title;
  final String codeName;
  final String destinationName;
  final PlanetaryData planetaryData;
  final String historicalInspiration;
  final String disclaimerNotice;
  final String briefingSummary;
  final int coinReward;
  final int xpReward;
  final MissionGameplayMode gameplayMode;
  final List<MissionObjective> objectives;
  final List<String> requiredEquipments;
  final List<String> nasaSourceKeys;
  final String environmentHazard;
  final String defaultVideoAsset;

  const MissionModel({
    required this.levelNumber,
    required this.id,
    required this.title,
    required this.codeName,
    required this.destinationName,
    required this.planetaryData,
    required this.historicalInspiration,
    this.disclaimerNotice = "",
    required this.briefingSummary,
    required this.coinReward,
    required this.xpReward,
    required this.gameplayMode,
    required this.objectives,
    required this.requiredEquipments,
    required this.nasaSourceKeys,
    required this.environmentHazard,
    required this.defaultVideoAsset,
  });

  static List<MissionModel> get allMissions => [
        // LEVEL 1: APOLLO 8
        MissionModel(
          levelNumber: 1,
          id: "m01_apollo8",
          title: "APOLLO 8: LUNAR ORBIT TRAINING",
          codeName: "TRANSLUNAR-01",
          destinationName: "Lunar Orbit (112 km altitude)",
          planetaryData: PlanetaryData.moon,
          historicalInspiration: "Apollo 8 (Dec 1968) — The first crewed spacecraft to leave low Earth orbit, reach the Moon, and witness the 'Earthrise'.",
          briefingSummary: "Launch from Earth, follow navigation trajectory waypoints, execute the lunar orbit insertion burn, capture an Earthrise observation photo, and guide the spacecraft on a return trajectory.",
          coinReward: 100,
          xpReward: 300,
          gameplayMode: MissionGameplayMode.orbitalFlight,
          objectives: [
            MissionObjective(key: "build_ready", description: "Validate spacecraft build with heat shield and parachutes"),
            MissionObjective(key: "reach_orbit", description: "Ascend past Earth atmosphere into stable low orbit"),
            MissionObjective(key: "lunar_injection", description: "Execute translunar injection burn along trajectory"),
            MissionObjective(key: "earthrise_photo", description: "Capture Earthrise observation through telemetry cam"),
            MissionObjective(key: "return_burn", description: "Perform Trans-Earth return alignment burn"),
          ],
          requiredEquipments: ["Apollo Command Module", "J-2 Vacuum Engine", "Heat Shield", "Parachutes"],
          nasaSourceKeys: ["Planetary Fact Sheet", "JPL Horizons", "NASA Images", "SPICE"],
          environmentHazard: "Van Allen Radiation Belts & Earth atmospheric re-entry thermal loads (2,760°C)",
          defaultVideoAsset: "assets/videos/astrovia_intro.mp4",
        ),

        // LEVEL 2: APOLLO 11
        MissionModel(
          levelNumber: 2,
          id: "m02_apollo11",
          title: "APOLLO 11: FIRST LUNAR STEPS",
          codeName: "TRANQUILITY-02",
          destinationName: "Moon — Sea of Tranquility (0.67° N, 23.47° E)",
          planetaryData: PlanetaryData.moon,
          historicalInspiration: "Apollo 11 (July 1969) — Humanity's first crewed lunar landing by Neil Armstrong and Buzz Aldrin.",
          briefingSummary: "Pilot the final lunar descent stage to a safe touchdown in Mare Tranquillitatis. Depressurize airlock, open hatch, step onto the regolith as your astronaut, collect 3 designated geological samples, deploy the PSEP seismic instrument, transfer all samples to the lander vault, re-enter cabin, and ignite ascent return.",
          coinReward: 150,
          xpReward: 450,
          gameplayMode: MissionGameplayMode.surfaceExploration,
          objectives: [
            MissionObjective(key: "apollo11_landing", description: "Safe touchdown in target zone (speed < 4 m/s, pitch < 15°)"),
            MissionObjective(key: "apollo11_hatch_exit", description: "Depressurize airlock, open hatch, and step onto surface"),
            MissionObjective(key: "apollo11_samples", description: "Collect 3 designated lunar samples (0/3)"),
            MissionObjective(key: "apollo11_deploy_psep", description: "Deploy Early Apollo Surface Experiments Package (PSEP)"),
            MissionObjective(key: "apollo11_transfer", description: "Transfer all collected samples to lander vault"),
            MissionObjective(key: "apollo11_ingress", description: "Re-enter lunar module cabin and seal airlock hatch"),
            MissionObjective(key: "apollo11_return", description: "Ignite ascent engine and confirm return trajectory"),
          ],
          requiredEquipments: ["Lunar Module", "EVA Suit", "Sample Bag", "Descent Landing Legs"],
          nasaSourceKeys: ["Planetary Fact Sheet", "PDS Geosciences", "LRO LOLA", "NASA 3D Resources"],
          environmentHazard: "Lunar hard vacuum, abrasive micro-meteorite regolith, extreme temperature swings (-130°C to +120°C)",
          defaultVideoAsset: "assets/videos/lunar_exploration.mp4",
        ),

        // LEVEL 3: APOLLO 12
        MissionModel(
          levelNumber: 3,
          id: "m03_apollo12",
          title: "APOLLO 12: PRECISION AND EQUIPMENT",
          codeName: "STORMS-03",
          destinationName: "Moon — Ocean of Storms (3.01° S, 23.42° W)",
          planetaryData: PlanetaryData.moon,
          historicalInspiration: "Apollo 12 (Nov 1969) — Precision pinpoint landing within 160 meters of the robotic Surveyor 3 probe (landed 1967).",
          briefingSummary: "Perform a pinpoint landing within the target crater rim. Walk to the historic Surveyor 3 robotic probe, inspect and photograph its condition, retrieve its camera sensor component, and deploy the ALSEP nuclear scientific station.",
          coinReward: 200,
          xpReward: 600,
          gameplayMode: MissionGameplayMode.surfaceExploration,
          objectives: [
            MissionObjective(key: "precision_touchdown", description: "Touchdown within 200 meters of the Surveyor 3 beacon"),
            MissionObjective(key: "inspect_surveyor", description: "Approach and photograph Surveyor 3 probe structure"),
            MissionObjective(key: "recover_camera", description: "Carefully detach and recover Surveyor 3 TV Camera"),
            MissionObjective(key: "deploy_alsep", description: "Deploy ALSEP Passive Seismic Experiment station"),
            MissionObjective(key: "secure_equipment", description: "Stow recovered hardware in vehicle storage vault"),
          ],
          requiredEquipments: ["Precision Radar Guidance", "Tool Kit", "ALSEP Station", "Sample Vault"],
          nasaSourceKeys: ["Planetary Fact Sheet", "LRO LOLA", "PDS Apollo Compendium", "NASA Images"],
          environmentHazard: "Crater slope terrain navigation, electrostatically levitated lunar dust clinging to visors",
          defaultVideoAsset: "assets/videos/lunar_exploration.mp4",
        ),

        // LEVEL 4: APOLLO 15
        MissionModel(
          levelNumber: 4,
          id: "m04_apollo15",
          title: "APOLLO 15: LUNAR ROVER EXPEDITION",
          codeName: "HADLEY-04",
          destinationName: "Moon — Hadley–Apennine Region (26.13° N, 3.63° E)",
          planetaryData: PlanetaryData.moon,
          historicalInspiration: "Apollo 15 (July 1971) — First mission with the Lunar Roving Vehicle (LRV), exploring Hadley Rille and finding the 'Genesis Rock'.",
          briefingSummary: "Deploy the electric Lunar Roving Vehicle from the lander bay. Drive across undulating terrain toward Hadley Rille, dismount to collect vesicular basalt and ancient anorthosite, monitor rover battery levels, and return safely.",
          coinReward: 250,
          xpReward: 750,
          gameplayMode: MissionGameplayMode.roverExpedition,
          objectives: [
            MissionObjective(key: "deploy_lrv", description: "Unlatch and deploy the Lunar Roving Vehicle from lander bay"),
            MissionObjective(key: "drive_waypoint1", description: "Drive LRV to Station 2 at Mount Hadley Delta"),
            MissionObjective(key: "collect_genesis_rock", description: "Dismount astronaut and collect ancient Anorthosite (Genesis Rock #15415)"),
            MissionObjective(key: "drive_rille_edge", description: "Navigate rover along rim of Hadley Rille gorge"),
            MissionObjective(key: "collect_rille_basalt", description: "Collect Olivine-Porphyritic Basalt sample"),
            MissionObjective(key: "rover_return", description: "Drive rover back to lander before battery drains below 10%"),
          ],
          requiredEquipments: ["Rover Deployment Cradle", "LRV Vehicle", "Geology Tongs", "Sample Bags"],
          nasaSourceKeys: ["LRO LOLA Hadley Elevation", "PDS Geosciences", "NASA 3D Resources"],
          environmentHazard: "Steep 15-degree canyon slopes, battery energy conservation, navigation without magnetic compass",
          defaultVideoAsset: "assets/videos/lunar_exploration.mp4",
        ),

        // LEVEL 5: APOLLO 17
        MissionModel(
          levelNumber: 5,
          id: "m05_apollo17",
          title: "APOLLO 17: FIELD SCIENTIST",
          codeName: "TAURUS-05",
          destinationName: "Moon — Taurus–Littrow Valley (20.19° N, 30.77° E)",
          planetaryData: PlanetaryData.moon,
          historicalInspiration: "Apollo 17 (Dec 1972) — Geological expedition featuring geologist Harrison Schmitt, discovering orange volcanic glass beads.",
          briefingSummary: "Conduct precision geological field investigation across the Taurus-Littrow valley. Photograph geological stratigraphy, discover and sample the famous Shorty Crater orange pyroclastic soil, and assemble the Surface Electrical Properties experiment.",
          coinReward: 300,
          xpReward: 900,
          gameplayMode: MissionGameplayMode.surfaceExploration,
          objectives: [
            MissionObjective(key: "survey_route", description: "Scout valley route and photograph South Massif landslide"),
            MissionObjective(key: "find_orange_soil", description: "Locate and sample Shorty Crater Orange Volcanic Glass (#74220)"),
            MissionObjective(key: "sample_troctolite", description: "Sample ancient Plutonic Troctolite rock (#76535)"),
            MissionObjective(key: "deploy_seismic_geophone", description: "Set up explosive seismic geophone array"),
            MissionObjective(key: "ingress_vehicle", description: "Secure all samples in lander vault and close hatch"),
          ],
          requiredEquipments: ["Geological Hammer", "Core Tube Drill", "Gnomon Scale Camera", "Sample Vault"],
          nasaSourceKeys: ["PDS Lunar Sample Compendium", "LRO LOLA Topography", "NASA Images"],
          environmentHazard: "Massive boulder fields, sharp thermal radiation gradients, limited astronaut suit oxygen reserve",
          defaultVideoAsset: "assets/videos/lunar_exploration.mp4",
        ),

        // LEVEL 6: STS-31
        MissionModel(
          levelNumber: 6,
          id: "m06_sts31",
          title: "STS-31: HUBBLE DEPLOYMENT",
          codeName: "DISCOVERY-06",
          destinationName: "Low Earth Orbit (612 km circular, 28.5° inclination)",
          planetaryData: PlanetaryData.earth,
          historicalInspiration: "STS-31 Space Shuttle Discovery (April 1990) — Historic orbital mission deploying the Hubble Space Telescope.",
          briefingSummary: "Pilot the Space Shuttle into a high 612 km deployment orbit. Stabilize spacecraft attitude, open the payload bay doors, unlatch the Hubble telescope via robotic grapple, maintain safe stand-off distance, and confirm solar array unfurling.",
          coinReward: 350,
          xpReward: 1050,
          gameplayMode: MissionGameplayMode.orbitalDeployment,
          objectives: [
            MissionObjective(key: "reach_hst_orbit", description: "Achieve 612 km circular deployment orbit with RCS null-drift"),
            MissionObjective(key: "open_payload_bay", description: "Open Shuttle payload bay radiator doors"),
            MissionObjective(key: "grapple_unlatch", description: "Activate Remote Manipulator System and unlatch Hubble"),
            MissionObjective(key: "verify_arrays", description: "Verify dual solar wing deployment status"),
            MissionObjective(key: "separation_burn", description: "Perform gentle RCS separation burn to 120m stand-off"),
          ],
          requiredEquipments: ["Shuttle Cargo Bay", "RCS Quad Thrusters", "Remote Manipulator Arm", "Comm High-Gain"],
          nasaSourceKeys: ["NASA 3D Resources Hubble", "JPL Horizons LEO", "NASA Video Library"],
          environmentHazard: "Orbital micro-debris in LEO, aerodynamic residual drag, Earth magnetic torque on solar wings",
          defaultVideoAsset: "assets/videos/space_background.mp4",
        ),

        // LEVEL 7: STS-61
        MissionModel(
          levelNumber: 7,
          id: "m07_sts61",
          title: "STS-61: HUBBLE SERVICING",
          codeName: "ENDEAVOUR-07",
          destinationName: "Low Earth Orbit — HST Servicing Berth",
          planetaryData: PlanetaryData.earth,
          historicalInspiration: "STS-61 Space Shuttle Endeavour (Dec 1993) — Daring multi-EVA mission installing COSTAR corrective optics on Hubble.",
          briefingSummary: "Rendezvous with the Hubble Space Telescope and secure it in the payload flight support berth. Depressurize the airlock, float outside in zero-gravity with suit thrusters and safety tether, replace the WFPC2 camera optics module, and test system response.",
          coinReward: 400,
          xpReward: 1200,
          gameplayMode: MissionGameplayMode.zeroGravityEva,
          objectives: [
            MissionObjective(key: "rendezvous_berth", description: "Approach within 10m of HST and secure telescope to berthing ring"),
            MissionObjective(key: "airlock_depress_eva", description: "Depressurize airlock and exit into zero-g orbital EVA"),
            MissionObjective(key: "navigate_tether", description: "Maneuver using suit RCS thrusters along safety tether boundary"),
            MissionObjective(key: "replace_wfpc2", description: "Install Wide Field and Planetary Camera 2 (WFPC2) optical box"),
            MissionObjective(key: "verify_telemetry", description: "Verify electrical power and optical alignment with Goddard control"),
            MissionObjective(key: "reenter_airlock", description: "Return to airlock, repressurize, and complete spacewalk"),
          ],
          requiredEquipments: ["Shuttle EMU Spacewalk Suit", "EVA Power Tools", "COSTAR/WFPC2 Module", "Safety Tether"],
          nasaSourceKeys: ["NASA 3D Resources", "SPICE Trajectory", "NASA Video Library"],
          environmentHazard: "Extreme orbital day/night thermal cycling (-100°C to +120°C every 45 mins), zero-g drift hazard",
          defaultVideoAsset: "assets/videos/space_background.mp4",
        ),

        // LEVEL 8: STS-88
        MissionModel(
          levelNumber: 8,
          id: "m08_sts88",
          title: "STS-88: SPACE STATION ASSEMBLY",
          codeName: "UNITY-08",
          destinationName: "Low Earth Orbit (390 km, 51.6° inclination)",
          planetaryData: PlanetaryData.earth,
          historicalInspiration: "STS-88 Space Shuttle Endeavour (Dec 1998) — First International Space Station assembly mission connecting Unity Node 1 and Zarya FGB.",
          briefingSummary: "Carry the Unity Node 1 module into orbit and rendezvous with the Russian Zarya module. Maneuver into docking alignment, complete magnetic capture, then perform a zero-gravity spacewalk to connect external power, data, and fluid umbilicals.",
          coinReward: 450,
          xpReward: 1350,
          gameplayMode: MissionGameplayMode.zeroGravityEva,
          objectives: [
            MissionObjective(key: "approach_zarya", description: "Pilot Endeavour within 5 meters of Zarya module"),
            MissionObjective(key: "docking_capture", description: "Align APDS docking ring (< 3° angle) and complete hard latch"),
            MissionObjective(key: "exit_assembly_eva", description: "Exit into zero-g assembly EVA as your astronaut"),
            MissionObjective(key: "connect_umbilicals", description: "Connect 4 high-voltage power and telemetry cables between modules"),
            MissionObjective(key: "station_power_on", description: "Verify Unity station bus electrical telemetry is active"),
            MissionObjective(key: "safe_return", description: "Return crew inside cabin safely"),
          ],
          requiredEquipments: ["Androgynous Docking Ring", "Unity Node 1 Payload", "EVA Cable Kit", "RCS Blocks"],
          nasaSourceKeys: ["NASA 3D Resources ISS", "JPL Horizons", "NASA Images"],
          environmentHazard: "Complex multi-body inertia, tether entanglement risks, 51.6° orbital inclination radiation belts",
          defaultVideoAsset: "assets/videos/space_background.mp4",
        ),

        // LEVEL 9: OSIRIS-REx
        MissionModel(
          levelNumber: 9,
          id: "m09_osiris_rex",
          title: "OSIRIS-REx: BENNU SAMPLE OPERATION",
          codeName: "TAGSAM-09",
          destinationName: "Near-Earth Asteroid (101955) Bennu (1.126 AU)",
          planetaryData: PlanetaryData.bennu,
          historicalInspiration: "OSIRIS-REx (2020) — Robotic mission collecting pristine carbonaceous regolith from hazardous boulder-strewn asteroid Bennu.",
          disclaimerNotice: "HISTORICAL FACT: OSIRIS-REx was an uncrewed robotic probe operated from Earth. You are commanding the autonomous probe console as mission operator.",
          briefingSummary: "Command the OSIRIS-REx robotic spacecraft from the mission operator console. Execute autonomous descent into the boulder-strewn Nightingale sampling site, fire the nitrogen gas canister in a 5-second Touch-and-Go (TAG) maneuver, secure the sample in the return capsule, and burn for Earth.",
          coinReward: 500,
          xpReward: 1600,
          gameplayMode: MissionGameplayMode.roboticConsole,
          objectives: [
            MissionObjective(key: "orbital_recon", description: "Perform 1 km asteroid reconnaissance mapping orbit"),
            MissionObjective(key: "descent_nightingale", description: "Guide Touch-and-Go arm toward Nightingale crater ring"),
            MissionObjective(key: "fire_nitrogen_tag", description: "Contact surface for 5 seconds and trigger TAGSAM nitrogen burst"),
            MissionObjective(key: "collect_bennu_sample", description: "Acquire > 60g of pristine carbon-rich regolith"),
            MissionObjective(key: "stow_src_capsule", description: "Stow Tag-SAM head inside Sample Return Capsule (SRC)"),
            MissionObjective(key: "earth_return_trajectory", description: "Ignite main thruster for 2.5-year Earth trajectory transfer"),
          ],
          requiredEquipments: ["OSIRIS Deep-Space Bus", "Tag-SAM Robotic Arm", "Sample Return Capsule", "Solar Wings"],
          nasaSourceKeys: ["NASA Planetary Fact Sheet (Bennu)", "JPL Horizons Bennu Ephemeris", "PDS Asteroid Data", "SPICE NAIF"],
          environmentHazard: "Microgravity (~0.00006 m/s²), high boulder density, particle ejection plumes from asteroid surface",
          defaultVideoAsset: "assets/videos/space_background.mp4",
        ),

        // LEVEL 10: PERSEVERANCE MARS
        MissionModel(
          levelNumber: 10,
          id: "m10_perseverance_mars",
          title: "PERSEVERANCE: MARS EXPEDITION",
          codeName: "JEZERO-10",
          destinationName: "Mars — Jezero Crater Delta (18.38° N, 77.58° E)",
          planetaryData: PlanetaryData.mars,
          historicalInspiration: "Perseverance Rover & Mars Sample Return Science.",
          disclaimerNotice: "SIMULATION NOTICE: This is a Fictional Astronaut Training Simulation Inspired by NASA Mars Science. Real Mars rover Perseverance is robotic; samples have not yet returned to Earth.",
          briefingSummary: "Execute Entry, Descent, and Landing through thin Martian CO2 atmosphere into ancient lakebed Jezero Crater. Egress in the Mars pressurized exploration suit, explore the ancient river delta, operate the rock-coring drill, collect and hermetically seal 3 core samples into cache tubes, deposit sample tubes, and transmit the exploration synthesis report to conclude the campaign!",
          coinReward: 600,
          xpReward: 2000,
          gameplayMode: MissionGameplayMode.roverExpedition,
          objectives: [
            MissionObjective(key: "martian_edl_landing", description: "Complete supersonic parachute & sky-crane landing in Jezero Crater"),
            MissionObjective(key: "astronaut_egress_mars", description: "Exit vehicle as your customized astronaut in Mars bio-suit"),
            MissionObjective(key: "explore_river_delta", description: "Navigate rover to ancient river delta fan sedimentary cliffs"),
            MissionObjective(key: "core_clay_sample", description: "Drill & seal Mudstone Clay core sample (Tube #01)"),
            MissionObjective(key: "core_igneous_sample", description: "Drill & seal Olivine Igneous floor sample (Tube #02)"),
            MissionObjective(key: "core_carbonate_sample", description: "Drill & seal Lacustrine Carbonate sample (Tube #03)"),
            MissionObjective(key: "cache_samples_depot", description: "Deposit sealed sample tubes at designated depot cache site"),
            MissionObjective(key: "transmit_final_report", description: "Return to lander console and transmit NASA exploration report"),
          ],
          requiredEquipments: ["Mars Pressure Suit", "Martian Surface Lander", "Drill Coring Kit", "Sample Cache Tubes"],
          nasaSourceKeys: ["NASA Planetary Fact Sheet (Mars)", "JPL Horizons Mars (499)", "PDS Mars Jezero", "NASA 3D Models"],
          environmentHazard: "Thin Martian CO2 atmosphere (0.6 kPa), dust devils, extreme chill (-63°C), 20-minute radio light delay",
          defaultVideoAsset: "assets/videos/lunar_exploration.mp4",
        ),
      ];
}

