import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/surface_exploration_controller.dart';
import '../models/mission_model.dart';
import '../rendering/astronaut_renderer.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import 'screen_equipment_inventory.dart';
import 'screen_10_mission_results.dart';

class Screen08PlanetaryExploration extends StatefulWidget {
  const Screen08PlanetaryExploration({super.key});

  @override
  State<Screen08PlanetaryExploration> createState() =>
      _Screen08PlanetaryExplorationState();
}

class _Screen08PlanetaryExplorationState
    extends State<Screen08PlanetaryExploration> {
  late SurfaceExplorationController _controller;
  Offset _joystickKnob = Offset.zero;
  bool _isPaused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final mission = MissionState.instance.currentMission ??
        MissionModel.allMissions[1]; // Apollo 11 default
    final profile = MissionState.instance.saveData.playerProfile;

    _controller = SurfaceExplorationController(
      mission: mission,
      astronautProfile: profile,
      onOxygenDepleted: _onOxygenDepleted,
      onMissionAlert: (alert) {
        MissionState.instance.setMissionAlert(alert);
      },
    );

    _controller.startExploration();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onOxygenDepleted() {
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
              const Icon(Icons.warning_amber_rounded,
                  color: AstroviaTheme.red, size: 48),
              const SizedBox(height: 12),
              Text(
                "MISSION FAILED: OXYGEN EXHAUSTED",
                style: AstroviaTheme.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Astronaut suit life-support oxygen reserves were depleted before returning to the vehicle airlock. Non-graphic emergency retrieval enacted.",
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
                      "RETURN TO MISSION CONTROL",
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
                      // Reset consumables and restart cleanly
                      MissionState.instance.resetMission();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, a1, a2) =>
                              const Screen08PlanetaryExploration(),
                        ),
                      );
                    },
                    child: Text(
                      "RETRY EVA",
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

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyE) {
        _handleInteract();
      } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
        _handleCollect();
      } else if (event.logicalKey == LogicalKeyboardKey.keyB ||
          event.logicalKey == LogicalKeyboardKey.keyI) {
        _openBag();
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _controller.triggerJump();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _togglePause();
      }
    }

    // Directional keys check
    double dx = 0.0;
    double dy = 0.0;
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    if (keys.contains(LogicalKeyboardKey.keyW) ||
        keys.contains(LogicalKeyboardKey.arrowUp)) {
      dy -= 1.0;
    }
    if (keys.contains(LogicalKeyboardKey.keyS) ||
        keys.contains(LogicalKeyboardKey.arrowDown)) {
      dy += 1.0;
    }
    if (keys.contains(LogicalKeyboardKey.keyA) ||
        keys.contains(LogicalKeyboardKey.arrowLeft)) {
      dx -= 1.0;
    }
    if (keys.contains(LogicalKeyboardKey.keyD) ||
        keys.contains(LogicalKeyboardKey.arrowRight)) {
      dx += 1.0;
    }

    final isShift = keys.contains(LogicalKeyboardKey.shiftLeft) ||
        keys.contains(LogicalKeyboardKey.shiftRight);

    final dir = (dx != 0.0 || dy != 0.0) ? Offset(dx, dy) : Offset.zero;
    _controller.setMovementVector(dir, running: isShift);
  }

  void _updateJoystick(Offset localPosition, double radius) {
    final center = Offset(radius, radius);
    final delta = localPosition - center;
    final dist = delta.distance;

    Offset clamped;
    if (dist > radius * 0.7) {
      clamped = Offset.fromDirection(delta.direction, radius * 0.7);
    } else {
      clamped = delta;
    }

    setState(() {
      _joystickKnob = clamped;
    });

    if (clamped == Offset.zero) {
      _controller.setMovementVector(Offset.zero);
    } else {
      final dir = Offset(clamped.dx / (radius * 0.7), clamped.dy / (radius * 0.7));
      _controller.setMovementVector(dir, running: dist > radius * 0.5);
    }
  }

  void _handleInteract() {
    AudioService.instance.playClick();
    _controller.interactWithNearest();
  }

  void _handleCollect() {
    AudioService.instance.playClick();
    _controller.collectNearestSample();
  }

  void _openBag() {
    AudioService.instance.playClick();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, a1, a2) => const ScreenEquipmentInventory(),
        transitionsBuilder: (ctx, a1, a2, child) =>
            FadeTransition(opacity: a1, child: child),
      ),
    );
  }

  void _togglePause() {
    AudioService.instance.playClick();
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _controller.stopExploration();
      } else {
        _controller.startExploration();
      }
    });
  }

  void _finishMissionAndReturn() {
    AudioService.instance.playSuccess();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, a1, a2) => const Screen10MissionResults(),
        transitionsBuilder: (ctx, a1, a2, child) =>
            FadeTransition(opacity: a1, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = MissionState.instance;
    final mission = _controller.mission;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AstroviaTheme.darkSpace,
        body: AstroviaVideoBackground(
          videoAsset: mission.defaultVideoAsset,
          overlayOpacity: 0.35,
          child: SafeArea(
            child: Stack(
              children: [
                // 1. World Layer: Interactable Entities & Samples
                AnimatedBuilder(
                  animation: _controller,
                  builder: (ctx, child) {
                    final pPos = _controller.playerWorldPos;
                    final size = MediaQuery.of(context).size;
                    final screenCenter = Offset(size.width / 2, size.height / 2);

                    return Stack(
                      children: [
                        // Lander Spacecraft in the world
                        Positioned(
                          left: screenCenter.dx +
                              (_controller.landerWorldPos.dx - pPos.dx) -
                              50,
                          top: screenCenter.dy +
                              (_controller.landerWorldPos.dy - pPos.dy) -
                              80,
                          child: _buildLanderWorldObject(),
                        ),

                        // Rover in the world if deployed
                        if (_controller.isRoverDeployed &&
                            !_controller.isRoverMounted)
                          Positioned(
                            left: screenCenter.dx +
                                (_controller.roverWorldPos.dx - pPos.dx) -
                                30,
                            top: screenCenter.dy +
                                (_controller.roverWorldPos.dy - pPos.dy) -
                                20,
                            child: _buildRoverWorldObject(),
                          ),

                        // Geological Sample Nodes & Science Targets
                        ..._controller.worldEntities
                            .where((e) =>
                                !e.isCollected &&
                                e.category != "vehicle" &&
                                e.category != "rover")
                            .map((entity) {
                          final screenPos = Offset(
                            screenCenter.dx + (entity.position.dx - pPos.dx),
                            screenCenter.dy + (entity.position.dy - pPos.dy),
                          );
                          final isTargetNear =
                              _controller.nearestEntity?.id == entity.id;

                          return Positioned(
                            left: screenPos.dx - 25,
                            top: screenPos.dy - 25,
                            child: _buildWorldEntityWidget(
                                entity, isTargetNear),
                          );
                        }),
                      ],
                    );
                  },
                ),

                // 2. Center Player Astronaut Character (Animated Rig)
                Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (ctx, child) {
                      return Transform.translate(
                        offset: Offset(0, -_controller.jumpVerticalOffset),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Astronaut callsig tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AstroviaTheme.panelGlass,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AstroviaTheme.cyan, width: 0.8),
                              ),
                              child: Text(
                                "${state.astronautName} [EVA]",
                                style: AstroviaTheme.orbitron(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.cyan,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),

                            // Procedural Humanoid Astronaut or Rover
                            if (_controller.isRoverMounted)
                              _buildRoverMountedAvatar()
                            else
                              AstronautAvatarWidget(
                                profile: _controller.astronautProfile,
                                animState: _controller.animState,
                                animPhase: _controller.animPhase,
                                facingRight: _controller.facingRight,
                                scale: 1.25,
                                showHeadlampBeam: true,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 3. Proximity Action Prompt (when near interactable object)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (ctx, child) {
                    final nearest = _controller.nearestEntity;
                    if (nearest == null) return const SizedBox.shrink();

                    return Positioned(
                      top: 76,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: nearest.sampleItem != null
                              ? _handleCollect
                              : _handleInteract,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: AstroviaTheme.gold.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AstroviaTheme.gold, width: 1.8),
                              boxShadow: AstroviaTheme.goldGlowShadow,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.touch_app_rounded,
                                    color: AstroviaTheme.gold, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  "${nearest.name.toUpperCase()} • TAP / PRESS [E / F] TO ${nearest.promptText.toUpperCase()}",
                                  style: AstroviaTheme.orbitron(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.gold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // 4. Top HUD Status Bar
                Positioned(
                  top: 12,
                  left: 20,
                  right: 20,
                  child: AnimatedBuilder(
                    animation: _controller,
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
                                  "LEVEL ${mission.levelNumber} • ${mission.title}",
                                  style: AstroviaTheme.orbitron(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.white,
                                  ),
                                ),
                                Text(
                                  state.missionAlertMessage,
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
                                _buildResourceMeter("OXYGEN",
                                    _controller.oxygenLevel, AstroviaTheme.cyan),
                                const SizedBox(width: 14),
                                _buildResourceMeter("STAMINA",
                                    _controller.stamina, AstroviaTheme.gold),
                                const SizedBox(width: 14),
                                IconButton(
                                  tooltip: "Astronaut Bag",
                                  icon: const Icon(Icons.backpack_rounded,
                                      color: AstroviaTheme.cyan),
                                  onPressed: _openBag,
                                ),
                                IconButton(
                                  tooltip: "Pause",
                                  icon: const Icon(Icons.pause_circle_rounded,
                                      color: AstroviaTheme.secondary),
                                  onPressed: _togglePause,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 5. Ready to Transmit / Return Button (when objectives complete)
                AnimatedBuilder(
                  animation: state,
                  builder: (ctx, child) {
                    if (!state.areAllPrimaryObjectivesCompleted) {
                      return const SizedBox.shrink();
                    }
                    return Positioned(
                      top: 128,
                      right: 20,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AstroviaTheme.green.withValues(alpha: 0.35),
                          side: const BorderSide(
                              color: AstroviaTheme.green, width: 1.5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        icon: const Icon(Icons.rocket_rounded,
                            color: AstroviaTheme.green),
                        label: Text(
                          "ALL OBJECTIVES COMPLETE ► RETURN / SECURE",
                          style: AstroviaTheme.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AstroviaTheme.white,
                          ),
                        ),
                        onPressed: _finishMissionAndReturn,
                      ),
                    );
                  },
                ),

                // 6. Bottom Left: Touch Virtual Joystick
                Positioned(
                  bottom: 16,
                  left: 20,
                  child: _buildVirtualJoystick(),
                ),

                // 7. Bottom Right: Action Touch Buttons (Interact, Collect, Jump, Bag)
                Positioned(
                  bottom: 16,
                  right: 20,
                  child: Row(
                    children: [
                      _buildRoundActionButton(
                        "COLLECT [F]",
                        Icons.science_rounded,
                        AstroviaTheme.gold,
                        _handleCollect,
                      ),
                      const SizedBox(width: 12),
                      _buildRoundActionButton(
                        "INTERACT [E]",
                        Icons.touch_app_rounded,
                        AstroviaTheme.cyan,
                        _handleInteract,
                      ),
                      const SizedBox(width: 12),
                      _buildRoundActionButton(
                        "JUMP [SPACE]",
                        Icons.arrow_upward_rounded,
                        AstroviaTheme.white,
                        _controller.triggerJump,
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

  Widget _buildResourceMeter(String label, double val, Color color) {
    return SizedBox(
      width: 75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AstroviaTheme.rajdhani(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.secondary,
                ),
              ),
              Text(
                "${(val * 100).toInt()}%",
                style: AstroviaTheme.orbitron(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: val.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: AstroviaTheme.darkSpace,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualJoystick() {
    const double radius = 55.0;
    return GestureDetector(
      onPanStart: (details) => _updateJoystick(details.localPosition, radius),
      onPanUpdate: (details) => _updateJoystick(details.localPosition, radius),
      onPanEnd: (_) {
        setState(() => _joystickKnob = Offset.zero);
        _controller.setMovementVector(Offset.zero);
      },
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AstroviaTheme.panelTranslucent,
          border: Border.all(
              color: AstroviaTheme.cyan.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: _joystickKnob,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AstroviaTheme.cyan,
                  boxShadow: [
                    BoxShadow(
                      color: AstroviaTheme.cyan,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.22),
              border: Border.all(color: color, width: 1.8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AstroviaTheme.orbitron(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AstroviaTheme.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLanderWorldObject() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AstroviaTheme.panelGlass,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AstroviaTheme.cyan),
          ),
          child: Text(
            "LANDER AIRLOCK",
            style: AstroviaTheme.orbitron(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AstroviaTheme.cyan,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFCFD8DC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF37474F), width: 2),
          ),
          child: const Center(
            child: Icon(Icons.rocket_rounded,
                size: 48, color: Color(0xFF37474F)),
          ),
        ),
      ],
    );
  }

  Widget _buildRoverWorldObject() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AstroviaTheme.panelGlass,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AstroviaTheme.gold),
          ),
          child: Text(
            "LRV ROVER",
            style: AstroviaTheme.orbitron(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AstroviaTheme.gold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        const Icon(Icons.directions_car_rounded,
            size: 42, color: AstroviaTheme.gold),
      ],
    );
  }

  Widget _buildRoverMountedAvatar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AstroviaTheme.gold.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AstroviaTheme.gold, width: 1.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_car_rounded,
              color: AstroviaTheme.gold, size: 28),
          SizedBox(width: 6),
          Icon(Icons.accessibility_new_rounded,
              color: AstroviaTheme.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildWorldEntityWidget(
      InteractableWorldEntity entity, bool isNear) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isNear
                ? AstroviaTheme.gold.withValues(alpha: 0.3)
                : AstroviaTheme.panelGlass,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isNear ? AstroviaTheme.gold : AstroviaTheme.cyan,
            ),
          ),
          child: Text(
            entity.name,
            style: AstroviaTheme.rajdhani(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isNear ? AstroviaTheme.gold : AstroviaTheme.white,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isNear
                ? AstroviaTheme.gold.withValues(alpha: 0.25)
                : AstroviaTheme.cyan.withValues(alpha: 0.15),
            border: Border.all(
              color: isNear ? AstroviaTheme.gold : AstroviaTheme.cyan,
              width: isNear ? 2.0 : 1.0,
            ),
            boxShadow: isNear ? AstroviaTheme.goldGlowShadow : [],
          ),
          child: Icon(
            entity.category == "sample"
                ? Icons.terrain_rounded
                : Icons.sensors_rounded,
            size: 20,
            color: isNear ? AstroviaTheme.gold : AstroviaTheme.cyan,
          ),
        ),
      ],
    );
  }
}
