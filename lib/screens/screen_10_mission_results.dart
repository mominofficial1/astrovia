import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/astrovia_video_background.dart';
import 'screen_06_mission_briefing.dart';
import 'screen_mission_map.dart';

class Screen10MissionResults extends StatefulWidget {
  const Screen10MissionResults({super.key});

  @override
  State<Screen10MissionResults> createState() => _Screen10MissionResultsState();
}

class _Screen10MissionResultsState extends State<Screen10MissionResults>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Map<String, dynamic> _results = {};
  bool _evaluated = false;

  @override
  void initState() {
    super.initState();
    AudioService.instance.playSuccess();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    // Evaluate mission completion once and award rewards safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_evaluated) {
        _evaluated = true;
        final res = MissionState.instance.completeMissionSuccess(
          baseScore: 1250,
          timeSeconds: 180,
        );
        setState(() {
          _results = res;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _goToMissionMap() {
    AudioService.instance.playClick();
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, a1, a2) => const ScreenMissionMap(),
        transitionsBuilder: (ctx, a1, a2, child) =>
            FadeTransition(opacity: a1, child: child),
      ),
      (route) => false,
    );
  }

  void _replayMission() {
    final mission = MissionState.instance.currentMission;
    if (mission != null) {
      AudioService.instance.playTransition();
      MissionState.instance.startMission(mission);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (ctx, a1, a2) => const Screen06MissionBriefing(),
          transitionsBuilder: (ctx, a1, a2, child) =>
              FadeTransition(opacity: a1, child: child),
        ),
      );
    }
  }

  void _nextMission() {
    final current = MissionState.instance.currentMission;
    if (current != null && current.levelNumber < 10) {
      final nextMission = MissionModel.allMissions[current.levelNumber];
      AudioService.instance.playTransition();
      MissionState.instance.startMission(nextMission);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (ctx, a1, a2) => const Screen06MissionBriefing(),
          transitionsBuilder: (ctx, a1, a2, child) =>
              FadeTransition(opacity: a1, child: child),
        ),
      );
    } else {
      _goToMissionMap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = MissionState.instance;
    final mission = state.currentMission ?? MissionModel.allMissions[0];
    final coinsAwarded = _results['coinsAwarded'] ?? mission.coinReward;
    final xpAwarded = _results['xpAwarded'] ?? mission.xpReward;
    final stars = _results['stars'] as int? ?? 3;
    final isFirstClear = _results['isFirstClear'] as bool? ?? true;
    final campaignCompleted = _results['campaignCompleted'] as bool? ?? false;

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: AstroviaVideoBackground(
        videoAsset: 'assets/videos/astrovia_intro.mp4',
        overlayOpacity: 0.45,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Success Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: AstroviaTheme.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AstroviaTheme.green, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AstroviaTheme.green.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      campaignCompleted
                          ? "★ GRAND CAMPAIGN ACCOMPLISHED ★"
                          : "★ MISSION ACCOMPLISHED ★",
                      style: AstroviaTheme.orbitron(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AstroviaTheme.green,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Main Mission Title
                Center(
                  child: Text(
                    mission.title,
                    textAlign: TextAlign.center,
                    style: AstroviaTheme.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AstroviaTheme.white,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Star Rating Stars
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final hasStar = i < stars;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          hasStar ? Icons.star_rounded : Icons.star_border_rounded,
                          color: hasStar ? AstroviaTheme.gold : AstroviaTheme.secondary,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),

                // Main Results Breakdown Layout
                Expanded(
                  child: Row(
                    children: [
                      // Left: Objectives Verified List
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AstroviaTheme.panelTranslucent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AstroviaTheme.cyan.withValues(alpha: 0.35)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "VERIFIED MISSION DIRECTIVES",
                                style: AstroviaTheme.orbitron(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.cyan,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: mission.objectives.length,
                                  separatorBuilder: (ctx, i) =>
                                      const SizedBox(height: 6),
                                  itemBuilder: (ctx, idx) {
                                    final obj = mission.objectives[idx];
                                    return Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded,
                                            size: 16,
                                            color: AstroviaTheme.green),
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
                                        Text(
                                          "PASSED",
                                          style: AstroviaTheme.orbitron(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AstroviaTheme.green,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Right: Rewards & Progression Card
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AstroviaTheme.panelTranslucent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AstroviaTheme.gold.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "MISSION PAYOUT & EXPEDITION XP",
                                style: AstroviaTheme.orbitron(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.gold,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildRewardTile(
                                "+$coinsAwarded COINS",
                                isFirstClear
                                    ? "Full first-completion bounty"
                                    : "Repeat expedition grant (25%)",
                                Icons.monetization_on_rounded,
                                AstroviaTheme.gold,
                              ),
                              const SizedBox(height: 10),
                              _buildRewardTile(
                                "+$xpAwarded FLIGHT XP",
                                "Scientific telemetry archival reward",
                                Icons.military_tech_rounded,
                                AstroviaTheme.cyan,
                              ),
                              const SizedBox(height: 10),
                              if (mission.levelNumber < 10)
                                _buildRewardTile(
                                  "LEVEL ${mission.levelNumber + 1} UNLOCKED",
                                  MissionModel.allMissions[mission.levelNumber].title,
                                  Icons.lock_open_rounded,
                                  AstroviaTheme.green,
                                ),
                              const Spacer(),
                              Text(
                                "TOTAL COINS: ${state.saveData.coins}  •  TOTAL XP: ${state.saveData.xp}",
                                style: AstroviaTheme.orbitron(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Bottom Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        backgroundColor: AstroviaTheme.panelGlass,
                        side: BorderSide(
                            color: AstroviaTheme.cyan.withValues(alpha: 0.5)),
                      ),
                      icon: const Icon(Icons.map_rounded,
                          color: AstroviaTheme.cyan, size: 18),
                      label: Text(
                        "MISSION MAP",
                        style: AstroviaTheme.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AstroviaTheme.cyan,
                        ),
                      ),
                      onPressed: _goToMissionMap,
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            backgroundColor: AstroviaTheme.panelGlass,
                            side: BorderSide(
                                color: AstroviaTheme.gold.withValues(alpha: 0.5)),
                          ),
                          icon: const Icon(Icons.refresh_rounded,
                              color: AstroviaTheme.gold, size: 18),
                          label: Text(
                            "REPLAY MISSION",
                            style: AstroviaTheme.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AstroviaTheme.gold,
                            ),
                          ),
                          onPressed: _replayMission,
                        ),
                        const SizedBox(width: 12),
                        if (mission.levelNumber < 10)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AstroviaTheme.cyan.withValues(alpha: 0.3),
                              side: const BorderSide(color: AstroviaTheme.cyan),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded,
                                color: AstroviaTheme.white, size: 18),
                            label: Text(
                              "NEXT MISSION ►",
                              style: AstroviaTheme.orbitron(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.white,
                              ),
                            ),
                            onPressed: _nextMission,
                          )
                        else
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AstroviaTheme.gold.withValues(alpha: 0.35),
                              side: const BorderSide(color: AstroviaTheme.gold),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                            ),
                            icon: const Icon(Icons.emoji_events_rounded,
                                color: AstroviaTheme.gold, size: 18),
                            label: Text(
                              "CAMPAIGN VICTORY ► MAP",
                              style: AstroviaTheme.orbitron(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.gold,
                              ),
                            ),
                            onPressed: _goToMissionMap,
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

  Widget _buildRewardTile(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AstroviaTheme.darkSpace,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AstroviaTheme.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: AstroviaTheme.inter(
                    fontSize: 10,
                    color: AstroviaTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
