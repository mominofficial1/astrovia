import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/save_manager.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/hud_container.dart';

class ScreenSettings extends StatefulWidget {
  const ScreenSettings({super.key});

  @override
  State<ScreenSettings> createState() => _ScreenSettingsState();
}

class _ScreenSettingsState extends State<ScreenSettings> {
  void _confirmResetData() {
    AudioService.instance.playClick();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AstroviaTheme.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AstroviaTheme.red, width: 1.5),
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_rounded,
                      color: AstroviaTheme.red, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "RESET MISSION PROGRESS?",
                    style: AstroviaTheme.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "This will clear all unlocked campaign levels, earned coins, and custom blueprints back to initial launch settings. This action cannot be undone.",
                style: AstroviaTheme.inter(
                  fontSize: 12,
                  color: AstroviaTheme.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      "CANCEL",
                      style: AstroviaTheme.rajdhani(
                        color: AstroviaTheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AstroviaTheme.red.withValues(alpha: 0.3),
                      side: const BorderSide(color: AstroviaTheme.red),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await SaveManager.instance.resetSave();
                      MissionState.instance.refreshFromSave();
                      AudioService.instance.playClick();
                      if (mounted) setState(() {});
                    },
                    child: Text(
                      "CONFIRM RESET",
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
    final state = MissionState.instance;
    final settings = state.saveData.settings;

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
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
                  Text(
                    "MISSION CONTROL SETTINGS & ACCESSIBILITY",
                    style: AstroviaTheme.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Row(
                  children: [
                    // Left Column: Audio & Controls
                    Expanded(
                      flex: 6,
                      child: HudContainer(
                        isSelected: true,
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AUDIO & SOUND EFFECTS",
                                style: AstroviaTheme.orbitron(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.cyan,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildSwitchRow(
                                "MUTE ALL AUDIO",
                                settings.isMuted,
                                (val) {
                                  state.toggleSound();
                                  setState(() {});
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildSliderRow(
                                "SOUND EFFECTS (SFX) VOLUME",
                                settings.sfxVolume,
                                (val) {
                                  setState(() => settings.sfxVolume = val);
                                  SaveManager.instance.save();
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildSliderRow(
                                "AMBIENT SPACE MUSIC VOLUME",
                                settings.musicVolume,
                                (val) {
                                  setState(() => settings.musicVolume = val);
                                  SaveManager.instance.save();
                                },
                              ),
                              const Divider(
                                  color: Color(0x3319D9FF), height: 24),
                              Text(
                                "CONTROLS & ACCESSIBILITY",
                                style: AstroviaTheme.orbitron(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.gold,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildSwitchRow(
                                "ON-SCREEN VIRTUAL JOYSTICK & TOUCH CONTROLS",
                                settings.touchControlsEnabled,
                                (val) {
                                  setState(
                                      () => settings.touchControlsEnabled = val);
                                  SaveManager.instance.save();
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildSwitchRow(
                                "REDUCED MOTION (DISABLE SCREEN SHAKE & FLASH)",
                                settings.reducedMotion,
                                (val) {
                                  setState(() => settings.reducedMotion = val);
                                  SaveManager.instance.save();
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildSliderRow(
                                "CAMERA ROTATION SENSITIVITY",
                                settings.cameraSensitivity / 2.0,
                                (val) {
                                  setState(() =>
                                      settings.cameraSensitivity = val * 2.0);
                                  SaveManager.instance.save();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Column: System Info & Game Save Data
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AstroviaTheme.panelTranslucent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AstroviaTheme.cyan.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 72,
                                height: 72,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AstroviaTheme.cyan.withValues(alpha: 0.45),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AstroviaTheme.cyan.withValues(alpha: 0.2),
                                      blurRadius: 16,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    'assets/images/astravia_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "MISSION PROFILE & DATA STORAGE",
                              style: AstroviaTheme.orbitron(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.cyan,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoText(
                                "COMMANDER CALLSIGN", state.astronautName),
                            _buildInfoText("ASTRONAUT RANK", state.saveData.rankTitle),
                            _buildInfoText("TOTAL FLIGHT XP", "${state.saveData.xp} XP"),
                            _buildInfoText("CAMPAIGN PROGRESS",
                                "Level ${state.saveData.unlockedCampaignLevel} / 10 Unlocked"),
                            _buildInfoText("SAVE FILE VERSION",
                                "v${state.saveData.version}.0 (Offline Local Persistence)"),
                            const Spacer(),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AstroviaTheme.red.withValues(alpha: 0.2),
                                side: const BorderSide(color: AstroviaTheme.red),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              icon: const Icon(Icons.delete_forever_rounded,
                                  color: AstroviaTheme.red),
                              label: Text(
                                "RESET ALL PROGRESS",
                                style: AstroviaTheme.orbitron(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.white,
                                ),
                              ),
                              onPressed: _confirmResetData,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildSwitchRow(String label, bool val, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AstroviaTheme.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AstroviaTheme.white,
            ),
          ),
        ),
        Switch(
          value: val,
          activeTrackColor: AstroviaTheme.cyan,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSliderRow(
      String label, double val, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AstroviaTheme.rajdhani(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AstroviaTheme.secondary,
              ),
            ),
            Text(
              "${(val * 100).toInt()}%",
              style: AstroviaTheme.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AstroviaTheme.cyan,
              ),
            ),
          ],
        ),
        Slider(
          value: val.clamp(0.0, 1.0),
          activeColor: AstroviaTheme.cyan,
          inactiveColor: AstroviaTheme.darkSpace,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
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
          const SizedBox(height: 2),
          Text(
            value,
            style: AstroviaTheme.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AstroviaTheme.white,
            ),
          ),
        ],
      ),
    );
  }
}
