import 'package:flutter/material.dart';
import '../controllers/surface_exploration_controller.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';

class DevDiagnosticsOverlay extends StatelessWidget {
  final SurfaceExplorationController controller;
  final VoidCallback onClose;

  const DevDiagnosticsOverlay({
    super.key,
    required this.controller,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final state = MissionState.instance;
    final mission = controller.mission;
    final validation = state.validateMissionSuccess();

    final rawIn = controller.rawInputVector;
    final normIn = controller.normalizedMovementVector;
    final pos = controller.playerWorldPos;
    final vel = controller.playerVelocity;
    final nearest = controller.nearestEntity;
    final dist = controller.nearestDistance;

    final bagMass = state.bag.currentMassKg;
    final bagCap = state.bag.maxCapacityKg;
    final vaultMass = state.activeVehicleStorage.fold<double>(
        0.0, (sum, item) => sum + item.massKg);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
        decoration: BoxDecoration(
          color: const Color(0xEE0B1220),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: validation.isValid ? AstroviaTheme.green : AstroviaTheme.cyan,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (validation.isValid ? AstroviaTheme.green : AstroviaTheme.cyan)
                  .withValues(alpha: 0.25),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AstroviaTheme.panel.withValues(alpha: 0.8),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                border: const Border(
                  bottom: BorderSide(color: AstroviaTheme.cyan, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bug_report_rounded,
                      color: AstroviaTheme.cyan, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "ASTRAVIA DIAGNOSTICS & TELEMETRY",
                      style: AstroviaTheme.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AstroviaTheme.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(Icons.close_rounded,
                          color: AstroviaTheme.secondary, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // 1. Attempt ID & Mission Phase
                  _buildSectionTitle("1. ATTEMPT & PHASE STATE"),
                  _buildRow("Attempt ID", state.currentAttemptId.isNotEmpty
                      ? state.currentAttemptId
                      : "NONE (Unregistered)"),
                  _buildRow("Mission Phase", state.currentPhase.name.toUpperCase()),
                  _buildRow("Control Mode", state.currentControlMode.name.toUpperCase()),
                  _buildRow("Mission Destination", mission.destinationName),

                  const SizedBox(height: 10),
                  // 2. Spatial & Movement Telemetry
                  _buildSectionTitle("2. KINEMATICS & INPUT PIPELINE"),
                  _buildRow(
                      "Raw Input (dx, dy)",
                      "[${rawIn.dx.toStringAsFixed(2)}, ${rawIn.dy.toStringAsFixed(2)}]"),
                  _buildRow(
                      "Normalized Vector",
                      "[${normIn.dx.toStringAsFixed(2)}, ${normIn.dy.toStringAsFixed(2)}]"),
                  _buildRow("World Pos (X, Y)",
                      "[${pos.dx.toStringAsFixed(1)}, ${pos.dy.toStringAsFixed(1)}]"),
                  _buildRow("Velocity (dx, dy)",
                      "[${vel.dx.toStringAsFixed(2)}, ${vel.dy.toStringAsFixed(2)}]"),
                  _buildRow("Grounded Status",
                      controller.isGrounded ? "TRUE (Surface Plane)" : "FALSE (Airborne Jump)"),
                  _buildRow("Vertical Offset",
                      "${controller.jumpVerticalOffset.toStringAsFixed(2)} m (g=${mission.planetaryData.surfaceGravity} m/s²)"),
                  _buildRow("Active Collider",
                      "Lander Box [-222.5 to -137.5, 7.5 to 72.5]"),

                  const SizedBox(height: 10),
                  // 3. Entity & Consumable Telemetry
                  _buildSectionTitle("3. PROXIMITY & LIFE-SUPPORT"),
                  _buildRow("Nearest Entity",
                      nearest != null ? "${nearest.name} [${nearest.id}]" : "None"),
                  _buildRow("Distance to Nearest",
                      dist < 9000 ? "${dist.toStringAsFixed(1)} px (Radius ${nearest?.radius ?? 0})" : "N/A"),
                  _buildRow("Airlock Hatch",
                      controller.isLanderHatchOpen ? "OPEN / EQUALIZED" : "SEALED"),
                  _buildRow("Astronaut Location",
                      controller.isAstronautOutside ? "OUTSIDE ON SURFACE" : "INSIDE CABIN"),
                  _buildRow("Oxygen Consumable",
                      "${(controller.oxygenLevel * 100).toStringAsFixed(1)}%"),
                  _buildRow("Sample Backpack",
                      "${bagMass.toStringAsFixed(1)} / ${bagCap.toStringAsFixed(1)} kg (${state.bag.items.length} items)"),
                  _buildRow("Lander Vault Storage",
                      "${vaultMass.toStringAsFixed(1)} kg (${state.activeVehicleStorage.length} items)"),

                  const SizedBox(height: 10),
                  // 4. Objective Checklist with Verified Evidence
                  _buildSectionTitle("4. OBJECTIVE VALIDATION CHECKLIST"),
                  ...mission.objectives.map((obj) {
                    final isComplete = state.isObjectiveCompleted(obj.key);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isComplete
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 14,
                            color: isComplete
                                ? AstroviaTheme.green
                                : (obj.isOptional
                                    ? AstroviaTheme.secondary
                                    : AstroviaTheme.gold),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: AstroviaTheme.rajdhani(
                                  fontSize: 11,
                                  color: isComplete
                                      ? AstroviaTheme.white
                                      : AstroviaTheme.secondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: "${obj.key}: ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AstroviaTheme.cyan),
                                  ),
                                  TextSpan(text: obj.description),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  // 5. Success Readiness Status
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: validation.isValid
                          ? AstroviaTheme.green.withValues(alpha: 0.15)
                          : AstroviaTheme.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: validation.isValid
                            ? AstroviaTheme.green
                            : AstroviaTheme.red,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              validation.isValid
                                  ? Icons.verified_rounded
                                  : Icons.block_rounded,
                              size: 16,
                              color: validation.isValid
                                  ? AstroviaTheme.green
                                  : AstroviaTheme.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              validation.isValid
                                  ? "SUCCESS READINESS: READY"
                                  : "SUCCESS READINESS: BLOCKED",
                              style: AstroviaTheme.orbitron(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: validation.isValid
                                    ? AstroviaTheme.green
                                    : AstroviaTheme.red,
                              ),
                            ),
                          ],
                        ),
                        if (!validation.isValid) ...[
                          const SizedBox(height: 4),
                          Text(
                            validation.failureReason,
                            style: AstroviaTheme.rajdhani(
                              fontSize: 11,
                              color: AstroviaTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: AstroviaTheme.orbitron(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AstroviaTheme.gold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: AstroviaTheme.rajdhani(
                fontSize: 11,
                color: AstroviaTheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AstroviaTheme.rajdhani(
                fontSize: 11,
                color: AstroviaTheme.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
