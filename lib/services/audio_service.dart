import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../state/mission_state.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();

  Future<void> _play(String assetName) async {
    // If sound is muted in mission state, do not play
    if (MissionState.instance.soundMuted) return;

    try {
      // audioplayers plays from AssetSource without leading 'assets/'
      final cleanPath = assetName.startsWith('assets/')
          ? assetName.substring(7)
          : assetName;
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(cleanPath), volume: 0.85);
    } catch (e) {
      if (kDebugMode) {
        print('AudioService error playing $assetName: $e');
      }
    }
  }

  void playClick() => _play('assets/audio/button_click.wav');
  void playTransition() => _play('assets/audio/screen_transition.wav');
  void playScan() => _play('assets/audio/scan_beep.wav');
  void playCountdown() => _play('assets/audio/launch_countdown.wav');
  void playSuccess() => _play('assets/audio/success_chime.wav');

  void dispose() {
    _sfxPlayer.dispose();
  }
}
