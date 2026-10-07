import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import '../widgets/cyber_button.dart';
import '../widgets/hud_container.dart';
import '../widgets/scanner_beam.dart';
import 'screen_10_mission_results.dart';

class Screen09RoverScienceMission extends StatefulWidget {
  const Screen09RoverScienceMission({super.key});

  @override
  State<Screen09RoverScienceMission> createState() =>
      _Screen09RoverScienceMissionState();
}

class _Screen09RoverScienceMissionState
    extends State<Screen09RoverScienceMission> {
  bool _isScanning = false;
  bool _sampleDetected = false;
  bool _sampleAnalyzed = false;
  double _roverDistance = 126.0;

  void _triggerScan() {
    AudioService.instance.playScan();
    setState(() {
      _isScanning = true;
    });

    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      AudioService.instance.playSuccess();
      setState(() {
        _isScanning = false;
        _sampleDetected = true;
      });
    });
  }

  void _driveRover() {
    AudioService.instance.playClick();
    setState(() {
      if (_roverDistance > 10) {
        _roverDistance -= 18;
      }
    });
  }

  void _analyzeSample() {
    AudioService.instance.playSuccess();
    setState(() {
      _sampleAnalyzed = true;
    });
    MissionState.instance.completeSampleScan();
  }

  void _proceedToResults() {
    AudioService.instance.playTransition();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Screen10MissionResults(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slow cinematic fade per Section 24
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: AstroviaVideoBackground(
        videoAsset: 'assets/videos/lunar_exploration.mp4',
        overlayOpacity: 0.35,
        loop: true,
        showMuteButton: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Stack(
              children: [
                // Animated Scanning Beam when scanning is active
                if (_isScanning)
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: ScannerBeam(
                        height: 400,
                        duration: Duration(milliseconds: 1000),
                      ),
                    ),
                  ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Telemetry Header
                    _buildTopHeader(),
                    const SizedBox(height: 14),

                    // Main Interactive Section
                    Expanded(
                      child: Row(
                        children: [
                          // Left: Rover System Controls
                          Expanded(
                            flex: 5,
                            child: HudContainer(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "AUTONOMOUS ROVER NAVIGATION",
                                        style: AstroviaTheme.orbitron(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AstroviaTheme.cyan,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "CHASSIS SENSORS: 4-WHEEL INDEPENDENT STEER",
                                        style: AstroviaTheme.rajdhani(
                                          fontSize: 12,
                                          color: AstroviaTheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Rover Interactive Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CyberButton(
                                          label: "DRIVE",
                                          icon: Icons.navigation_rounded,
                                          variant: CyberButtonVariant.cyan,
                                          height: 46,
                                          fontSize: 13,
                                          onPressed: _driveRover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: CyberButton(
                                          label: _isScanning
                                              ? "SCANNING..."
                                              : "SCAN",
                                          icon: Icons.radar_rounded,
                                          variant: _sampleDetected
                                              ? CyberButtonVariant.gold
                                              : CyberButtonVariant.cyan,
                                          height: 46,
                                          fontSize: 13,
                                          onPressed: _isScanning
                                              ? () {}
                                              : _triggerScan,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CyberButton(
                                          label: "SAMPLE",
                                          icon: Icons.biotech_rounded,
                                          variant: CyberButtonVariant.cyan,
                                          height: 46,
                                          fontSize: 13,
                                          onPressed: _analyzeSample,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: CyberButton(
                                          label: "ANALYZE",
                                          icon: Icons.insights_rounded,
                                          variant: CyberButtonVariant.cyan,
                                          height: 46,
                                          fontSize: 13,
                                          onPressed: _analyzeSample,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Right: Scientific Detection & Educational Panel
                          Expanded(
                            flex: 6,
                            child: HudContainer(
                              isSelected: _sampleDetected,
                              isGold: _sampleAnalyzed,
                              padding: const EdgeInsets.all(16.0),
                              child: _sampleDetected
                                  ? _buildDetectionPanel()
                                  : _buildAwaitingScanPanel(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bottom Navigation: Return to Map / Proceed to Results
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CyberButton(
                          label: "EVA MAP VIEW",
                          icon: Icons.arrow_back_rounded,
                          variant: CyberButtonVariant.transparent,
                          minWidth: 160,
                          height: 44,
                          onPressed: () => Navigator.pop(context),
                        ),
                        if (_sampleDetected)
                          CyberButton(
                            label: "COMPLETE OBJECTIVE ►",
                            icon: Icons.check_circle_rounded,
                            variant: CyberButtonVariant.gold,
                            minWidth: 230,
                            height: 46,
                            onPressed: _proceedToResults,
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
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
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AstroviaTheme.cyan,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AstroviaTheme.cyan,
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "ROVER ONLINE",
                style: AstroviaTheme.orbitron(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderStat("BATTERY", "82%", AstroviaTheme.green),
              const SizedBox(width: 18),
              _buildHeaderStat("SIGNAL", "98%", AstroviaTheme.cyan),
              const SizedBox(width: 18),
              _buildHeaderStat(
                  "DISTANCE", "${_roverDistance.toInt()}M", AstroviaTheme.gold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, Color color) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: AstroviaTheme.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AstroviaTheme.secondary,
          ),
        ),
        Text(
          value,
          style: AstroviaTheme.orbitron(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAwaitingScanPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.radar_rounded,
            size: 54,
            color: AstroviaTheme.secondary,
          ),
          const SizedBox(height: 12),
          Text(
            "SURFACE RADAR STANDBY",
            style: AstroviaTheme.orbitron(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AstroviaTheme.secondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "PRESS [SCAN] TO EMIT SPECTRAL RADAR PULSE",
            style: AstroviaTheme.rajdhani(
              fontSize: 13,
              color: AstroviaTheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AstroviaTheme.cyan, size: 20),
                const SizedBox(width: 8),
                Text(
                  "SCIENTIFIC OBJECT DETECTED",
                  style: AstroviaTheme.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AstroviaTheme.cyan,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "LUNAR REGOLITH ILMENITE SAMPLE",
              style: AstroviaTheme.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AstroviaTheme.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  "SCIENTIFIC VALUE: ",
                  style: AstroviaTheme.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AstroviaTheme.secondary,
                  ),
                ),
                Text(
                  "HIGH (RICH TITANIUM & OXYGEN ISOTOPES)",
                  style: AstroviaTheme.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AstroviaTheme.gold,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Educational Information Panel (Section 14 requirement)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AstroviaTheme.panel,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AstroviaTheme.cyan.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.school_rounded,
                  color: AstroviaTheme.cyan, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "This sample helps scientists understand how regolith can be refined into breathable oxygen and rocket propellant for permanent extraterrestrial lunar bases.",
                  style: AstroviaTheme.inter(
                    fontSize: 12,
                    color: AstroviaTheme.white,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
