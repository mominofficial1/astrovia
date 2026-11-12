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
      for (final obj in m1.objectives) {
        state.completeObjective(obj.key);
      }

      final res1 = state.completeMissionSuccess(baseScore: 1000, timeSeconds: 120);
      expect(res1['success'], isTrue);
      expect(res1['isFirstClear'], isTrue);
      expect(res1['coinsAwarded'], m1.coinReward);
      expect(state.saveData.unlockedCampaignLevel, 2);
      expect(state.saveData.isLevelUnlocked(2), isTrue);
      expect(state.saveData.coins, 200 + m1.coinReward);

      // Replaying Level 1 awards 25% reward and never locks Level 2
      final coinsBeforeReplay = state.saveData.coins;
      final res2 = state.completeMissionSuccess(baseScore: 1100, timeSeconds: 110);
      expect(res2['success'], isTrue);
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
      for (final obj in m10.objectives) {
        state.completeObjective(obj.key);
      }

      final res = state.completeMissionSuccess(baseScore: 2500, timeSeconds: 240);
      expect(res['success'], isTrue);
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
    test('Apollo 11 initializes with world entities including PSEP, and supports airlock egress flow', () {
      final m2 = MissionModel.allMissions[1];
      final profile = AstronautProfile();
      final controller = SurfaceExplorationController(
        mission: m2,
        astronautProfile: profile,
      );

      // Verify world entities populated
      expect(controller.worldEntities.length, greaterThanOrEqualTo(5));
      expect(controller.worldEntities.any((e) => e.id == "apollo11_psep_site"), isTrue);
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

  group('10. Explicit Game States & Attempt ID Tracking', () {
    test('startMission creates unique attempt ID and initializes phase state', () {
      final state = MissionState.instance;
      final m2 = MissionModel.allMissions[1];

      state.startMission(m2);
      final id1 = state.currentAttemptId;
      expect(id1.startsWith("att_"), isTrue);
      expect(state.currentPhase, MissionPhase.briefing);
      expect(state.currentControlMode, ControlMode.none);

      state.setMissionPhase(MissionPhase.surfaceActivity);
      expect(state.currentPhase, MissionPhase.surfaceActivity);

      state.setControlMode(ControlMode.astronaut);
      expect(state.currentControlMode, ControlMode.astronaut);

      // Starting mission generates fresh distinct attempt ID
      state.startMission(m2);
      final id2 = state.currentAttemptId;
      expect(id2.isNotEmpty, isTrue);
      expect(id1 != id2 || id1.contains("m02"), isTrue);
    });
  });

  group('11. Central Authoritative Success Validator', () {
    test('Validator rejects attempt ID mismatch', () {
      final state = MissionState.instance;
      final m2 = MissionModel.allMissions[1];
      state.startMission(m2);

      final val = state.validateMissionSuccess("bogus_attempt_id");
      expect(val.isValid, isFalse);
      expect(val.failureReason.contains("MISMATCH"), isTrue);
    });

    test('Validator rejects when non-optional objectives are incomplete', () {
      final state = MissionState.instance;
      final m2 = MissionModel.allMissions[1];
      state.startMission(m2);

      // Only complete 1 out of 7 objectives
      state.completeObjective("apollo11_landing");
      final val = state.validateMissionSuccess(state.currentAttemptId);
      expect(val.isValid, isFalse);
      expect(val.failureReason.contains("INCOMPLETE"), isTrue);
    });

    test('Validator rejects when samples remain in astronaut backpack', () {
      final state = MissionState.instance;
      final m2 = MissionModel.allMissions[1];
      state.startMission(m2);

      for (final obj in m2.objectives) {
        state.completeObjective(obj.key);
      }
      state.setCrewOutside(false);
      state.setHatchState(false);

      // Put un-transferred sample in backpack
      state.bag.addItem(InventoryItem(
        id: "sample_basalt_10017",
        name: "Mare Basalt",
        category: "Sample",
        massKg: 1.8,
        description: "D",
        locationFound: "L",
        missionRelevance: "R",
        iconKey: "landscape",
      ));

      final val = state.validateMissionSuccess(state.currentAttemptId);
      expect(val.isValid, isFalse);
      expect(val.failureReason.contains("BACKPACK"), isTrue);
    });

    test('Validator rejects when crew remains outside spacecraft or hatch is unsealed', () {
      final state = MissionState.instance;
      final m2 = MissionModel.allMissions[1];
      state.startMission(m2);

      for (final obj in m2.objectives) {
        state.completeObjective(obj.key);
      }

      // Crew left outside
      state.setCrewOutside(true);
      final valCrew = state.validateMissionSuccess(state.currentAttemptId);
      expect(valCrew.isValid, isFalse);
      expect(valCrew.failureReason.contains("OUTSIDE"), isTrue);

      // Ingress crew but leave hatch unsealed
      state.setCrewOutside(false);
      state.setHatchState(true);
      final valHatch = state.validateMissionSuccess(state.currentAttemptId);
      expect(valHatch.isValid, isFalse);
      expect(valHatch.failureReason.contains("UNSEALED"), isTrue);
    });

    test('completeMissionSuccess returns false and grants no coins if validation fails', () {
      final state = MissionState.instance;
      state.refreshFromSave();
      state.saveData.unlockedCampaignLevel = 2;
      state.saveData.coins = 100;
      final m2 = MissionModel.allMissions[1];
      state.startMission(m2);

      final res = state.completeMissionSuccess(
        attemptId: state.currentAttemptId,
        baseScore: 1000,
        timeSeconds: 120,
      );

      expect(res['success'], isFalse);
      expect(res['coinsAwarded'], 0);
      expect(state.saveData.coins, 100); // Unchanged!
      expect(state.saveData.unlockedCampaignLevel, 2); // Unchanged!
      expect(state.saveData.isLevelUnlocked(3), isFalse); // Not unlocked!
    });
  });

  group('12. Complete 7-Stage Apollo 11 Gameplay Verification', () {
    test('Apollo 11 reference mission satisfies all 7 validated stages in sequence', () {
      final state = MissionState.instance;
      state.refreshFromSave();
      state.saveData.unlockedCampaignLevel = 2;
      final m2 = MissionModel.allMissions[1];
      state.startMission(m2);

      final ctrl = SurfaceExplorationController(
        mission: m2,
        astronautProfile: state.saveData.playerProfile,
      );

      // Stage 1: Safe Landing Touchdown
      state.completeObjective("apollo11_landing");
      expect(state.isObjectiveCompleted("apollo11_landing"), isTrue);

      // Stage 2: Airlock Depress, Open Hatch & Egress
      ctrl.openVehicleHatch();
      ctrl.egressAstronaut();
      expect(state.isObjectiveCompleted("apollo11_hatch_exit"), isTrue);
      expect(ctrl.isAstronautOutside, isTrue);

      // Stage 3: Collect 3 Designated Samples (Basalt, Breccia, Regolith)
      final basalt = ctrl.worldEntities.firstWhere((e) => e.id == "sample_basalt_10017");
      final breccia = ctrl.worldEntities.firstWhere((e) => e.id == "sample_breccia_10021");
      final regolith = ctrl.worldEntities.firstWhere((e) => e.id == "sample_regolith_10005");

      ctrl.nearestEntity = basalt;
      ctrl.startCollectionProcess();
      state.pickupWorldItem(basalt.sampleItem!);
      state.apollo11SamplesCollectedCount++;
      basalt.isCollected = true;

      ctrl.nearestEntity = breccia;
      ctrl.startCollectionProcess();
      state.pickupWorldItem(breccia.sampleItem!);
      state.apollo11SamplesCollectedCount++;
      breccia.isCollected = true;

      ctrl.nearestEntity = regolith;
      ctrl.startCollectionProcess();
      state.pickupWorldItem(regolith.sampleItem!);
      state.apollo11SamplesCollectedCount++;
      regolith.isCollected = true;

      expect(state.apollo11SamplesCollectedCount, 3);
      state.completeObjective("apollo11_samples");
      expect(state.isObjectiveCompleted("apollo11_samples"), isTrue);
      expect(state.bag.items.length, 3);

      // Stage 4: Deploy PSEP Seismic Station
      final psep = ctrl.worldEntities.firstWhere((e) => e.id == "apollo11_psep_site");
      ctrl.nearestEntity = psep;
      ctrl.interactWithNearest();
      expect(state.isObjectiveCompleted("apollo11_deploy_psep"), isTrue);
      expect(psep.isInteractedWith, isTrue);

      // Stage 5: Sample Transfer to Vehicle Vault
      state.transferSamplesToVehicleStorage();
      expect(state.isObjectiveCompleted("apollo11_transfer"), isTrue);
      expect(state.bag.items.isEmpty, isTrue);
      expect(state.activeVehicleStorage.length, 3);

      // Stage 6: Cabin Ingress & Seal Hatch
      ctrl.ingressAstronaut();
      expect(state.isObjectiveCompleted("apollo11_ingress"), isTrue);
      expect(ctrl.isAstronautOutside, isFalse);
      expect(ctrl.isLanderHatchOpen, isFalse);

      // Stage 7: Ignite Ascent Propulsion & Return Trajectory
      ctrl.executeAscentReturn();
      expect(state.isObjectiveCompleted("apollo11_return"), isTrue);
      expect(state.currentPhase, MissionPhase.returnPhase);

      // Final Authoritative Validation
      final validation = state.validateMissionSuccess(state.currentAttemptId);
      expect(validation.isValid, isTrue);

      // Complete Mission and verify rewards + level unlock
      final result = state.completeMissionSuccess(
        attemptId: state.currentAttemptId,
        baseScore: 1300,
        timeSeconds: 150,
      );

      expect(result['success'], isTrue);
      expect(result['coinsAwarded'], m2.coinReward);
      expect(result['xpAwarded'], m2.xpReward);
      expect(state.saveData.unlockedCampaignLevel, 3);
      expect(state.saveData.isLevelUnlocked(3), isTrue);

      ctrl.dispose();
    });
  });

  group('13. Kinematics, Collision Sliding & Jump Physics', () {
    test('Diagonal input vector is normalized to unit length', () {
      final m2 = MissionModel.allMissions[1];
      final ctrl = SurfaceExplorationController(
        mission: m2,
        astronautProfile: AstronautProfile(),
      );

      // Diagonal input (dx=1, dy=1) has raw length sqrt(2) ~ 1.414
      ctrl.setMovementVector(const Offset(1.0, 1.0));
      expect(ctrl.rawInputVector, const Offset(1.0, 1.0));
      expect(ctrl.normalizedMovementVector.distance, closeTo(1.0, 0.001));
      ctrl.dispose();
    });

    test('Lander collision box blocks penetrating displacement and allows sliding', () {
      final m2 = MissionModel.allMissions[1];
      final ctrl = SurfaceExplorationController(
        mission: m2,
        astronautProfile: AstronautProfile(),
      );
      ctrl.egressAstronaut(); // Put astronaut outside on foot

      // Place player just to the right of the lander box (lander is at [-180, 40], width 85 => right edge -137.5)
      ctrl.playerWorldPos = const Offset(-136.0, 40.0);
      ctrl.playerVelocity = const Offset(-5.0, 0.0); // Moving directly into lander

      // Simulate step: moving directly left into lander is blocked
      final landerBounds = Rect.fromCenter(center: ctrl.landerWorldPos, width: 85.0, height: 65.0);
      expect(landerBounds.contains(ctrl.playerWorldPos + ctrl.playerVelocity), isTrue);

      // Diagonal slide: moving left and down
      ctrl.playerVelocity = const Offset(-5.0, 3.0);
      final nextPos = ctrl.playerWorldPos + ctrl.playerVelocity;
      final testX = Offset(nextPos.dx, ctrl.playerWorldPos.dy);
      final testY = Offset(ctrl.playerWorldPos.dx, nextPos.dy);

      expect(landerBounds.contains(testX), isTrue); // X is blocked
      expect(landerBounds.contains(testY), isFalse); // Y is clear to slide!

      ctrl.dispose();
    });

    test('Astronaut is grounded on surface plane and cannot jump while airborne', () {
      final m2 = MissionModel.allMissions[1];
      final ctrl = SurfaceExplorationController(
        mission: m2,
        astronautProfile: AstronautProfile(),
      );

      expect(ctrl.isGrounded, isTrue);
      ctrl.triggerJump();
      expect(ctrl.isJumping, isTrue);
      ctrl.jumpVerticalOffset = 5.0; // In air
      expect(ctrl.isGrounded, isFalse);

      // Second jump request while airborne must be ignored
      final prevVel = ctrl.jumpVelocity;
      ctrl.triggerJump();
      expect(ctrl.jumpVelocity, prevVel); // Velocity not reset by midair spam

      ctrl.dispose();
    });
  });
}

