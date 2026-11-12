import 'package:flutter/material.dart';

enum ComponentCategory {
  capsulePayload,
  structure,
  propellantTank,
  mainEngine,
  upperEngine,
  booster,
  separator,
  fairing,
  avionics,
  commAntenna,
  electricalBattery,
  solarArray,
  rcsThruster,
  lifeSupport,
  thermalHeatShield,
  parachute,
  landingLegs,
  dockingPort,
  scienceInstrument,
  sampleStorage,
  roverBay,
}

class SpacecraftComponent {
  final String id;
  final String name;
  final ComponentCategory category;
  final String description;
  final double massKg;
  final double fuelKg;
  final double thrustKn;
  final double ispSec;
  final double powerGenWatts;
  final double powerDrawWatts;
  final double lifeSupportHours;
  final int costCoins;
  final int stage; // 1 = first/booster stage, 2 = upper/transfer, 3 = payload/lander
  final String iconName;
  final Color baseColor;

  const SpacecraftComponent({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.massKg = 200,
    this.fuelKg = 0,
    this.thrustKn = 0,
    this.ispSec = 0,
    this.powerGenWatts = 0,
    this.powerDrawWatts = 15,
    this.lifeSupportHours = 0,
    this.costCoins = 0,
    this.stage = 2,
    this.iconName = "extension",
    this.baseColor = const Color(0xFF90A4AE),
  });

  static const List<SpacecraftComponent> catalog = [
    // 1. Crew Capsule / Robotic Payloads
    SpacecraftComponent(
      id: "capsule_apollo",
      name: "Apollo Command Module",
      category: ComponentCategory.capsulePayload,
      description: "Pressurized 3-crew aerodynamic capsule for lunar exploration & orbital re-entry.",
      massKg: 5800,
      powerDrawWatts: 120,
      lifeSupportHours: 240,
      stage: 3,
      baseColor: Color(0xFFCFD8DC),
    ),
    SpacecraftComponent(
      id: "payload_lem_cabin",
      name: "Lunar Ascent Cockpit",
      category: ComponentCategory.capsulePayload,
      description: "Lightweight 2-crew pressurized cockpit with EVA ingress/egress hatch.",
      massKg: 2150,
      powerDrawWatts: 90,
      lifeSupportHours: 72,
      stage: 3,
      baseColor: Color(0xFFFFB300),
    ),
    SpacecraftComponent(
      id: "payload_robotic_bus",
      name: "OSIRIS Deep-Space Bus",
      category: ComponentCategory.capsulePayload,
      description: "Autonomous high-precision avionics bus with Tag-SAM robotic arm interface.",
      massKg: 880,
      powerDrawWatts: 80,
      lifeSupportHours: 0,
      stage: 3,
      baseColor: Color(0xFF78909C),
    ),
    SpacecraftComponent(
      id: "payload_shuttle_orbiter",
      name: "Shuttle Crew Cabin & Bay",
      category: ComponentCategory.capsulePayload,
      description: "Reusable orbiter cabin with 18-meter unpressurized payload bay.",
      massKg: 12500,
      powerDrawWatts: 240,
      lifeSupportHours: 380,
      stage: 3,
      baseColor: Color(0xFFECEFF1),
    ),

    // 2. Propellant Tanks
    SpacecraftComponent(
      id: "tank_stage1_kerolox",
      name: "Heavy Booster Core Tank",
      category: ComponentCategory.propellantTank,
      description: "Cryogenic liquid oxygen and RP-1 tank for high-thrust atmospheric ascent.",
      massKg: 12000,
      fuelKg: 140000,
      stage: 1,
      baseColor: Color(0xFFB0BEC5),
    ),
    SpacecraftComponent(
      id: "tank_stage2_hydrolox",
      name: "Translunar Injection Tank",
      category: ComponentCategory.propellantTank,
      description: "Liquid hydrogen & liquid oxygen tank with vacuum multi-layer insulation.",
      massKg: 3500,
      fuelKg: 38000,
      stage: 2,
      baseColor: Color(0xFF90A4AE),
    ),
    SpacecraftComponent(
      id: "tank_lander_hypergolic",
      name: "Lander Descent Aerozine Tank",
      category: ComponentCategory.propellantTank,
      description: "Storable hypergolic NTO/UDMH propellant for reliable in-space ignition.",
      massKg: 950,
      fuelKg: 8200,
      stage: 3,
      baseColor: Color(0xFFFFCC80),
    ),

    // 3. Engines
    SpacecraftComponent(
      id: "engine_f1_cluster",
      name: "F-1 Heavy Main Engines",
      category: ComponentCategory.mainEngine,
      description: "Massive gas-generator rocket engine cluster producing 7,500 kN liftoff thrust.",
      massKg: 8400,
      thrustKn: 7500,
      ispSec: 304,
      stage: 1,
      baseColor: Color(0xFF37474F),
    ),
    SpacecraftComponent(
      id: "engine_j2_vacuum",
      name: "J-2 Upper Stage Engine",
      category: ComponentCategory.upperEngine,
      description: "High-expansion hydrolox vacuum engine for orbital insertion and lunar burn.",
      massKg: 1600,
      thrustKn: 1030,
      ispSec: 421,
      stage: 2,
      baseColor: Color(0xFF455A64),
    ),
    SpacecraftComponent(
      id: "engine_dps_throttle",
      name: "Throttleable Descent Engine",
      category: ComponentCategory.upperEngine,
      description: "Continuous throttle descent engine (10% - 100%) for soft planetary landings.",
      massKg: 420,
      thrustKn: 45,
      ispSec: 311,
      stage: 3,
      baseColor: Color(0xFF546E7A),
    ),
    SpacecraftComponent(
      id: "engine_ion_xenon",
      name: "NEXT-C Ion Plasma Engine",
      category: ComponentCategory.upperEngine,
      description: "Ultra-efficient electrostatic ion thruster for interplanetary trajectories.",
      massKg: 110,
      thrustKn: 0.25,
      ispSec: 4200,
      powerDrawWatts: 450,
      stage: 3,
      baseColor: Color(0xFF00B0FF),
    ),

    // 4. Boosters
    SpacecraftComponent(
      id: "booster_srb_pair",
      name: "Solid Rocket Booster Straps",
      category: ComponentCategory.booster,
      description: "High-impulse segmented solid propellant boosters for initial liftoff kick.",
      massKg: 14000,
      fuelKg: 90000,
      thrustKn: 4800,
      ispSec: 268,
      stage: 1,
      baseColor: Color(0xFFECEFF1),
    ),

    // 5. Structure & Staging
    SpacecraftComponent(
      id: "separator_stage1_2",
      name: "Pneumatic Interstage Ring",
      category: ComponentCategory.separator,
      description: "Pyrotechnic separation ring ensuring clean first-stage staging.",
      massKg: 650,
      stage: 1,
      baseColor: Color(0xFF263238),
    ),
    SpacecraftComponent(
      id: "fairing_aerodynamic",
      name: "Jettisonable Payload Fairing",
      category: ComponentCategory.fairing,
      description: "Composite fairing halves shielding delicate payloads during atmospheric flight.",
      massKg: 1100,
      stage: 2,
      baseColor: Color(0xFFFAFAFA),
    ),

    // 6. Avionics, Comm & Power
    SpacecraftComponent(
      id: "computer_guidance",
      name: "Triple-Redundant Flight Computer",
      category: ComponentCategory.avionics,
      description: "Radiation-hardened primary guidance, navigation, and control (GNC) unit.",
      massKg: 85,
      powerDrawWatts: 45,
      stage: 3,
      baseColor: Color(0xFF19D9FF),
    ),
    SpacecraftComponent(
      id: "comm_high_gain_dish",
      name: "High-Gain S-Band Comm Dish",
      category: ComponentCategory.commAntenna,
      description: "Steerable parabolic antenna transmitting real-time telemetry to Deep Space Network.",
      massKg: 45,
      powerDrawWatts: 30,
      stage: 3,
      baseColor: Color(0xFFFFD54F),
    ),
    SpacecraftComponent(
      id: "battery_lithium_bank",
      name: "Space-Grade LiFePO4 Battery Bank",
      category: ComponentCategory.electricalBattery,
      description: "High energy-density 12 kWh electrical storage for orbital eclipses.",
      massKg: 140,
      powerGenWatts: 0,
      powerDrawWatts: 0,
      stage: 3,
      baseColor: Color(0xFF00E676),
    ),
    SpacecraftComponent(
      id: "solar_deployable_wings",
      name: "Dual Deployable Solar Arrays",
      category: ComponentCategory.solarArray,
      description: "Gallium-arsenide solar tracking panels generating 2.4 kW continuous power.",
      massKg: 95,
      powerGenWatts: 2400,
      powerDrawWatts: 0,
      stage: 3,
      baseColor: Color(0xFF1565C0),
    ),

    // 7. RCS & Life Support
    SpacecraftComponent(
      id: "rcs_quad_blocks",
      name: "Quad Cold-Gas RCS Thrusters",
      category: ComponentCategory.rcsThruster,
      description: "3-axis translation and attitude control thruster blocks for docking & landing.",
      massKg: 65,
      thrustKn: 1.2,
      stage: 3,
      baseColor: Color(0xFFE0E0E0),
    ),
    SpacecraftComponent(
      id: "life_support_eclss",
      name: "ECLSS Regenerative Life Support",
      category: ComponentCategory.lifeSupport,
      description: "Carbon dioxide scrubbers, oxygen replenishment, and water recycling system.",
      massKg: 420,
      powerDrawWatts: 180,
      lifeSupportHours: 280,
      stage: 3,
      baseColor: Color(0xFF00ACC1),
    ),

    // 8. Recovery, Landing & Docking
    SpacecraftComponent(
      id: "heat_shield_ablative",
      name: "PICA-X Ablative Heat Shield",
      category: ComponentCategory.thermalHeatShield,
      description: "Phenolic-impregnated carbon ablator protecting craft during Earth re-entry at 11 km/s.",
      massKg: 480,
      stage: 3,
      baseColor: Color(0xFFBF360C),
    ),
    SpacecraftComponent(
      id: "parachute_cluster",
      name: "Triple Main Parachute System",
      category: ComponentCategory.parachute,
      description: "Drogue and main nylon parachutes for atmospheric deceleration and ocean splashdown.",
      massKg: 280,
      stage: 3,
      baseColor: Color(0xFFFF7043),
    ),
    SpacecraftComponent(
      id: "landing_legs_quad",
      name: "Crushable Quad Landing Gear",
      category: ComponentCategory.landingLegs,
      description: "Aluminum honeycomb shock-absorbing legs for stable touchdown on planetary terrain.",
      massKg: 310,
      stage: 3,
      baseColor: Color(0xFF78909C),
    ),
    SpacecraftComponent(
      id: "docking_apds_ring",
      name: "Androgynous Peripheral Docking Ring",
      category: ComponentCategory.dockingPort,
      description: "NASA Docking System (NDS) compatible latching ring for ISS & orbital berthing.",
      massKg: 195,
      stage: 3,
      baseColor: Color(0xFFCFD8DC),
    ),

    // 9. Science & Payload Storage
    SpacecraftComponent(
      id: "science_spectrometer_suite",
      name: "Multispectral Science Scanner",
      category: ComponentCategory.scienceInstrument,
      description: "Infrared and gamma-ray spectrometer for mineral composition and water detection.",
      massKg: 68,
      powerDrawWatts: 40,
      stage: 3,
      baseColor: Color(0xFFAB47BC),
    ),
    SpacecraftComponent(
      id: "sample_container_hermetic",
      name: "Hermetic Geological Sample Vault",
      category: ComponentCategory.sampleStorage,
      description: "Ultra-clean sealed storage holding up to 16 vacuum sample return tubes.",
      massKg: 45,
      stage: 3,
      baseColor: Color(0xFFFFCA28),
    ),
    SpacecraftComponent(
      id: "rover_deployment_bay",
      name: "Lunar Roving Vehicle (LRV) Cradle",
      category: ComponentCategory.roverBay,
      description: "Folded stowage and egress ramp for deployable astronaut planetary rover.",
      massKg: 480,
      stage: 3,
      baseColor: Color(0xFF5D4037),
    ),
  ];
}

class SpacecraftBuild {
  String name;
  List<String> componentIds;

  SpacecraftBuild({
    required this.name,
    required this.componentIds,
  });

  List<SpacecraftComponent> get components {
    return componentIds
        .map((id) => SpacecraftComponent.catalog.firstWhere(
              (c) => c.id == id,
              orElse: () => SpacecraftComponent.catalog.first,
            ))
        .toList();
  }

  // Pre-calculated physical parameters
  double get totalMassKg => components.fold(0.0, (acc, c) => acc + c.massKg + c.fuelKg);
  double get dryMassKg => components.fold(0.0, (acc, c) => acc + c.massKg);
  double get totalFuelKg => components.fold(0.0, (acc, c) => acc + c.fuelKg);
  double get totalLiftoffThrustKn => components
      .where((c) => c.stage == 1 || c.category == ComponentCategory.mainEngine || c.category == ComponentCategory.booster)
      .fold(0.0, (acc, c) => acc + c.thrustKn);

  // Thrust-to-Weight Ratio on Earth surface
  double get twrEarth {
    final weightKn = (totalMassKg * 9.807) / 1000.0;
    return weightKn > 0 ? (totalLiftoffThrustKn / weightKn) : 0.0;
  }

  double get netPowerWatts {
    final gen = components.fold(0.0, (acc, c) => acc + c.powerGenWatts);
    final draw = components.fold(0.0, (acc, c) => acc + c.powerDrawWatts);
    return gen - draw;
  }

  double get maxLifeSupportHours =>
      components.fold(0.0, (acc, c) => acc + c.lifeSupportHours);

  bool hasCategory(ComponentCategory cat) =>
      components.any((c) => c.category == cat);

  // Validation diagnostics
  List<String> validateForMission(int missionLevel) {
    final errors = <String>[];

    if (!hasCategory(ComponentCategory.capsulePayload)) {
      errors.add("Missing Crew Capsule or Robotic Payload Bus.");
    }
    if (!hasCategory(ComponentCategory.propellantTank)) {
      errors.add("Missing Propellant Tanks for propulsion.");
    }
    if (!hasCategory(ComponentCategory.mainEngine) && !hasCategory(ComponentCategory.upperEngine)) {
      errors.add("Missing Rocket Engines.");
    }
    if (twrEarth < 1.0 && missionLevel <= 5) {
      errors.add("Thrust-to-Weight Ratio (${twrEarth.toStringAsFixed(2)}) is below 1.0. Rocket cannot lift off from Earth!");
    }
    if (!hasCategory(ComponentCategory.avionics)) {
      errors.add("Missing Guidance Computer (Avionics) for trajectory navigation.");
    }
    if (!hasCategory(ComponentCategory.commAntenna)) {
      errors.add("Missing Communications Antenna for Deep Space Network telemetry.");
    }

    // Mission-specific physical validations
    if (missionLevel == 1) {
      // Apollo 8 (Earth re-entry)
      if (!hasCategory(ComponentCategory.thermalHeatShield)) {
        errors.add("Mission 01 requires a Heat Shield for high-speed Earth atmospheric re-entry.");
      }
      if (!hasCategory(ComponentCategory.parachute)) {
        errors.add("Mission 01 requires Parachutes for safe splashdown.");
      }
    } else if (missionLevel == 2 || missionLevel == 3) {
      // Lunar landings
      if (!hasCategory(ComponentCategory.landingLegs)) {
        errors.add("Mission requires Landing Gear (Legs) for surface touchdown.");
      }
      if (hasCategory(ComponentCategory.parachute) && missionLevel == 2) {
        // Warning: parachutes don't work in lunar vacuum
      }
    } else if (missionLevel == 4) {
      // Rover mission
      if (!hasCategory(ComponentCategory.roverBay)) {
        errors.add("Mission 04 requires a Rover Stowage Cradle to deploy the Lunar Rover.");
      }
    } else if (missionLevel == 6) {
      // Hubble deployment
      if (!hasCategory(ComponentCategory.dockingPort) && !hasCategory(ComponentCategory.rcsThruster)) {
        errors.add("Mission 06 requires RCS Thrusters for orbital payload release attitude control.");
      }
    } else if (missionLevel == 7 || missionLevel == 8) {
      // EVA & Docking
      if (!hasCategory(ComponentCategory.dockingPort)) {
        errors.add("Mission requires a Docking Ring for berthing with target spacecraft.");
      }
    }

    return errors;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'componentIds': componentIds,
      };

  factory SpacecraftBuild.fromJson(Map<String, dynamic> json) => SpacecraftBuild(
        name: json['name'] as String? ?? "Default Spacecraft",
        componentIds: (json['componentIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  // Pre-configured Starter Blueprints
  static SpacecraftBuild get starterApollo => SpacecraftBuild(
        name: "Saturn V / CSM Apollo",
        componentIds: [
          "capsule_apollo",
          "heat_shield_ablative",
          "parachute_cluster",
          "computer_guidance",
          "life_support_eclss",
          "battery_lithium_bank",
          "comm_high_gain_dish",
          "rcs_quad_blocks",
          "tank_stage2_hydrolox",
          "engine_j2_vacuum",
          "separator_stage1_2",
          "tank_stage1_kerolox",
          "engine_f1_cluster",
        ],
      );

  static SpacecraftBuild get starterLunarLander => SpacecraftBuild(
        name: "Artemis Lunar Lander",
        componentIds: [
          "payload_lem_cabin",
          "computer_guidance",
          "comm_high_gain_dish",
          "battery_lithium_bank",
          "solar_deployable_wings",
          "rcs_quad_blocks",
          "landing_legs_quad",
          "sample_container_hermetic",
          "science_spectrometer_suite",
          "tank_lander_hypergolic",
          "engine_dps_throttle",
        ],
      );

  static SpacecraftBuild get starterRoboticProbe => SpacecraftBuild(
        name: "OSIRIS-REx Robotic Sampler",
        componentIds: [
          "payload_robotic_bus",
          "computer_guidance",
          "comm_high_gain_dish",
          "solar_deployable_wings",
          "battery_lithium_bank",
          "rcs_quad_blocks",
          "sample_container_hermetic",
          "science_spectrometer_suite",
          "tank_lander_hypergolic",
          "engine_ion_xenon",
        ],
      );
}
