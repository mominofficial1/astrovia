# ASTRAVIA — THE JOURNEY THROUGH SPACE

> **NASA International Space Apps Challenge 2026 • Category: Space Mission Design Game**
> **A fully playable, visually polished, NASA-data-informed space mission adventure built with Flutter & Dart.**

---

## 🚀 Overview

**ASTRAVIA** is a deep-space mission design game and planetary surface exploration adventure. The player experiences space exploration firsthand: personalizing their astronaut commander, engineering mission-compatible spacecraft in an interactive assembly hangar, executing real orbital maneuvers and lunar touchdowns, and performing hands-on field science, rock coring, rover expeditions, and spacewalk assemblies.

---

## 🌌 The Central Gameplay Loop

```
Create Profile ➔ Build Spacecraft ➔ Customize Astronaut ➔ Select Unlocked Mission
      ⬇
Review Objectives & Equipment ➔ Terminal T-Minus Countdown ➔ Pilot Spacecraft
      ⬇
Perform Mission Activities (EVA / Rover / Science) ➔ Return or Secure Results
      ⬇
Receive Rewards (Coins & XP) ➔ Unlock Next Level (1 to 10)
```

---

## ✨ Core Game Systems

### 1. Visual Direction & Coordinated Identity
* **Color Palette:** Deep Space Navy (`#050B14`, `#02050A`), Panel Glass (`#0D1B2A`), Cyan Illumination (`#19D9FF`), and Restrained Solar Gold (`#FFC857`).
* **Typography:** Aerospace-grade Orbitron (headers), Rajdhani (telemetry & data), and Inter (body legibility).
* **Cinematic Integration:** Preserved real 1080p NASA background footage (`astrovia_intro.mp4`, `astronaut_preparation.mp4`, `lunar_exploration.mp4`, `space_background.mp4`) with smooth canvas fallbacks, skip controls, replay, and browser autoplay resilience.

### 2. Main Menu Hub (7 Coordinated Modules)
1. **Continue Mission:** One-click instant resume of the current campaign level.
2. **Mission Map:** Winding 10-node progression route across Earth, Moon, Orbit, Bennu, and Mars.
3. **Rocket Builder:** Interactive assembly hangar with visual part snapping and preflight validation.
4. **Astronaut Customization:** Live 360° animated showroom customizing characters, skin tones, suits, visors, PLSS packs, colors, and patches.
5. **Equipment & Inventory:** Field bag capacity management and hermetic lander sample vault.
6. **NASA Data & Credits:** Presentation-ready interactive scientific citation center detailing all 8 required NASA datasets.
7. **Settings:** Independent SFX/music volume, virtual joystick controls toggle, reduced motion mode, camera sensitivity, and versioned data reset.

### 3. Road-Style Level Progression Map
* **Winding Route:** Glowing trajectory through space connecting Earth, lunar destinations, orbital stations, and Mars.
* **Progression Safeguards:** Level 1 initially unlocked; Level $N$ completion unlocks Level $N+1$; completed missions remain replayable; failure never deletes earned coins or relocks previously unlocked missions.
* **Dual Progression:** Campaign mission unlock tier is strictly separated from cumulative XP astronaut ranks (Cadet through Commander General). Replays award a 25% repeat grant to prevent progression exploits.

### 4. Interactive Rocket & Spacecraft Assembly Hangar
* **Visible Vehicle Assembly:** Assembled components appear directly on the vehicle stage (capsules, hydrolox tanks, engine bells, solid strap-on boosters, interstages, solar arrays, RCS blocks, landing legs, heat shields, parachutes, and sample vaults).
* **Dynamic Staging Metrics:** Computes Total Mass (kg), Propellant Mass (kg), Liftoff Thrust (kN), Earth Thrust-to-Weight Ratio (TWR), Net Power Balance (W), and Life Support (hours).
* **Preflight Diagnostic Assistant:** Validates mission physical viability (e.g., verifying heat shields and parachutes for Earth atmospheric return, landing legs for vacuum touchdowns, and TWR > 1.0 for Earth liftoff).
* **Blueprints & Tools:** Undo stack, clear/reset build, starter blueprints (Apollo Saturn V/CSM, Artemis Lunar Lander, OSIRIS-REx Robotic Probe), and persistent blueprint saving.

### 5. Astronaut Creation & Humanoid Rigged Rendering
* **Multiple Selectable Commanders:** Commander Alex Mercer, Specialist Maya Lin, Pilot Marcus Vance, and Geologist Elena Rostova.
* **Full Humanoid Rigging (`AstronautPainter`):** Procedural skeletal animation rendering dynamic idle breathing, walking stride, running posture, gravity-scaled jumping, landing impact compression, kneeling sample collection, and zero-gravity floating with cold-gas RCS backpack thruster bursts.
* **Customization Palette:** 4 skin tones (Fair, Medium, Bronze, Deep), 4 spacesuit generations (Explorer, Lunar A7L, Deep Space MK-IV, Mars Bio-Suit), 4 reflective visor tints (Gold, Cyan, Amber, Obsidian), gloves, boots, PLSS life-support rigs, primary/secondary suit colorways, and historical mission patches.
* **World Consistency:** Selected outfit choices immediately update the active 3rd-person gameplay avatar in the exploration environment.

### 6. Controllable Spacecraft Flight Simulation
* **Interactive Flight Cockpit:** Real-time throttle slider (0% to 100%), pitch attitude rotation, translation RCS thrusters, Stability Augmentation System (SAS auto-gyro dampener), landing gear extension/retraction, and staging pyrotechnics.
* **Consistent Physics:** Inertial coasting in vacuum, celestial gravity scaling (Earth 9.81, Moon 1.62, Mars 3.72, Bennu microgravity), dynamic atmospheric pressure drag, and touchdown tolerance checks (touchdown velocity $\le 4.5\text{ m/s}$, pitch $\le 10^\circ$).
* **Live Telemetry HUD:** Altitude, Downrange distance, Vertical speed, Horizontal speed, Pitch angle, Fuel mass, Battery power, Hull integrity, and Mission Control alerts.

### 7. Surface Exploration, Airlock Egress, and Field Science
* **Airlock & Hatch Operations:** Safe landing prompts depressurization and airlock egress, smoothly transitioning the player's customized astronaut onto the planetary regolith.
* **Contextual Proximity Interaction:** Approaching geological entities displays glowing radar rings and action prompts (`[E]` to interact / mount rover, `[F]` to collect geological sample).
* **Driveable Lunar Rover (LRV):** Deploy and pilot the electric exploration rover across undulating terrain, monitoring rover battery conservation and astronaut exertion.
* **Real Bag Capacity Management:** Astronaut EVA suits hold up to 15.0 kg of samples. Full bags require transferring collected rocks to the lander's hermetic storage vault to complete mission return objectives.
* **Mission Control Guidance:** In-game assistant broadcasts contextual audio-visual warnings before consumables drop to critical levels.

---

## 🗺️ The Ten Playable Missions

| Level | Mission Title | Destination | Historical Inspiration & Gameplay | Reward |
|:---:|:---|:---|:---|:---:|
| **01** | **Apollo 8: Lunar Orbit Training** | Lunar Orbit (112 km) | Spacecraft build preflight, ascent trajectory, translunar injection burn, Earthrise observation photography, and guided return. | 100 Coins / 300 XP |
| **02** | **Apollo 11: First Lunar Steps** | Sea of Tranquility | Lunar module descent, airlock egress, collecting Mare Basalt (#10017), Breccia (#10021), and core tube soil (#10005), securing samples in lander vault. | 150 Coins / 450 XP |
| **03** | **Apollo 12: Precision & Equipment** | Ocean of Storms | Pinpoint crater landing, navigating to robotic Surveyor 3 probe, recovering Surveyor optical camera, and deploying ALSEP nuclear seismic station. | 200 Coins / 600 XP |
| **04** | **Apollo 15: Lunar Rover Expedition** | Hadley–Apennine | Deploying electric Lunar Roving Vehicle (LRV), driving to Station 2 at Hadley Delta, collecting ancient Genesis Rock Anorthosite (#15415) and Rille basalt. | 250 Coins / 750 XP |
| **05** | **Apollo 17: Field Scientist** | Taurus–Littrow Valley | Geological stratigraphy survey, discovering Shorty Crater Orange Volcanic Glass (#74220), sampling Plutonic Troctolite (#76535), and planting explosive geophone sensors. | 300 Coins / 900 XP |
| **06** | **STS-31: Hubble Deployment** | Low Earth Orbit (612 km) | High orbital insertion, payload bay door opening, robotic arm grapple unlatch of Hubble Space Telescope, solar wing unfurling, and stand-off separation. | 350 Coins / 1050 XP |
| **07** | **STS-61: Hubble Servicing** | HST Servicing Berth | Orbital rendezvous, berthing capture, zero-gravity EVA spacewalk on safety tether, replacing WFPC2 optical box, and telemetry verification. | 400 Coins / 1200 XP |
| **08** | **STS-88: Space Station Assembly** | LEO (390 km, 51.6° inc) | Transporting Unity Node 1, rendezvous and APDS docking with Zarya FGB module, zero-g spacewalk to connect external power and data umbilicals. | 450 Coins / 1350 XP |
| **09** | **OSIRIS-REx: Bennu Sample Operation** | Asteroid (101955) Bennu | *Uncrewed Robotic Console:* Asteroid recon orbit, Nightingale crater approach, 5-second Touch-and-Go (TAG) nitrogen burst, regolith capture, SRC capsule stowage. | 500 Coins / 1600 XP |
| **10** | **Perseverance: Mars Expedition** | Mars — Jezero Crater | *Fictional Training Simulation Inspired by NASA Mars Science:* Atmospheric EDL, egress in pressurized Mars bio-suit, rover trekking across river delta, drilling and sealing 3 core sample tubes, caching in depot. | 600 Coins / 2000 XP + Trophy |

---

## 🛰️ NASA Scientific Data Integration & Citations

The project integrates eight verified NASA scientific data sources, recorded in `NasaDatasetEntry` and presented in the interactive **NASA Data & Credits** screen:

1. **NASA Planetary Fact Sheet** (NASA GSFC): Verified surface gravities (Earth 9.81, Moon 1.62, Mars 3.72, Bennu 0.00006 m/s²), atmospheric pressures, and temperatures driving the real-time flight physics engine.
2. **JPL Horizons Ephemeris System** (NASA JPL): Planetary positions, transfer trajectory distances, and inertial navigation coordinates for Earth-Moon, LEO, Mars, and Asteroid Bennu.
3. **NASA 3D Resources** (NASA Science): Reference dimensions, silhouettes, and staging mass distributions for Apollo, Lunar Module, LRV, Hubble, OSIRIS-REx, and Perseverance.
4. **NASA Image and Video Library** (NASA HQ): Official mission media IDs (AS11-40-5903, AS08-14-2383 Earthrise, STS-31 deploy sequences) powering cinematic video backdrops.
5. **NASA Planetary Data System (PDS)** (PDS Geosciences Node): Exact lunar petrology classifications, including Mare Basalt #10017, Genesis Rock #15415, and Orange Soil #74220.
6. **LRO–LOLA Topography** (LRO LOLA Science Team): Lunar elevation profiles, crater slope gradients, and obstacle heights across Shackleton, Fra Mauro, and Hadley Rille.
7. **NASA DONKI Space Weather Database** (CCMC / NASA GSFC): Solar Energetic Particle (SEP) flux and solar storm hazard thresholds scaling radiation warning alerts.
8. **NASA/JPL SPICE System** (NAIF / JPL): Prepared trajectory state vectors and docking approach cones guiding orbital flight telemetry HUDs.

---

## 🕹️ Controls Reference

| Action | Desktop Keyboard & Mouse | Mobile / Tablet Touch Controls |
|:---|:---|:---|
| **Move Astronaut / Drive Rover** | `W`, `A`, `S`, `D` or Arrow Keys | Left Virtual 360° Analog Joystick |
| **Run / High-Speed Stride** | `Shift` + Direction | Joystick pushed beyond 50% radius |
| **Jump / Vertical EVA Thrust** | `Spacebar` | On-screen **JUMP [SPACE]** Button |
| **Interact / Airlock / Rover Mount** | `E` Key | On-screen **INTERACT [E]** Button / Tap Prompt |
| **Collect Sample / Core Drill** | `F` Key | On-screen **COLLECT [F]** Button / Tap Prompt |
| **Open Field Bag / Inventory** | `B` or `I` Key | Top HUD Backpack Icon |
| **Pause Mission** | `Escape` Key | Top HUD Pause Icon |
| **Spacecraft Throttle** | Telemetry Slider / Keyboard | Interactive Slider Bar (0% – 100%) |
| **Attitude Pitch & Yaw** | Rotate Buttons | Dedicated On-Screen Pitch Controls |
| **SAS Gyro Auto-Stabilizer** | Toggle Button | Dedicated SAS ON/OFF Button |
| **Landing Gear Toggle** | Gear Button | Dedicated GEAR UP/DOWN Button |

---

## 🧪 Automated Test Suite

A comprehensive test suite in `test/astravia_systems_test.dart` and `test/widget_test.dart` validates all core game systems:

* **Campaign Progression & Economy:** Level unlocking prerequisites, reward idempotency, replay reward scaling (25%), campaign victory trigger, and XP rank isolation.
* **Spacecraft Builder:** Mass summation, propellant calculation, Earth TWR formulas, and preflight validation checks (missing heat shield, missing parachutes, weak TWR).
* **Astronaut Customization:** Profile serialization, cosmetic persistence across restarts, and character model selection.
* **Inventory Bag Management:** Strict weight capacity limits (15.0 kg), overflow prevention, and safe transfer to vehicle vaults.
* **NASA Scientific Data Verification:** Verified integrity of all 8 NASA sources, URLs, SI units, and planetary constants.

To execute tests:
```bash
flutter test
```

---

## 📦 How to Build and Run

### Run Locally (Desktop / Chrome / Mobile Emulator)
```bash
flutter pub get
flutter run
```

### Build Android Release APK
```bash
flutter build apk --release
```

---

## 📄 License & Attribution
* **Engine & Game Code:** MIT License. Developed for the **NASA International Space Apps Challenge 2026**.
* **NASA Assets & Data:** Used under the NASA Open Data Policy and Public Domain Media Guidelines.
