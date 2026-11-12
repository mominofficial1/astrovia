import 'package:flutter_test/flutter_test.dart';
import 'package:astrovia/models/astronaut_model.dart';
import 'package:astrovia/models/inventory_model.dart';
import 'package:astrovia/models/mission_model.dart';
import 'package:astrovia/models/nasa_dataset_info.dart';
import 'package:astrovia/models/planetary_data.dart';
import 'package:astrovia/models/save_data.dart';
import 'package:astrovia/models/spacecraft_model.dart';
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
}
