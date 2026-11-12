import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import '../widgets/hud_container.dart';
import 'screen_launch_flight.dart';
import 'screen_rocket_builder.dart';

class Screen06MissionBriefing extends StatelessWidget {
  const Screen06MissionBriefing({super.key});

  @override
  Widget build(BuildContext context) {
    final state = MissionState.instance;
    final mission = state.currentMission ?? MissionModel.allMissions[0];
    final spacecraft = state.activeSpacecraft;
    final profile = state.saveData.playerProfile;

    // Preflight validation check
    final validationErrors = spacecraft.validateForMission(mission.levelNumber);
    final isFlightReady = validationErrors.isEmpty;

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: AstroviaVideoBackground(
        videoAsset: mission.defaultVideoAsset,
        overlayOpacity: 0.45,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AstroviaTheme.cyan),
                      onPressed: () {
                        AudioService.instance.playClick();
                        Navigator.pop(context);
                      },
                    ),
                    Column(
                      children: [
                        Text(
                          "AEROSPACE MISSION DIRECTIVE BRIEFING",
                          style: AstroviaTheme.orbitron(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AstroviaTheme.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${mission.title} • DESTINATION: ${mission.destinationName}",
                          style: AstroviaTheme.rajdhani(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AstroviaTheme.gold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AstroviaTheme.cyan.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AstroviaTheme.cyan),
                      ),
                      child: Text(
                        "LEVEL ${mission.levelNumber.toString().padLeft(2, '0')}",
                        style: AstroviaTheme.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AstroviaTheme.cyan,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Main Content 2-Column Layout:
                // Left: Mission Directives, Historical Inspiration, Hazards & NASA Sources
                // Right: Vehicle Preflight Readiness, Commander Loadout & Ignition Trigger
                Expanded(
                  child: Row(
                    children: [
                      // Left Column
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AstroviaTheme.panelTranslucent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AstroviaTheme.cyan.withValues(alpha: 0.35)),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Historical Inspiration
                                Text(
                                  "HISTORICAL NASA MISSION INSPIRATION",
                                  style: AstroviaTheme.orbitron(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.cyan,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mission.historicalInspiration,
                                  style: AstroviaTheme.inter(
                                    fontSize: 12,
                                    color: AstroviaTheme.white,
                                    height: 1.4,
                                  ),
                                ),
                                if (mission.disclaimerNotice.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AstroviaTheme.gold
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: AstroviaTheme.gold
                                              .withValues(alpha: 0.4)),
                                    ),
                                    child: Text(
                                      mission.disclaimerNotice,
                                      style: AstroviaTheme.rajdhani(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AstroviaTheme.gold,
                                      ),
                                    ),
                                  ),
                                ],
                                const Divider(
                                    color: Color(0x3319D9FF), height: 18),

                                // Required Objectives Checklist
                                Text(
                                  "PRIMARY FLIGHT OBJECTIVES",
                                  style: AstroviaTheme.orbitron(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.gold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...mission.objectives.map((obj) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.radio_button_unchecked_rounded,
                                            size: 14,
                                            color: AstroviaTheme.cyan),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            obj.description,
                                            style: AstroviaTheme.rajdhani(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AstroviaTheme.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const Divider(
                                    color: Color(0x3319D9FF), height: 18),

                                // Expected Hazards & Environmental Specs
                                Text(
                                  "ENVIRONMENTAL HAZARDS & PHYSICS",
                                  style: AstroviaTheme.orbitron(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mission.environmentHazard,
                                  style: AstroviaTheme.inter(
                                    fontSize: 12,
                                    color: AstroviaTheme.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Surface Gravity: ${mission.planetaryData.surfaceGravity} m/s² • Atmospheric Pressure: ${mission.planetaryData.atmosphericPressure} kPa",
                                  style: AstroviaTheme.rajdhani(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.cyan,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Right Column: Spacecraft & Commander Check
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            // Spacecraft Build Readiness Card
                            HudContainer(
                              isSelected: isFlightReady,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "ASSIGNED VEHICLE",
                                        style: AstroviaTheme.orbitron(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AstroviaTheme.cyan,
                                        ),
                                      ),
                                      Icon(
                                        isFlightReady
                                            ? Icons.check_circle_rounded
                                            : Icons.warning_amber_rounded,
                                        color: isFlightReady
                                            ? AstroviaTheme.green
                                            : AstroviaTheme.red,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    spacecraft.name,
                                    style: AstroviaTheme.orbitron(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AstroviaTheme.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Mass: ${spacecraft.totalMassKg.toInt()} kg • Liftoff Thrust: ${spacecraft.totalLiftoffThrustKn.toStringAsFixed(0)} kN • Earth TWR: ${spacecraft.twrEarth.toStringAsFixed(2)}",
                                    style: AstroviaTheme.rajdhani(
                                      fontSize: 11,
                                      color: AstroviaTheme.secondary,
                                    ),
                                  ),
                                  if (!isFlightReady) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      validationErrors.first,
                                      style: AstroviaTheme.inter(
                                        fontSize: 11,
                                        color: AstroviaTheme.red,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        backgroundColor: AstroviaTheme.panel,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (ctx, a1, a2) =>
                                                const ScreenRocketBuilder(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "OPEN ASSEMBLY HANGAR TO FIX",
                                        style: AstroviaTheme.orbitron(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AstroviaTheme.cyan,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Commander Loadout Summary
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AstroviaTheme.panelTranslucent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AstroviaTheme.cyan
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ACTIVE COMMANDER",
                                    style: AstroviaTheme.orbitron(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AstroviaTheme.gold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${profile.character.name} [CALLSIGN: ${profile.callsign}]",
                                    style: AstroviaTheme.rajdhani(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AstroviaTheme.white,
                                    ),
                                  ),
                                  Text(
                                    "Suit: ${profile.currentSuit.name} • PLSS: ${profile.backpackType}",
                                    style: AstroviaTheme.inter(
                                      fontSize: 11,
                                      color: AstroviaTheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),

                            // Ignition Launch Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFlightReady
                                      ? AstroviaTheme.cyan
                                          .withValues(alpha: 0.35)
                                      : Colors.grey.withValues(alpha: 0.2),
                                  side: BorderSide(
                                    color: isFlightReady
                                        ? AstroviaTheme.cyan
                                        : Colors.grey,
                                    width: 1.8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.rocket_launch_rounded,
                                    color: AstroviaTheme.white, size: 22),
                                label: Text(
                                  "INITIALIZE LAUNCH COUNTDOWN",
                                  style: AstroviaTheme.orbitron(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                onPressed: isFlightReady
                                    ? () {
                                        AudioService.instance.playTransition();
                                        Navigator.pushReplacement(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (ctx, a1, a2) =>
                                                ScreenLaunchFlight(
                                                    mission: mission),
                                            transitionsBuilder:
                                                (ctx, a1, a2, child) =>
                                                    FadeTransition(
                                                        opacity: a1,
                                                        child: child),
                                            transitionDuration:
                                                const Duration(milliseconds: 700),
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
