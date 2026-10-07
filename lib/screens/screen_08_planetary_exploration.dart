import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import '../widgets/cyber_button.dart';
import 'screen_09_rover_science_mission.dart';

class Screen08PlanetaryExploration extends StatefulWidget {
  const Screen08PlanetaryExploration({super.key});

  @override
  State<Screen08PlanetaryExploration> createState() =>
      _Screen08PlanetaryExplorationState();
}

class _Screen08PlanetaryExplorationState
    extends State<Screen08PlanetaryExploration>
    with SingleTickerProviderStateMixin {
  // Astronaut player coordinate offsets
  Offset _playerOffset = const Offset(-80, 50);
  Offset _joystickKnob = Offset.zero;
  bool _isDraggingJoystick = false;
  bool _facingRight = true;
  double _walkBob = 0.0;

  // Anomaly beacon coordinate
  final Offset _beaconOffset = const Offset(140, -40);
  bool _isNearAnomaly = false;

  Timer? _movementLoopTimer;
  Offset _currentVelocity = Offset.zero;

  @override
  void initState() {
    super.initState();
    // 60fps Game Movement Loop for responsive, game-like player navigation
    _movementLoopTimer =
        Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (_currentVelocity != Offset.zero) {
        setState(() {
          _playerOffset += _currentVelocity;
          // Clamp inside screen bounds
          _playerOffset = Offset(
            _playerOffset.dx.clamp(-260.0, 260.0),
            _playerOffset.dy.clamp(-120.0, 110.0),
          );

          if (_currentVelocity.dx > 0) _facingRight = true;
          if (_currentVelocity.dx < 0) _facingRight = false;

          _walkBob = (_walkBob + 0.3) % 6.28;

          // Check distance to science anomaly beacon
          final distToBeacon = (_playerOffset - _beaconOffset).distance;
          _isNearAnomaly = distToBeacon < 85;
        });
      }
    });
  }

  @override
  void dispose() {
    _movementLoopTimer?.cancel();
    super.dispose();
  }

  void _moveByDirection(Offset direction, {double speed = 12.0}) {
    setState(() {
      _playerOffset += direction * speed;
      _playerOffset = Offset(
        _playerOffset.dx.clamp(-260.0, 260.0),
        _playerOffset.dy.clamp(-120.0, 110.0),
      );
      if (direction.dx > 0) _facingRight = true;
      if (direction.dx < 0) _facingRight = false;

      final distToBeacon = (_playerOffset - _beaconOffset).distance;
      _isNearAnomaly = distToBeacon < 85;
    });
    AudioService.instance.playClick();
  }

  void _updateJoystick(Offset localPosition, double radius) {
    final center = Offset(radius, radius);
    final delta = localPosition - center;
    final dist = delta.distance;

    Offset clampedDelta;
    if (dist > radius * 0.7) {
      clampedDelta = Offset.fromDirection(delta.direction, radius * 0.7);
    } else {
      clampedDelta = delta;
    }

    setState(() {
      _joystickKnob = clampedDelta;
      // Proportional game velocity
      _currentVelocity = Offset(clampedDelta.dx * 0.12, clampedDelta.dy * 0.12);
    });
  }

  void _openRoverMission() {
    AudioService.instance.playScan();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Screen09RoverScienceMission(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showMapModal() {
    AudioService.instance.playClick();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AstroviaTheme.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AstroviaTheme.cyan, width: 1.5),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LUNAR TOPOGRAPHIC SECTOR RADAR",
                style: AstroviaTheme.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.cyan,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 170,
                decoration: BoxDecoration(
                  color: AstroviaTheme.darkSpace,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AstroviaTheme.cyan.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.radar_rounded,
                          size: 48, color: AstroviaTheme.cyan),
                      const SizedBox(height: 8),
                      Text(
                        "SECTOR A-09: SOUTH POLE CRATER",
                        style: AstroviaTheme.orbitron(
                          color: AstroviaTheme.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "COMMANDER: ${MissionState.instance.astronautName}",
                        style: AstroviaTheme.rajdhani(
                          color: AstroviaTheme.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: CyberButton(
                  label: "CLOSE RADAR",
                  variant: CyberButtonVariant.transparent,
                  minWidth: 120,
                  height: 40,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final distToBeacon = (_playerOffset - _beaconOffset).distance.toInt();

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: AstroviaVideoBackground(
        videoAsset: 'assets/videos/lunar_exploration.mp4',
        overlayOpacity: 0.28,
        loop: true,
        showMuteButton: true,
        child: SafeArea(
          child: Stack(
            children: [
              // Interactive World Layer (Objective Beacon)
              Center(
                child: Transform.translate(
                  offset: _beaconOffset,
                  child: _buildAnomalyBeacon(),
                ),
              ),

              // Interactive Player Character (Astronaut Avatar with dynamic walk bob and facing)
              Center(
                child: Transform.translate(
                  offset: Offset(
                    _playerOffset.dx,
                    _playerOffset.dy +
                        (_currentVelocity != Offset.zero
                            ? (4 * (1.0 + (_walkBob % 3.14 - 1.57).abs()))
                            : 0.0),
                  ),
                  child: _buildAstronautAvatar(),
                ),
              ),

              // HUD Layer: Top Bar
              Positioned(
                top: 12,
                left: 20,
                right: 20,
                child: _buildTopHud(distToBeacon),
              ),

              // Proximity Notification Alert
              if (_isNearAnomaly)
                Positioned(
                  top: 76,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _openRoverMission,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
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
                            const Icon(Icons.warning_amber_rounded,
                                color: AstroviaTheme.gold, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "ANOMALY LOCATED • TAP TO DEPLOY ROVER ►",
                              style: AstroviaTheme.orbitron(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.gold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Bottom Left: Dual Control Hub (Virtual Joystick + Game D-Pad Buttons)
              Positioned(
                bottom: 16,
                left: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildVirtualJoystick(),
                    const SizedBox(width: 14),
                    _buildDirectionalDpad(),
                  ],
                ),
              ),

              // Bottom Right: Action Buttons
              Positioned(
                bottom: 16,
                right: 20,
                child: _buildActionButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHud(int distToBeacon) {
    final state = MissionState.instance;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AstroviaTheme.panelTranslucent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AstroviaTheme.cyan.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Left: MISSION 01 / LUNAR DISCOVERY
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MISSION 01 • PILOT: ${state.astronautName}",
                style: AstroviaTheme.rajdhani(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.cyan,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "LUNAR DISCOVERY",
                style: AstroviaTheme.orbitron(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          // Top Center: OBJECTIVE + Realtime Distance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AstroviaTheme.panelGlass,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _isNearAnomaly
                      ? AstroviaTheme.gold
                      : AstroviaTheme.cyan.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.explore_rounded,
                    color:
                        _isNearAnomaly ? AstroviaTheme.gold : AstroviaTheme.cyan,
                    size: 16),
                const SizedBox(width: 8),
                Text(
                  "OBJECTIVE: REACH CRATER ANOMALY [${distToBeacon}M]",
                  style: AstroviaTheme.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AstroviaTheme.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Top Right: OXYGEN, ENERGY, MISSION TIME
          Row(
            children: [
              _buildTopStat("OXYGEN", 0.92, AstroviaTheme.cyan),
              const SizedBox(width: 14),
              _buildTopStat("ENERGY", 0.84, AstroviaTheme.gold),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "MISSION TIME",
                    style: AstroviaTheme.rajdhani(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.secondary,
                    ),
                  ),
                  Text(
                    "08:42",
                    style: AstroviaTheme.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopStat(String label, double val, Color color) {
    return SizedBox(
      width: 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AstroviaTheme.rajdhani(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AstroviaTheme.secondary,
            ),
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: val,
              minHeight: 5,
              backgroundColor: AstroviaTheme.panel,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAstronautAvatar() {
    final state = MissionState.instance;

    return Transform.scale(
      scaleX: _facingRight ? 1.0 : -1.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name tag & life support indicator
          Transform.scale(
            scaleX: _facingRight ? 1.0 : -1.0, // keep text un-flipped
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AstroviaTheme.panelTranslucent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AstroviaTheme.cyan, width: 0.8),
              ),
              child: Text(
                "${state.astronautName} [EVA]",
                style: AstroviaTheme.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.cyan,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AstroviaTheme.panelGlass,
              border: Border.all(
                color: _isNearAnomaly ? AstroviaTheme.gold : AstroviaTheme.cyan,
                width: 2,
              ),
              boxShadow: _isNearAnomaly
                  ? AstroviaTheme.goldGlowShadow
                  : AstroviaTheme.cyanGlowShadow,
            ),
            child: const Icon(
              Icons.accessibility_new_rounded,
              size: 36,
              color: AstroviaTheme.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomalyBeacon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AstroviaTheme.gold.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AstroviaTheme.gold, width: 1),
          ),
          child: Text(
            "LUNAR OBJECTIVE",
            style: AstroviaTheme.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AstroviaTheme.gold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AstroviaTheme.gold.withValues(alpha: 0.2),
            border: Border.all(color: AstroviaTheme.gold, width: 2),
            boxShadow: AstroviaTheme.goldGlowShadow,
          ),
          child: const Icon(
            Icons.location_searching_rounded,
            color: AstroviaTheme.gold,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildVirtualJoystick() {
    const double radius = 50.0;
    return GestureDetector(
      onPanStart: (details) {
        setState(() => _isDraggingJoystick = true);
        _updateJoystick(details.localPosition, radius);
      },
      onPanUpdate: (details) {
        _updateJoystick(details.localPosition, radius);
      },
      onPanEnd: (_) {
        setState(() {
          _isDraggingJoystick = false;
          _joystickKnob = Offset.zero;
          _currentVelocity = Offset.zero;
        });
      },
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AstroviaTheme.panelTranslucent.withValues(alpha: 0.75),
          border: Border.all(
            color: _isDraggingJoystick
                ? AstroviaTheme.cyan
                : AstroviaTheme.cyan.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Transform.translate(
            offset: _joystickKnob,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AstroviaTheme.cyan.withValues(alpha: 0.4),
                border: Border.all(color: AstroviaTheme.cyan, width: 2),
                boxShadow: AstroviaTheme.cyanGlowShadow,
              ),
              child: const Icon(
                Icons.navigation_rounded,
                color: AstroviaTheme.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Interactive Game D-Pad Buttons (UP, DOWN, LEFT, RIGHT)
  Widget _buildDirectionalDpad() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AstroviaTheme.panelTranslucent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AstroviaTheme.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDpadBtn(
              Icons.arrow_upward_rounded, const Offset(0, -1), "UP"),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDpadBtn(
                  Icons.arrow_back_rounded, const Offset(-1, 0), "LEFT"),
              const SizedBox(width: 28),
              _buildDpadBtn(
                  Icons.arrow_forward_rounded, const Offset(1, 0), "RIGHT"),
            ],
          ),
          _buildDpadBtn(
              Icons.arrow_downward_rounded, const Offset(0, 1), "DOWN"),
        ],
      ),
    );
  }

  Widget _buildDpadBtn(IconData icon, Offset dir, String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _moveByDirection(dir),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 34,
          height: 32,
          decoration: BoxDecoration(
            color: AstroviaTheme.panelGlass,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AstroviaTheme.cyan.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, color: AstroviaTheme.cyan, size: 18),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHudActionButton(
          label: "MOVE",
          icon: Icons.directions_walk_rounded,
          onTap: () => _moveByDirection(const Offset(1, 0)),
        ),
        const SizedBox(width: 12),
        _buildHudActionButton(
          label: "SCAN",
          icon: Icons.radar_rounded,
          isHighlight: _isNearAnomaly,
          onTap: _openRoverMission,
        ),
        const SizedBox(width: 12),
        _buildHudActionButton(
          label: "INTERACT",
          icon: Icons.touch_app_rounded,
          isHighlight: _isNearAnomaly,
          onTap: _openRoverMission,
        ),
        const SizedBox(width: 12),
        _buildHudActionButton(
          label: "MAP",
          icon: Icons.map_rounded,
          onTap: _showMapModal,
        ),
      ],
    );
  }

  Widget _buildHudActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isHighlight = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AudioService.instance.playClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 68,
          height: 60,
          decoration: BoxDecoration(
            color: isHighlight
                ? AstroviaTheme.gold.withValues(alpha: 0.3)
                : AstroviaTheme.panelTranslucent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHighlight ? AstroviaTheme.gold : AstroviaTheme.cyan,
              width: isHighlight ? 1.8 : 1.2,
            ),
            boxShadow: isHighlight ? AstroviaTheme.goldGlowShadow : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isHighlight ? AstroviaTheme.gold : AstroviaTheme.cyan,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AstroviaTheme.rajdhani(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isHighlight ? AstroviaTheme.gold : AstroviaTheme.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
