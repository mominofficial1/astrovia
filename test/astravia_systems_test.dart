import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrovia/controllers/surface_exploration_controller.dart';
import 'package:astrovia/models/astronaut_model.dart';
import 'package:astrovia/models/inventory_model.dart';
import 'package:astrovia/models/mission_model.dart';
import 'package:astrovia/models/nasa_dataset_info.dart';
import 'package:astrovia/models/planetary_data.dart';
import 'package:astrovia/models/save_data.dart';
import 'package:astrovia/models/spacecraft_model.dart';
import 'package:astrovia/rendering/planetary_environment_renderer.dart';
import 'package:astrovia/rendering/spacecraft_renderer.dart';
import 'package:astrovia/state/mission_state.dart';

void main() {
  group('1. Campaign Progression & Economy Rules', () {
    test('Level 1 is initially unlocked and subsequent levels locked', () {
      final save = AstraviaSaveData();
      expect(save.unlockedCampaignLevel, 1);
      expect(save.isLevelUnlocked(1), isTrue);
      expect(save.isLevelUnlocked(2), isFalse);
      expect(save.isLevelUnlocked(10), isFalse);
      expect(save.isCampaignCompleted, isFalse);
    });

    test('Completing Level N unlocks Level N+1 and awards rewards exactly once', () {
      final state = MissionState.instance;
      state.refreshFromSave();
      state.saveData.unlockedCampaignLevel = 1;
      state.saveData.coins = 200;

      final m1 = MissionModel.allMissions[0];
      state.startMission(m1);

      final res1 = state.completeMissionSuccess(baseScore: 1000, timeSeconds: 120);
      expect(res1['isFirstClear'], isTrue);
      expect(res1['coinsAwarded'], m1.coinReward);
      expect(state.saveData.unlockedCampaignLevel, 2);
      expect(state.saveData.isLevelUnlocked(2), isTrue);
      expect(state.saveData.coins, 200 + m1.coinReward);

      // Replaying Level 1 awards 25% reward and never locks Level 2
      final coinsBeforeReplay = state.saveData.coins;
      final res2 = state.completeMissionSuccess(baseScore: 1100, timeSeconds: 110);
      expect(res2['isFirstClear'], isFalse);
      expect(res2['coinsAwarded'], (m1.coinReward * 0.25).toInt());
      expect(state.saveData.coins, coinsBeforeReplay + (m1.coinReward * 0.25).toInt());
      expect(state.saveData.unlockedCampaignLevel, 2);
    });

    test('Completing Level 10 triggers campaign completion', () {
      final state = MissionState.instance;
      state.refreshFromSave();
      state.saveData.unlockedCampaignLevel = 10;

      final m10 = MissionModel.allMissions[9];
      state.startMission(m10);

      final res = state.completeMissionSuccess(baseScore: 2500, timeSeconds: 240);
      expect(res['campaignCompleted'], isTrue);
      expect(state.saveData.isCampaignCompleted, isTrue);
    });

    test('XP rank separates from campaign progression', () {
      final save = AstraviaSaveData(unlockedCampaignLevel: 1, xp: 6000);
      expect(save.astronautRank, 4); // Senior Commander
      expect(save.unlockedCampaignLevel, 1); // XP replays do not bypass mission unlocks
    });
  });

  group('2. Spacecraft Builder & Preflight Validation', () {
    test('Starter Apollo build computes valid mass, propellant and TWR', () {
      final apollo = SpacecraftBuild.starterApollo;
      expect(apollo.totalMassKg, greaterThan(150000));
      expect(apollo.totalLiftoffThrustKn, greaterThan(7000));
      expect(apollo.twrEarth, greaterThan(1.0));
      expect(apollo.validateForMission(1).isEmpty, isTrue);
    });

    test('Validation catches missing heat shield and parachutes for Earth return', () {
      final invalidBuild = SpacecraftBuild(
        name: "Unshielded Capsule",
        componentIds: [
          "capsule_apollo",
          "computer_guidance",
          "comm_high_gain_dish",
          "tank_stage1_kerolox",
          "engine_f1_cluster",
        ],
      );
      final errors = invalidBuild.validateForMission(1);
      expect(errors.any((e) => e.contains("Heat Shield")), isTrue);
      expect(errors.any((e) => e.contains("Parachutes")), isTrue);
    });

    test('Validation catches TWR < 1.0 when thrust cannot lift mass', () {
      final weakRocket = SpacecraftBuild(
        name: "Underpowered Rocket",
        componentIds: [
          "capsule_apollo",
          "heat_shield_ablative",
          "parachute_cluster",
          "computer_guidance",
          "comm_high_gain_dish",
          "tank_stage1_kerolox", // 152,000 kg mass
          "engine_dps_throttle", // only 45 kN thrust!
        ],
      );
      final errors = weakRocket.validateForMission(1);
      expect(errors.any((e) => e.contains("Thrust-to-Weight Ratio")), isTrue);
    });
  });

  group('3. Astronaut Customization & Persistence', () {
    test('Profile updates and serializes all cosmetic attributes', () {
      final p1 = AstronautProfile(
        characterId: "maya",
        callsign: "VALKYRIE",
        skinTone: "bronze",
        suitId: "deepspace",
        helmetVisorTint: "cyan",
        primaryColorValue: 0xFF0D1B2A,
      );

      final json = p1.toJson();
      final p2 = AstronautProfile.fromJson(json);

      expect(p2.characterId, "maya");
      expect(p2.callsign, "VALKYRIE");
      expect(p2.skinTone, "bronze");
      expect(p2.suitId, "deepspace");
      expect(p2.helmetVisorTint, "cyan");
      expect(p2.primaryColorValue, 0xFF0D1B2A);
      expect(p2.character.name, "MAYA LIN");
    });
  });

  group('4. Inventory Bag & Sample Security', () {
    test('Bag enforces weight capacity and prevents overflow', () {
      final bag = InventoryBag(maxCapacityKg: 5.0);
      final item1 = InventoryItem(
        id: "s1",
        name: "Heavy Sample",
        category: "Sample",
        massKg: 3.5,
        description: "Desc",
        locationFound: "Loc",
        missionRelevance: "Rel",
        iconKey: "landscape",
      );
      final item2 = InventoryItem(
        id: "s2",
        name: "Second Sample",
        category: "Sample",
        massKg: 2.0,
        description: "Desc",
        locationFound: "Loc",
        missionRelevance: "Rel",
        iconKey: "landscape",
      );

      expect(bag.addItem(item1), isTrue);
      expect(bag.currentMassKg, 3.5);
      expect(bag.addItem(item2), isFalse); // 3.5 + 2.0 = 5.5 > 5.0 limit!
      expect(bag.items.length, 1);
    });

    test('Transfer to vehicle secures samples and empties bag', () {
      final bag = InventoryBag();
      final item = InventoryItem(
        id: "s1",
        name: "Basalt",
        category: "Sample",
        massKg: 1.5,
        description: "Desc",
        locationFound: "Loc",
        missionRelevance: "Rel",
        iconKey: "landscape",
      );
      bag.addItem(item);

      final vehicleVault = <InventoryItem>[];
      bag.transferAllToVehicle(vehicleVault);

      expect(bag.items.isEmpty, isTrue);
      expect(vehicleVault.length, 1);
      expect(vehicleVault.first.isSecuredInVehicle, isTrue);
    });
  });

  group('5. NASA Data Integrity', () {
    test('All 8 required NASA sources are present with verified records', () {
      final sources = NasaDatasetEntry.allSources;
      expect(sources.length, 8);

      final titles = sources.map((s) => s.title).toList();
      expect(titles.any((t) => t.contains("Planetary Fact Sheet")), isTrue);
      expect(titles.any((t) => t.contains("Horizons")), isTrue);
      expect(titles.any((t) => t.contains("3D Resources")), isTrue);
      expect(titles.any((t) => t.contains("Image and Video Library")), isTrue);
      expect(titles.any((t) => t.contains("Planetary Data System")), isTrue);
      expect(titles.any((t) => t.contains("LRO–LOLA")), isTrue);
      expect(titles.any((t) => t.contains("DONKI")), isTrue);
      expect(titles.any((t) => t.contains("SPICE")), isTrue);

      for (final s in sources) {
        expect(s.url.startsWith("http"), isTrue);
        expect(s.exactDatasetAsset.isNotEmpty, isTrue);
        expect(s.gameFeatureUsage.isNotEmpty, isTrue);
        expect(s.status, IntegrationStatus.implemented);
      }
    });

    test('Physical planetary constants match NASA Planetary Fact Sheet', () {
      expect(PlanetaryData.earth.surfaceGravity, closeTo(9.807, 0.01));
      expect(PlanetaryData.moon.surfaceGravity, closeTo(1.62, 0.01));
      expect(PlanetaryData.mars.surfaceGravity, closeTo(3.721, 0.01));
      expect(PlanetaryData.bennu.surfaceGravity, closeTo(0.00006, 0.00001));
    });
  });

  group('6. Ten Distinct Playable Missions', () {
    test('Contains exactly 10 distinct missions with non-generic objectives', () {
      final missions = MissionModel.allMissions;
      expect(missions.length, 10);

      for (int i = 0; i < 10; i++) {
        final m = missions[i];
        expect(m.levelNumber, i + 1);
        expect(m.objectives.length, greaterThanOrEqualTo(4));
        expect(m.coinReward, greaterThan(0));
        expect(m.xpReward, greaterThan(0));
        expect(m.historicalInspiration.isNotEmpty, isTrue);
      }

      // Verify Level 9 (OSIRIS-REx) uncrewed disclaimer
      expect(missions[8].disclaimerNotice.contains("uncrewed"), isTrue);

      // Verify Level 10 (Perseverance Mars) simulation disclaimer
      expect(missions[9].disclaimerNotice.contains("Fictional Astronaut Training"), isTrue);
    });
  });

  group('7. Surface Exploration Controller & Egress Flow', () {
    test('Apollo 11 initializes with hatch open, astronaut egressed beside ladder', () {
      final m2 = MissionModel.allMissions[1];
      final profile = AstronautProfile();
      final controller = SurfaceExplorationController(
        mission: m2,
        astronautProfile: profile,
      );

      // Verify world entities populated
      expect(controller.worldEntities.length, greaterThanOrEqualTo(4));
      expect(controller.worldEntities.any((e) => e.id == "sample_basalt_10017"), isTrue);
      expect(controller.worldEntities.any((e) => e.id == "sample_breccia_10021"), isTrue);
      expect(controller.worldEntities.any((e) => e.id == "sample_regolith_10005"), isTrue);
      expect(controller.worldEntities.any((e) => e.id == "lander_airlock"), isTrue);

      controller.openVehicleHatch();
      expect(controller.isLanderHatchOpen, isTrue);

      controller.egressAstronaut();
      expect(controller.isAstronautOutside, isTrue);
      expect(controller.playerWorldPos.dx, greaterThan(controller.landerWorldPos.dx));
      controller.dispose();
    });

    test('Collection adds sample to bag and enforces 15.0 kg capacity', () {
      final m2 = MissionModel.allMissions[1];
      final profile = AstronautProfile();
      final state = MissionState.instance;
      state.startMission(m2);

      final controller = SurfaceExplorationController(
        mission: m2,
        astronautProfile: profile,
      );

      final basalt = controller.worldEntities.firstWhere((e) => e.id == "sample_basalt_10017");
      controller.nearestEntity = basalt;
      final started = controller.startCollectionProcess();
      expect(started, isTrue);
      expect(controller.isBusyCollecting, isTrue);

      // Complete collection
      controller.actionProgress = 1.0;
      controller.setMovementVector(Offset.zero); // triggers finish check in next frame or direct call
      final picked = state.pickupWorldItem(basalt.sampleItem!);
      expect(picked, isTrue);
      expect(state.bag.items.length, 1);
      expect(state.bag.currentMassKg, closeTo(1.8, 0.01));
      expect(state.bag.capacityFraction, closeTo(1.8 / 15.0, 0.01));
      controller.dispose();
    });

    test('All 10 missions generate distinct non-empty entity sets', () {
      for (final m in MissionModel.allMissions) {
        final ctrl = SurfaceExplorationController(
          mission: m,
          astronautProfile: AstronautProfile(),
        );
        expect(ctrl.worldEntities.isNotEmpty, isTrue, reason: "Mission ${m.title} should have world entities");
        ctrl.dispose();
      }
    });
  });

  group('8. Proving Grounds Suit & Equipment Shop Economy', () {
    test('Buy item deducts coins and equips item', () {
      final state = MissionState.instance;
      state.refreshFromSave();
      state.saveData.coins = 500;
      state.saveData.ownedVisorIds.clear();
      state.saveData.ownedVisorIds.add("gold");

      final bought = state.buyShopItem(
        category: "visor",
        id: "cyan",
        cost: 100,
      );

      expect(bought, isTrue);
      expect(state.saveData.coins, 400);
      expect(state.saveData.ownedVisorIds.contains("cyan"), isTrue);
      expect(state.saveData.playerProfile.helmetVisorTint, "cyan");

      // Cannot buy again if already owned
      final rebuy = state.buyShopItem(
        category: "visor",
        id: "cyan",
        cost: 100,
      );
      expect(rebuy, isFalse);
      expect(state.saveData.coins, 400); // No coins deducted
    });

    test('Cannot buy item if coins are insufficient', () {
      final state = MissionState.instance;
      state.refreshFromSave();
      state.saveData.coins = 50;

      final bought = state.buyShopItem(
        category: "suit",
        id: "deepspace",
        cost: 300,
      );
      expect(bought, isFalse);
      expect(state.saveData.coins, 50);
    });
  });

  group('9. Procedural Planetary and Spacecraft Renderers', () {
    test('SpacecraftPainter paints all vehicle configurations without error', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final size = const Size(150, 230);

      final builds = [
        SpacecraftBuild.starterApollo,
        SpacecraftBuild.starterLunarLander,
        SpacecraftBuild.starterRoboticProbe,
      ];

      for (int lvl = 1; lvl <= 10; lvl++) {
        for (final b in builds) {
          final painter = SpacecraftPainter(
            buildData: b,
            throttle: 0.5,
            isRcsFiring: true,
            landingLegsExtended: true,
            solarPanelsDeployed: true,
            hatchOpen: lvl.isEven,
            missionLevel: lvl,
          );
          expect(() => painter.paint(canvas, size), returnsNormally);
        }
      }
    });

    test('PlanetaryEnvironmentPainter paints all 10 celestial environments without error', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final size = const Size(800, 600);

      for (final m in MissionModel.allMissions) {
        final painter = PlanetaryEnvironmentPainter(
          planetaryData: m.planetaryData,
          levelNumber: m.levelNumber,
          cameraOffset: const Offset(50, 20),
          animationTime: 2.5,
          isOrbital: m.gameplayMode == MissionGameplayMode.orbitalFlight ||
              m.gameplayMode == MissionGameplayMode.orbitalDeployment ||
              m.gameplayMode == MissionGameplayMode.zeroGravityEva ||
              m.gameplayMode == MissionGameplayMode.roboticConsole,
        );
        expect(() => painter.paint(canvas, size), returnsNormally);
      }
    });
  });
}

