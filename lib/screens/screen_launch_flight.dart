import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/flight_physics_controller.dart';
import '../models/mission_model.dart';
import '../rendering/planetary_environment_renderer.dart';
import '../rendering/spacecraft_renderer.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import 'screen_08_planetary_exploration.dart';
import 'screen_10_mission_results.dart';

class ScreenLaunchFlight extends StatefulWidget {
  final MissionModel mission;

  const ScreenLaunchFlight({
    super.key,
    required this.mission,
  });

  @override
  State<ScreenLaunchFlight> createState() => _ScreenLaunchFlightState();
}

class _ScreenLaunchFlightState extends State<ScreenLaunchFlight> {
  // Countdown phase
  bool _isCountdownActive = true;
  int _countdownSeconds = 10;
  Timer? _countdownTimer;

  // Flight simulation
  late FlightPhysicsController _flightController;

  @override
  void initState() {
    super.initState();
    final spacecraft = MissionState.instance.activeSpacecraft;

    _flightController = FlightPhysicsController(
      spacecraft: spacecraft,
      mission: widget.mission,
      onSafeLanding: _onSafeTouchdown,
      onFlightFailed: _onFlightFailed,
      onCheckpointReached: _onCheckpoint,
    );

    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _flightController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    AudioService.instance.playCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdownSeconds > 1) {
        setState(() {
          _countdownSeconds--;
        });
        AudioService.instance.playCountdown();
      } else {
        timer.cancel();
        _igniteAndLaunch();
      }
    });
  }

  void _cancelCountdown() {
    AudioService.instance.playClick();
    _countdownTimer?.cancel();
    Navigator.pop(context);
  }

  void _igniteAndLaunch() {
    AudioService.instance.playSuccess();
    setState(() {
      _isCountdownActive = false;
    });
    _flightController.startSimulation();
  }

  void _onCheckpoint(String checkpoint) {
    if (checkpoint == "reach_orbit") {
      MissionState.instance.completeObjective("reach_orbit");
      MissionState.instance.completeObjective("reach_hst_orbit");
      MissionState.instance.completeObjective("orbital_recon");
    }
  }

  void _onSafeTouchdown() {
    AudioService.instance.playSuccess();
    MissionState.instance.completeObjective("soft_landing");
    MissionState.instance.completeObjective("precision_touchdown");
    MissionState.instance.completeObjective("martian_edl_landing");
    MissionState.instance.completeObjective("rendezvous_berth");
    MissionState.instance.completeObjective("docking_capture");

    // Show touchdown notification and allow vehicle exit
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AstroviaTheme.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AstroviaTheme.green, width: 1.5),
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AstroviaTheme.green, size: 48),
              const SizedBox(height: 12),
              Text(
                "TOUCHDOWN CONFIRMED!",
                style: AstroviaTheme.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Spacecraft has safely reached destination on ${widget.mission.destinationName}. Airlock status: Equalized.",
                textAlign: TextAlign.center,
                style: AstroviaTheme.rajdhani(
                  fontSize: 13,
                  color: AstroviaTheme.white,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AstroviaTheme.cyan.withValues(alpha: 0.3),
                  side: const BorderSide(color: AstroviaTheme.cyan),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.sensor_door_rounded,
                    color: AstroviaTheme.cyan),
                label: Text(
                  "OPEN AIRLOCK & EGRESS ASTRONAUT",
                  style: AstroviaTheme.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AstroviaTheme.white,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  MissionState.instance.completeObjective("open_hatch_exit");
                  MissionState.instance.completeObjective("airlock_depress_eva");
                  MissionState.instance.completeObjective("astronaut_egress_mars");
                  MissionState.instance.completeObjective("exit_assembly_eva");

                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, a1, a2) =>
                          const Screen08PlanetaryExploration(),
                      transitionsBuilder: (context, a1, a2, child) =>
                          FadeTransition(opacity: a1, child: child),
                      transitionDuration: const Duration(milliseconds: 700),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onFlightFailed(String reason) {
    AudioService.instance.playScan();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AstroviaTheme.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AstroviaTheme.red, width: 1.5),
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.report_problem_rounded,
                  color: AstroviaTheme.red, size: 48),
              const SizedBox(height: 12),
              Text(
                "MISSION FAILED • VEHICLE LOSS",
                style: AstroviaTheme.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: AstroviaTheme.inter(
                  fontSize: 12,
                  color: AstroviaTheme.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "ABORT TO MISSION CONTROL",
                      style: AstroviaTheme.rajdhani(
                        color: AstroviaTheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AstroviaTheme.cyan.withValues(alpha: 0.3),
                      side: const BorderSide(color: AstroviaTheme.cyan),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      // Clean restart
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, a1, a2) =>
                              ScreenLaunchFlight(mission: widget.mission),
                          transitionsBuilder: (context, a1, a2, child) =>
                              FadeTransition(opacity: a1, child: child),
                        ),
                      );
                    },
                    child: Text(
                      "RETRY FLIGHT",
                      style: AstroviaTheme.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AstroviaTheme.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final telem = _flightController.telemetry;

    final isOrbitalMode = widget.mission.gameplayMode == MissionGameplayMode.orbitalFlight ||
        widget.mission.gameplayMode == MissionGameplayMode.orbitalDeployment ||
        widget.mission.gameplayMode == MissionGameplayMode.zeroGravityEva ||
        widget.mission.gameplayMode == MissionGameplayMode.roboticConsole;

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: PlanetaryEnvironmentWidget(
        planetaryData: widget.mission.planetaryData,
        levelNumber: widget.mission.levelNumber,
        isOrbital: isOrbitalMode,
        cameraOffset: Offset(telem.horizontalSpeedMs * 2.0, -telem.verticalSpeedMs),
        animationTime: DateTime.now().millisecondsSinceEpoch / 1000.0,
        child: SafeArea(
          child: Stack(
            children: [
              // 1. Central Flight Spacecraft Canvas
              if (!_isCountdownActive)
                Center(
                  child: AnimatedBuilder(
                    animation: _flightController,
                    builder: (ctx, child) {
                      return Transform.rotate(
                        angle: telem.pitchDegrees * (3.14159 / 180.0),
                        child: SpacecraftWidget(
                          buildData: _flightController.spacecraft,
                          throttle: telem.throttle,
                          isRcsFiring: telem.isRcsFiring,
                          landingLegsExtended: telem.landingGearExtended,
                          scale: 1.1,
                          missionLevel: widget.mission.levelNumber,
                        ),
                      );
                    },
                  ),
                ),

              // 2. Audible / Visual T-Minus 10s Countdown Overlay
              if (_isCountdownActive)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 28),
                    decoration: BoxDecoration(
                      color: AstroviaTheme.panelTranslucent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AstroviaTheme.cyan, width: 2.0),
                      boxShadow: AstroviaTheme.cyanGlowShadow,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "TERMINAL COUNTDOWN SEQUENCE",
                          style: AstroviaTheme.orbitron(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AstroviaTheme.cyan,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "T-${_countdownSeconds.toString().padLeft(2, '0')}",
                          style: AstroviaTheme.orbitron(
                            fontSize: 54,
                            fontWeight: FontWeight.w900,
                            color: AstroviaTheme.gold,
                            letterSpacing: 4.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "TARGET: ${widget.mission.destinationName}",
                          style: AstroviaTheme.rajdhani(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AstroviaTheme.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AstroviaTheme.red.withValues(alpha: 0.3),
                            side: const BorderSide(color: AstroviaTheme.red),
                          ),
                          icon: const Icon(Icons.cancel_rounded,
                              color: AstroviaTheme.red),
                          label: Text(
                            "ABORT COUNTDOWN",
                            style: AstroviaTheme.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AstroviaTheme.white,
                            ),
                          ),
                          onPressed: _cancelCountdown,
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. Top Flight Telemetry Bar
              if (!_isCountdownActive)
                Positioned(
                  top: 12,
                  left: 20,
                  right: 20,
                  child: AnimatedBuilder(
                    animation: _flightController,
                    builder: (ctx, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AstroviaTheme.panelTranslucent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AstroviaTheme.cyan.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.mission.title,
                                  style: AstroviaTheme.orbitron(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.white,
                                  ),
                                ),
                                Text(
                                  telem.flightStatusText,
                                  style: AstroviaTheme.rajdhani(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.cyan,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildTelemValue("ALTITUDE",
                                    "${telem.altitudeMeters.toStringAsFixed(0)} M"),
                                const SizedBox(width: 14),
                                _buildTelemValue(
                                  "VERT SPEED",
                                  "${telem.verticalSpeedMs.toStringAsFixed(1)} M/S",
                                  isWarning:
                                      telem.verticalSpeedMs.abs() > 4.5 &&
                                          telem.altitudeMeters < 100,
                                ),
                                const SizedBox(width: 14),
                                _buildTelemValue("PITCH",
                                    "${telem.pitchDegrees.toStringAsFixed(1)}°"),
                                const SizedBox(width: 14),
                                _buildTelemValue("FUEL",
                                    "${(telem.fuelRemaining * 100).toInt()}%"),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              // 4. Bottom Flight Controls (Desktop & Touch HUD)
              if (!_isCountdownActive)
                Positioned(
                  bottom: 16,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Throttle Control Slider & Ignition
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AstroviaTheme.panelTranslucent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AstroviaTheme.cyan.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.speed_rounded,
                                color: AstroviaTheme.cyan, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "THROTTLE",
                              style: AstroviaTheme.orbitron(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.cyan,
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: Slider(
                                value: telem.throttle,
                                activeColor: AstroviaTheme.cyan,
                                inactiveColor: AstroviaTheme.darkSpace,
                                onChanged: (val) {
                                  _flightController.setThrottle(val);
                                },
                              ),
                            ),
                            Text(
                              "${(telem.throttle * 100).toInt()}%",
                              style: AstroviaTheme.orbitron(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Pitch & RCS Translation buttons
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.rotate_left_rounded,
                                color: AstroviaTheme.cyan, size: 28),
                            onPressed: () =>
                                _flightController.adjustPitch(-5.0),
                          ),
                          IconButton(
                            icon: const Icon(Icons.rotate_right_rounded,
                                color: AstroviaTheme.cyan, size: 28),
                            onPressed: () =>
                                _flightController.adjustPitch(5.0),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: telem.sasEnabled
                                  ? AstroviaTheme.cyan.withValues(alpha: 0.3)
                                  : AstroviaTheme.panel,
                              side: const BorderSide(color: AstroviaTheme.cyan),
                            ),
                            onPressed: _flightController.toggleSas,
                            child: Text(
                              "SAS: ${telem.sasEnabled ? 'ON' : 'OFF'}",
                              style: AstroviaTheme.orbitron(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: telem.landingGearExtended
                                  ? AstroviaTheme.gold.withValues(alpha: 0.3)
                                  : AstroviaTheme.panel,
                              side: const BorderSide(color: AstroviaTheme.gold),
                            ),
                            onPressed: _flightController.toggleLandingGear,
                            child: Text(
                              "GEAR: ${telem.landingGearExtended ? 'DOWN' : 'UP'}",
                              style: AstroviaTheme.orbitron(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.gold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Quick skip/advance for orbital trajectory in training
                          if (widget.mission.levelNumber == 1)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AstroviaTheme.green.withValues(alpha: 0.25),
                                side:
                                    const BorderSide(color: AstroviaTheme.green),
                              ),
                              onPressed: () {
                                MissionState.instance
                                    .completeObjective("lunar_injection");
                                MissionState.instance
                                    .completeObjective("earthrise_photo");
                                MissionState.instance
                                    .completeObjective("return_burn");
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, a1, a2) =>
                                        const Screen10MissionResults(),
                                  ),
                                );
                              },
                              child: Text(
                                "EARTHRISE OBSERVED ►",
                                style: AstroviaTheme.orbitron(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.green,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemValue(String label, String value,
      {bool isWarning = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: AstroviaTheme.rajdhani(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isWarning ? AstroviaTheme.red : AstroviaTheme.secondary,
          ),
        ),
        Text(
          value,
          style: AstroviaTheme.orbitron(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isWarning ? AstroviaTheme.red : AstroviaTheme.white,
          ),
        ),
      ],
    );
  }
}

