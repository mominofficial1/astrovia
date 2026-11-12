import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../models/spacecraft_model.dart';

class FlightTelemetry {
  double altitudeMeters;
  double downrangeMeters;
  double verticalSpeedMs;
  double horizontalSpeedMs;
  double pitchDegrees; // 0 = straight up (radial out), 90 = prograde horizontal
  double throttle; // 0.0 to 1.0
  double fuelRemaining; // 0.0 to 1.0
  double powerRemaining; // 0.0 to 1.0
  double hullIntegrity; // 0.0 to 1.0
  bool isEngineFiring;
  bool isRcsFiring;
  bool sasEnabled; // Stability Augmentation System
  bool landingGearExtended;
  int currentStage;
  bool isLandedSafely;
  bool isCrashed;
  String flightStatusText;

  FlightTelemetry({
    this.altitudeMeters = 1500.0,
    this.downrangeMeters = 0.0,
    this.verticalSpeedMs = -18.0,
    this.horizontalSpeedMs = 0.0,
    this.pitchDegrees = 0.0,
    this.throttle = 0.0,
    this.fuelRemaining = 0.85,
    this.powerRemaining = 0.95,
    this.hullIntegrity = 1.0,
    this.isEngineFiring = false,
    this.isRcsFiring = false,
    this.sasEnabled = true,
    this.landingGearExtended = true,
    this.currentStage = 1,
    this.isLandedSafely = false,
    this.isCrashed = false,
    this.flightStatusText = "DESCENT TRAJECTORY ACTIVE",
  });

  double get totalSpeedMs =>
      math.sqrt((verticalSpeedMs * verticalSpeedMs) + (horizontalSpeedMs * horizontalSpeedMs));
}

class FlightPhysicsController extends ChangeNotifier {
  final SpacecraftBuild spacecraft;
  final MissionModel mission;
  late FlightTelemetry telemetry;

  Timer? _physicsTimer;
  VoidCallback? onSafeLanding;
  Function(String reason)? onFlightFailed;
  Function(String checkpoint)? onCheckpointReached;

  FlightPhysicsController({
    required this.spacecraft,
    required this.mission,
    this.onSafeLanding,
    this.onFlightFailed,
    this.onCheckpointReached,
  }) {
    // Initialize starting conditions based on mission mode
    final isAscent = mission.levelNumber == 1 || mission.levelNumber == 6;
    telemetry = FlightTelemetry(
      altitudeMeters: isAscent ? 50.0 : 2800.0,
      verticalSpeedMs: isAscent ? 2.0 : -32.0,
      pitchDegrees: 0.0,
      throttle: isAscent ? 1.0 : 0.0,
      landingGearExtended: !isAscent,
      flightStatusText: isAscent ? "ASCENT FLIGHT ACTIVE" : "APPROACH & DESCENT ACTIVE",
    );
  }

  void startSimulation() {
    _physicsTimer?.cancel();
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      _tick(0.033);
    });
  }

  void stopSimulation() {
    _physicsTimer?.cancel();
    _physicsTimer = null;
  }

  void setThrottle(double value) {
    if (telemetry.isLandedSafely || telemetry.isCrashed) return;
    if (telemetry.fuelRemaining <= 0.0) {
      telemetry.throttle = 0.0;
      telemetry.isEngineFiring = false;
      notifyListeners();
      return;
    }
    telemetry.throttle = value.clamp(0.0, 1.0);
    telemetry.isEngineFiring = telemetry.throttle > 0.05;
    notifyListeners();
  }

  void adjustPitch(double deltaDeg) {
    if (telemetry.isLandedSafely || telemetry.isCrashed) return;
    telemetry.pitchDegrees = (telemetry.pitchDegrees + deltaDeg).clamp(-85.0, 85.0);
    notifyListeners();
  }

  void fireRcs(bool left) {
    if (telemetry.isLandedSafely || telemetry.isCrashed) return;
    telemetry.isRcsFiring = true;
    telemetry.horizontalSpeedMs += (left ? -1.8 : 1.8);
    telemetry.fuelRemaining = (telemetry.fuelRemaining - 0.002).clamp(0.0, 1.0);
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 150), () {
      telemetry.isRcsFiring = false;
      notifyListeners();
    });
  }

  void toggleSas() {
    telemetry.sasEnabled = !telemetry.sasEnabled;
    notifyListeners();
  }

  void toggleLandingGear() {
    telemetry.landingGearExtended = !telemetry.landingGearExtended;
    notifyListeners();
  }

  void triggerStageSeparation() {
    if (telemetry.currentStage < 3) {
      telemetry.currentStage++;
      telemetry.flightStatusText = "STAGE ${telemetry.currentStage} SEPARATION CONFIRMED";
      onCheckpointReached?.call("stage_separated");
      notifyListeners();
    }
  }

  void _tick(double dt) {
    if (telemetry.isLandedSafely || telemetry.isCrashed) return;

    final gravity = mission.planetaryData.surfaceGravity;

    // SAS auto-attitude dampener
    if (telemetry.sasEnabled && telemetry.pitchDegrees != 0.0) {
      telemetry.pitchDegrees *= 0.96;
      if (telemetry.pitchDegrees.abs() < 0.2) telemetry.pitchDegrees = 0.0;
    }

    // Engine Thrust Acceleration
    double thrustAcc = 0.0;
    if (telemetry.throttle > 0.0 && telemetry.fuelRemaining > 0.0) {
      final totalThrust = spacecraft.totalLiftoffThrustKn * 1000.0; // N
      final mass = spacecraft.totalMassKg;
      final maxAcc = totalThrust / mass; // F = ma -> a = F/m
      // Normalizing for accessible gameplay feel
      final effectiveAcc = (maxAcc * 0.25).clamp(8.0, 32.0);
      thrustAcc = effectiveAcc * telemetry.throttle;

      // Fuel consumption: ~1% per 2.5 seconds at full throttle
      telemetry.fuelRemaining -= (0.004 * telemetry.throttle * dt);
      if (telemetry.fuelRemaining <= 0.0) {
        telemetry.fuelRemaining = 0.0;
        telemetry.throttle = 0.0;
        telemetry.isEngineFiring = false;
        telemetry.flightStatusText = "PROPULSION DEPLETED: BALLISTIC GLIDE";
      }
    }

    // Vector decomposition
    final pitchRad = telemetry.pitchDegrees * (math.pi / 180.0);
    final verticalThrust = thrustAcc * math.cos(pitchRad);
    final horizontalThrust = thrustAcc * math.sin(pitchRad);

    // Gravity acceleration downward
    final netVerticalAcc = verticalThrust - gravity;

    // Atmospheric Drag if planet has atmosphere
    double dragAcc = 0.0;
    if (mission.planetaryData.atmosphericPressure > 0.0 && telemetry.altitudeMeters < 50000) {
      final densityFactor = (1.0 - (telemetry.altitudeMeters / 50000.0)).clamp(0.0, 1.0);
      dragAcc = 0.001 * densityFactor * telemetry.verticalSpeedMs * telemetry.verticalSpeedMs.abs();
    }

    // Update speeds
    telemetry.verticalSpeedMs += (netVerticalAcc - dragAcc) * dt;
    telemetry.horizontalSpeedMs += horizontalThrust * dt;

    // Update positions
    telemetry.altitudeMeters += telemetry.verticalSpeedMs * dt;
    telemetry.downrangeMeters += telemetry.horizontalSpeedMs * dt;

    // Checkpoint altitude checks
    if (mission.levelNumber == 1 && telemetry.altitudeMeters > 3000) {
      onCheckpointReached?.call("reach_orbit");
    }

    // Touchdown or Crash detection
    if (telemetry.altitudeMeters <= 0.0) {
      telemetry.altitudeMeters = 0.0;
      final vSpeed = telemetry.verticalSpeedMs.abs();
      final hSpeed = telemetry.horizontalSpeedMs.abs();
      final pitch = telemetry.pitchDegrees.abs();

      if (vSpeed <= 4.5 && hSpeed <= 2.5 && pitch <= 10.0 && telemetry.landingGearExtended) {
        // Safe Touchdown!
        telemetry.isLandedSafely = true;
        telemetry.verticalSpeedMs = 0.0;
        telemetry.horizontalSpeedMs = 0.0;
        telemetry.throttle = 0.0;
        telemetry.flightStatusText = "TOUCHDOWN CONFIRMED • TOUCHDOWN METRICS NOMINAL";
        stopSimulation();
        notifyListeners();
        onSafeLanding?.call();
      } else {
        // Hard Impact!
        telemetry.isCrashed = true;
        telemetry.verticalSpeedMs = 0.0;
        telemetry.horizontalSpeedMs = 0.0;
        telemetry.hullIntegrity = 0.0;
        telemetry.flightStatusText = vSpeed > 4.5
            ? "CRASH: DESCENT VELOCITY EXCEEDED STRUCTURAL LIMITS (${vSpeed.toStringAsFixed(1)} m/s > 4.5 m/s)"
            : (!telemetry.landingGearExtended
                ? "CRASH: LANDING GEAR WAS NOT EXTENDED"
                : "CRASH: UNSTABLE ATTITUDE AT TOUCHDOWN (${pitch.toStringAsFixed(1)}°)");
        stopSimulation();
        notifyListeners();
        onFlightFailed?.call(telemetry.flightStatusText);
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    stopSimulation();
    super.dispose();
  }
}
