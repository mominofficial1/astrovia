# ASTROVIA — THE JOURNEY THROUGH SPACE

> **AAA Cinematic Space Mission & Planetary Exploration Experience built with Flutter**

---

## 🚀 Overview

**ASTROVIA** is an offline-first space mission simulation and planetary exploration game prototype designed for landscape Android displays. Built for hackathons and space exploration enthusiasts, it immerses players into the role of a deep space astronaut commander through real 1080p cinematic video layers, reactive aerospace telemetry HUDs, custom sound effects, and interactive surface exploration gameplay.

---

## ✨ Key Features

### 🎬 10 Cinematic Landscape Screens
1. **Screen 01 — Cinematic Entry:** AAA space game title sequence with sequential title reveals over orbital Earth observation video.
2. **Screen 02 — Mission Control Command:** Futuristic glassmorphism navigation hub with telemetry badges, astronaut callsign editor, and rich visual operation cards.
3. **Screen 03 — Astronaut Dossier:** Character profile with pilot XP, science archives, and holographic avatar.
4. **Screen 04 — Suit Selection:** Modular spacesuit loadout (`Explorer Suit`, `Lunar Suit`, `Deep Space Suit`) with animated scanning beams and stat meters.
5. **Screen 05 — Rocket Selection:** Heavy-lift propulsion selection (`Orbiter`, `Lunar Explorer`, `Deep Space Vehicle`) with payload and fuel telemetry.
6. **Screen 06 — Mission Briefing:** NASA-grade mission directives, operational objectives, and flight metrics.
7. **Screen 07 — Terminal Launch Sequence:** Full-screen launch countdown ($T-10 \to T-1$) with real-time fuel and oxygen gauges, transitioning through a white/cyan ignition flash.
8. **Screen 08 — Planetary Exploration:** Interactive 3rd-person lunar surface gameplay with dual control schemes (360° Joystick & 4-way D-Pad), character walking physics, dynamic coordinate telemetry, and anomaly beacon proximity detection.
9. **Screen 09 — Autonomous Rover Science Mission:** Planetary rover deployment, spectral scanning beam, sample acquisition, and scientific educational briefing.
10. **Screen 10 — Mission Results & Debrief:** Animated score evaluations, scientific data logs, discovery summaries, and curriculum insights.

---

## 🎮 Interactive Gameplay Controls

* **Dual Navigation System:**
  * **360° Analog Joystick:** Dynamic drag vector with proportional velocity.
  * **4-Way Game D-Pad:** Dedicated **▲ UP**, **▼ DOWN**, **◄ LEFT**, and **► RIGHT** buttons for manual navigation.
* **Character Mechanics:**
  * Directional avatar flipping (faces direction of travel).
  * Cadenced walking bob and regolith surface motion.
  * Screen boundary collision enforcement.
  * Real-time distance and radar tracking to target crater anomalies.

---

## 🔊 Audio & Visual Engineering

* **Reactive Sci-Fi SFX:**
  * Interface click beeps
  * Atmospheric screen transition whoosh
  * Telemetry sonar radar scan pulses
  * Countdown cadence beeps
  * Mission completion triumph chime
* **Cinematic Video Backgrounds:**
  * Official H.264 MP4 1080p video integration with hardware acceleration.
  * Memory-safe controller lifecycle management with automatic disposal.
  * High-fidelity cosmic starfield and nebula canvas fallbacks.
* **Design Palette:**
  * Background: `#050B14`
  * Dark Space: `#02050A`
  * Panel Glass: `#0D1B2A`
  * Cyan Accent: `#19D9FF`
  * Solar Gold: `#FFC857`
  * Typography: Orbitron, Rajdhani, Inter

---

## 🛠️ Tech Stack & Dependencies

* **Framework:** Flutter 3.47.x (Channel Stable)
* **Language:** Dart 3.13.x
* **Core Packages:**
  * `video_player: ^2.14.1` — Hardware-accelerated video playback
  * `audioplayers: ^6.8.1` — Low-latency sound effects playback
  * `google_fonts: ^9.0.0` — Aerospace typography with offline font fallbacks
  * `video_player_win: ^3.3.0` — Media Foundation desktop playback support

---

## 📦 How to Build & Run

### Prerequisites
* Flutter SDK (3.40+)
* Android SDK (API 34+)

### 1. Clone & Fetch Dependencies
```bash
git clone https://github.com/mominofficial/astrovia.git
cd astrovia
flutter pub get
```

### 2. Run in Landscape Mode
```bash
flutter run
```

### 3. Build Android Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📄 License
MIT License. Created by [mominofficial](https://github.com/mominofficial).
