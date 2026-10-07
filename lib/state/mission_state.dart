import 'package:flutter/material.dart';

class MissionState extends ChangeNotifier {
  static final MissionState instance = MissionState._internal();
  MissionState._internal();

  String astronautName = "MOMIN";
  int level = 1;
  int xp = 0;
  int science = 0;
  int exploration = 0;

  String selectedSuit = "EXPLORER SUIT";
  String selectedRocket = "LUNAR EXPLORER";

  bool soundMuted = false; // Enabled SFX by default so user can hear the new sounds!
  bool roverScanned = false;
  bool sampleCollected = false;

  void setAstronautName(String name) {
    if (name.trim().isNotEmpty) {
      astronautName = name.trim().toUpperCase();
      notifyListeners();
    }
  }

  void selectSuit(String suit) {
    selectedSuit = suit;
    notifyListeners();
  }

  void selectRocket(String rocket) {
    selectedRocket = rocket;
    notifyListeners();
  }

  void toggleSound() {
    soundMuted = !soundMuted;
    notifyListeners();
  }

  void completeSampleScan() {
    roverScanned = true;
    science += 250;
    exploration += 180;
    xp += 430;
    notifyListeners();
  }

  void resetMission() {
    roverScanned = false;
    sampleCollected = false;
    notifyListeners();
  }
}
