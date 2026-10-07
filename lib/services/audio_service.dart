import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../state/mission_state.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  AudioService._internal() {
    _initPlayer();
  }

  AudioPlayer? _sfxPlayer;
  bool _isDisposed = false;
  bool _isPlaying = false;

  void _initPlayer() {
    try {
      _sfxPlayer = AudioPlayer();
      _sfxPlayer?.setReleaseMode(ReleaseMode.stop).catchError((_) {});
    } catch (e) {
      if (kDebugMode) {
        print('AudioService init error: $e');
      }
    }
  }

  Future<void> _play(String assetName) async {
    if (_isDisposed) return;
    if (MissionState.instance.soundMuted) return;

    // Concurrency guard: avoid overlapping native MediaPlayer calls that crash Android
    if (_isPlaying) return;
    _isPlaying = true;

    try {
      if (_sfxPlayer == null) {
        _initPlayer();
      }
      final cleanPath = assetName.startsWith('assets/')
          ? assetName.substring(7)
          : assetName;

      final player = _sfxPlayer;
      if (player != null) {
        await player.stop().catchError((_) {});
        await player.play(AssetSource(cleanPath), volume: 0.85).catchError((_) {});
      }
    } catch (e) {
      if (kDebugMode) {
        print('AudioService error playing $assetName: $e');
      }
    } finally {
      // Short delay before allowing next sound to avoid native buffer overflow
      Future.delayed(const Duration(milliseconds: 140), () {
        _isPlaying = false;
      });
    }
  }

  void playClick() => _play('assets/audio/button_click.wav');
  void playTransition() => _play('assets/audio/screen_transition.wav');
  void playScan() => _play('assets/audio/scan_beep.wav');
  void playCountdown() => _play('assets/audio/launch_countdown.wav');
  void playSuccess() => _play('assets/audio/success_chime.wav');

  void dispose() {
    _isDisposed = true;
    try {
      _sfxPlayer?.dispose().catchError((_) {});
      _sfxPlayer = null;
    } catch (_) {}
  }
}

