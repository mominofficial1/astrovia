import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../models/planetary_data.dart';
import '../rendering/planetary_environment_renderer.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import 'screen_06_mission_briefing.dart';

class ScreenMissionMap extends StatefulWidget {
  const ScreenMissionMap({super.key});

  @override
  State<ScreenMissionMap> createState() => _ScreenMissionMapState();
}

class _ScreenMissionMapState extends State<ScreenMissionMap> {
  late ScrollController _scrollController;
  final List<MissionModel> _missions = MissionModel.allMissions;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Scroll automatically toward active unlocked mission
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final unlocked = MissionState.instance.saveData.unlockedCampaignLevel;
      final targetScroll = ((unlocked - 1) * 160.0).clamp(0.0, 1200.0);
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          targetScroll,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openMissionPreview(MissionModel mission, bool isUnlocked) {
    AudioService.instance.playClick();
    final record = MissionState.instance.saveData.levelRecords[mission.levelNumber];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AstroviaTheme.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AstroviaTheme.cyan, width: 1.5),
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge & Level
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AstroviaTheme.cyan.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isUnlocked ? AstroviaTheme.cyan : Colors.grey,
                      ),
                    ),
                    child: Text(
                      "LEVEL ${mission.levelNumber.toString().padLeft(2, '0')} • ${mission.codeName}",
                      style: AstroviaTheme.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? AstroviaTheme.cyan : Colors.grey,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(3, (starIdx) {
                      final hasStar = (record?.starsEarned ?? 0) > starIdx;
                      return Icon(
                        hasStar ? Icons.star_rounded : Icons.star_border_rounded,
                        color: hasStar ? AstroviaTheme.gold : AstroviaTheme.secondary,
                        size: 20,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title & Destination
              Text(
                mission.title,
                style: AstroviaTheme.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AstroviaTheme.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.place_rounded, color: AstroviaTheme.gold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    mission.destinationName,
                    style: AstroviaTheme.rajdhani(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.gold,
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0x3319D9FF), height: 20),

              // Summary
              Text(
                mission.briefingSummary,
                style: AstroviaTheme.inter(
                  fontSize: 13,
                  color: AstroviaTheme.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),

              // Historical context & Disclaimer
              if (mission.disclaimerNotice.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AstroviaTheme.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AstroviaTheme.gold.withValues(alpha: 0.5)),
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

              // Rewards & Record
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monetization_on_rounded,
                          color: AstroviaTheme.gold, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "+${mission.coinReward} COINS",
                        style: AstroviaTheme.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AstroviaTheme.gold,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.military_tech_rounded,
                          color: AstroviaTheme.cyan, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "+${mission.xpReward} XP",
                        style: AstroviaTheme.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AstroviaTheme.cyan,
                        ),
                      ),
                    ],
                  ),
                  if (record != null && record.bestScore > 0)
                    Text(
                      "BEST: ${record.bestScore} PTS",
                      style: AstroviaTheme.orbitron(
                        fontSize: 11,
                        color: AstroviaTheme.secondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "CLOSE",
                      style: AstroviaTheme.rajdhani(
                        color: AstroviaTheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUnlocked
                          ? AstroviaTheme.cyan.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.2),
                      side: BorderSide(
                        color: isUnlocked ? AstroviaTheme.cyan : Colors.grey,
                      ),
                    ),
                    onPressed: isUnlocked
                        ? () {
                            Navigator.pop(context);
                            MissionState.instance.startMission(mission);
                            AudioService.instance.playTransition();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, a1, a2) =>
                                    const Screen06MissionBriefing(),
                                transitionsBuilder: (context, a1, a2, child) =>
                                    FadeTransition(opacity: a1, child: child),
                              ),
                            );
                          }
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUnlocked ? Icons.rocket_launch_rounded : Icons.lock_rounded,
                          size: 16,
                          color: isUnlocked ? AstroviaTheme.white : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isUnlocked ? "START MISSION" : "MISSION LOCKED",
                          style: AstroviaTheme.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? AstroviaTheme.white : Colors.grey,
                          ),
                        ),
                      ],
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
    final state = MissionState.instance;
    final unlockedLevel = state.saveData.unlockedCampaignLevel;
    final isCampaignComplete = state.saveData.isCampaignCompleted;

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: PlanetaryEnvironmentWidget(
        planetaryData: PlanetaryData.earth,
        levelNumber: 1,
        isOrbital: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: AstroviaTheme.cyan),
                          onPressed: () {
                            AudioService.instance.playClick();
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AstroviaTheme.cyan.withValues(alpha: 0.4),
                              width: 1.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.asset(
                              'assets/images/astravia_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "ASTRAVIA CAMPAIGN MISSION MAP",
                          style: AstroviaTheme.orbitron(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AstroviaTheme.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "PROGRESSION ROUTE • 10 EXPLORATION NODES",
                          style: AstroviaTheme.rajdhani(
                            fontSize: 12,
                            color: AstroviaTheme.cyan,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on_rounded,
                            color: AstroviaTheme.gold, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "${state.saveData.coins}",
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
                const SizedBox(height: 12),

                // Campaign Complete Trophy Banner if unlocked
                if (isCampaignComplete)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AstroviaTheme.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AstroviaTheme.gold, width: 1.5),
                      boxShadow: AstroviaTheme.goldGlowShadow,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events_rounded,
                            color: AstroviaTheme.gold, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          "★ CAMPAIGN COMPLETED: ALL 10 NASA MISSIONS CONQUERED ★",
                          style: AstroviaTheme.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AstroviaTheme.gold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Horizontal Winding Progression Route
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(_missions.length, (idx) {
                        final mission = _missions[idx];
                        final levelNum = mission.levelNumber;
                        final isUnlocked = levelNum <= unlockedLevel;
                        final isCompleted =
                            state.saveData.levelRecords[levelNum]?.isCompleted ?? false;
                        final record = state.saveData.levelRecords[levelNum];

                        // Alternating winding vertical offset (sinusoidal road)
                        final verticalOffset = (idx % 2 == 0) ? -28.0 : 28.0;

                        return Row(
                          children: [
                            // Mission Node Card
                            Transform.translate(
                              offset: Offset(0, verticalOffset),
                              child: InkWell(
                                onTap: () => _openMissionPreview(mission, isUnlocked),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 175,
                                  height: 240,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUnlocked
                                        ? AstroviaTheme.panelTranslucent
                                        : Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isCompleted
                                          ? AstroviaTheme.gold
                                          : (isUnlocked
                                              ? AstroviaTheme.cyan
                                              : Colors.grey.withValues(alpha: 0.4)),
                                      width: isCompleted || isUnlocked ? 1.8 : 1.0,
                                    ),
                                    boxShadow: isCompleted
                                        ? AstroviaTheme.goldGlowShadow
                                        : (isUnlocked
                                            ? AstroviaTheme.cyanGlowShadow
                                            : []),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Node Number & Lock/Check status
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isCompleted
                                                  ? AstroviaTheme.gold
                                                  : (isUnlocked
                                                      ? AstroviaTheme.cyan
                                                      : Colors.grey),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "$levelNum",
                                              style: AstroviaTheme.orbitron(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AstroviaTheme.darkSpace,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            isCompleted
                                                ? Icons.check_circle_rounded
                                                : (isUnlocked
                                                    ? Icons.play_arrow_rounded
                                                    : Icons.lock_rounded),
                                            color: isCompleted
                                                ? AstroviaTheme.gold
                                                : (isUnlocked
                                                    ? AstroviaTheme.cyan
                                                    : Colors.grey),
                                            size: 20,
                                          ),
                                        ],
                                      ),

                                      // Mission Title & Destination
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mission.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AstroviaTheme.orbitron(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isUnlocked
                                                  ? AstroviaTheme.white
                                                  : Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            mission.destinationName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AstroviaTheme.rajdhani(
                                              fontSize: 10,
                                              color: isUnlocked
                                                  ? AstroviaTheme.cyan
                                                  : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Stars & Reward
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: List.generate(3, (s) {
                                              final hasStar =
                                                  (record?.starsEarned ?? 0) > s;
                                              return Icon(
                                                hasStar
                                                    ? Icons.star_rounded
                                                    : Icons.star_border_rounded,
                                                color: hasStar
                                                    ? AstroviaTheme.gold
                                                    : AstroviaTheme.secondary,
                                                size: 14,
                                              );
                                            }),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.monetization_on_rounded,
                                                color: AstroviaTheme.gold,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "+${mission.coinReward}",
                                                style: AstroviaTheme.orbitron(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: AstroviaTheme.gold,
                                                ),
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

                            // Connecting Glowing Path Segment (between nodes)
                            if (idx < _missions.length - 1)
                              Container(
                                width: 44,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? AstroviaTheme.gold
                                      : (isUnlocked
                                          ? AstroviaTheme.cyan.withValues(alpha: 0.6)
                                          : Colors.grey.withValues(alpha: 0.3)),
                                  boxShadow: isCompleted
                                      ? AstroviaTheme.goldGlowShadow
                                      : [],
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
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

