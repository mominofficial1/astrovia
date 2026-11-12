import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/planetary_data.dart';
import '../theme/astrovia_theme.dart';

/// High-fidelity procedural planetary and orbital real-time environment renderer.
/// Renders authentic celestial bodies, horizons, terrain relief, starfields, and atmospheric
/// scattering based on NASA planetary facts and destination specifications without video playback.
class PlanetaryEnvironmentWidget extends StatelessWidget {
  final PlanetaryData planetaryData;
  final int levelNumber;
  final Offset cameraOffset;
  final double animationTime;
  final bool isOrbital;
  final Widget? child;

  const PlanetaryEnvironmentWidget({
    super.key,
    required this.planetaryData,
    required this.levelNumber,
    this.cameraOffset = Offset.zero,
    this.animationTime = 0.0,
    this.isOrbital = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PlanetaryEnvironmentPainter(
        planetaryData: planetaryData,
        levelNumber: levelNumber,
        cameraOffset: cameraOffset,
        animationTime: animationTime,
        isOrbital: isOrbital,
      ),
      child: child,
    );
  }
}

class PlanetaryEnvironmentPainter extends CustomPainter {
  final PlanetaryData planetaryData;
  final int levelNumber;
  final Offset cameraOffset;
  final double animationTime;
  final bool isOrbital;

  PlanetaryEnvironmentPainter({
    required this.planetaryData,
    required this.levelNumber,
    required this.cameraOffset,
    required this.animationTime,
    required this.isOrbital,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (isOrbital || levelNumber == 1 || levelNumber == 6 || levelNumber == 7 || levelNumber == 8 || levelNumber == 9) {
      _paintOrbitalScene(canvas, size);
    } else if (levelNumber == 10 || planetaryData.name == "Mars") {
      _paintMarsSurfaceScene(canvas, size);
    } else {
      // Lunar surface (Apollo 11, 12, 15, 17)
      _paintLunarSurfaceScene(canvas, size);
    }
  }

  // -------------------------------------------------------------
  // 1. ORBITAL SCENE (Apollo 8, STS-31, STS-61, STS-88, Bennu)
  // -------------------------------------------------------------
  void _paintOrbitalScene(Canvas canvas, Size size) {
    // 1. Deep cosmic starfield
    _paintDeepCosmicStarfield(canvas, size);

    // 2. Earth or Celestial destination
    if (levelNumber == 1) {
      // Apollo 8: Low lunar orbit with famous Earthrise in the distance!
      _paintApollo8MoonAndEarthrise(canvas, size);
    } else if (levelNumber == 9) {
      // OSIRIS-REx: Rubble-pile asteroid Bennu in microgravity deep space
      _paintBennuAsteroid(canvas, size);
    } else {
      // STS-31, STS-61, STS-88: Low Earth Orbit with massive curved blue Earth
      _paintLowEarthOrbitGlobe(canvas, size);
    }

    // 3. Solar illumination glare
    _paintSunGlare(canvas, size, const Offset(0.85, 0.15));
  }

  void _paintApollo8MoonAndEarthrise(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;

    // Curved lunar surface horizon at bottom
    final moonRadius = size.width * 0.95;
    final moonCenter = Offset(cx, cy + moonRadius * 0.65);

    // Lunar body base
    final moonPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.7),
        radius: 0.9,
        colors: const [
          Color(0xFF8A939E),
          Color(0xFF535A63),
          Color(0xFF2B2F36),
          Color(0xFF15181C),
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    canvas.drawCircle(moonCenter, moonRadius, moonPaint);

    // Lunar craters on curved limb
    final craterBorder = Paint()
      ..color = const Color(0xFF1E2126)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final craterRimLight = Paint()
      ..color = const Color(0xFFBAC2CB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final craters = [
      Offset(cx - 240, cy - 90),
      Offset(cx - 110, cy - 130),
      Offset(cx + 80, cy - 115),
      Offset(cx + 260, cy - 70),
      Offset(cx - 30, cy - 60),
    ];

    for (int i = 0; i < craters.length; i++) {
      final pos = craters[i];
      final r = 24.0 + (i % 3) * 14.0;
      canvas.drawOval(Rect.fromCenter(center: pos, width: r * 2, height: r * 0.8), craterBorder);
      // Bright sunlit rim on top edge
      canvas.drawArc(
        Rect.fromCenter(center: pos, width: r * 2, height: r * 0.8),
        math.pi * 0.8,
        math.pi * 0.9,
        false,
        craterRimLight,
      );
    }

    // The Radiant "Earthrise" Globe in the black sky
    final earthPos = Offset(cx + 180 + (cameraOffset.dx * 0.05), size.height * 0.28 + (cameraOffset.dy * 0.05));
    final earthRadius = 42.0;

    // Atmospheric outer glow
    final atmosphereGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF19D9FF).withValues(alpha: 0.5),
          const Color(0xFF0077B6).withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: earthPos, radius: earthRadius * 1.5));
    canvas.drawCircle(earthPos, earthRadius * 1.5, atmosphereGlow);

    // Earth marble disc
    final earthDisc = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.35),
        radius: 0.85,
        colors: [
          Color(0xFFE0F7FA), // Cloud highlight
          Color(0xFF0096C7), // Blue ocean
          Color(0xFF023E8A), // Deep oceanic trench
          Color(0xFF03071E), // Night terminator
        ],
        stops: [0.0, 0.45, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: earthPos, radius: earthRadius));
    canvas.drawCircle(earthPos, earthRadius, earthDisc);

    // Swirling white cloud bands & continents
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    final continentPaint = Paint()..color = const Color(0xFF2D6A4F).withValues(alpha: 0.6);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: earthPos, radius: earthRadius)));
    // Continents
    canvas.drawOval(Rect.fromCenter(center: earthPos + const Offset(-10, -5), width: 28, height: 22), continentPaint);
    canvas.drawOval(Rect.fromCenter(center: earthPos + const Offset(8, 12), width: 24, height: 18), continentPaint);
    // Swirling cloud spiral
    canvas.drawArc(Rect.fromCenter(center: earthPos, width: 65, height: 35), 0.2, 2.4, false, cloudPaint..strokeWidth = 3.5..style = PaintingStyle.stroke);
    canvas.drawArc(Rect.fromCenter(center: earthPos + const Offset(-4, -8), width: 45, height: 20), 1.2, 1.8, false, cloudPaint..strokeWidth = 2.5);
    canvas.restore();
  }

  void _paintLowEarthOrbitGlobe(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Earth curves across the lower half of the view
    final earthRadius = size.width * 1.2;
    final earthCenter = Offset(cx, size.height + earthRadius * 0.45);

    // 1. Blue atmospheric limb glow
    final limbGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF19D9FF).withValues(alpha: 0.6),
          const Color(0xFF0096C7).withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: earthCenter, radius: earthRadius * 1.08));
    canvas.drawCircle(earthCenter, earthRadius * 1.08, limbGlow);

    // 2. Main planet ocean surface
    final earthBody = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.6),
        radius: 0.95,
        colors: const [
          Color(0xFF48CAE4),
          Color(0xFF0077B6),
          Color(0xFF03045E),
          Color(0xFF020215),
        ],
      ).createShader(Rect.fromCircle(center: earthCenter, radius: earthRadius));
    canvas.drawCircle(earthCenter, earthRadius, earthBody);

    // 3. Continents & cloud decks
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: earthCenter, radius: earthRadius)));

    final continentPaint = Paint()..color = const Color(0xFF2B9348).withValues(alpha: 0.35);
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    // Parallax continent formations
    final landOffset = Offset(cameraOffset.dx * 0.08, 0);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 180, size.height * 0.8) + landOffset, width: 320, height: 160),
      continentPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 220, size.height * 0.85) + landOffset, width: 280, height: 180),
      continentPaint,
    );

    // Cloud swirls with animation drift
    final drift = (animationTime * 8.0) % 400.0;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - 100 + drift, size.height * 0.72), width: 380, height: 80),
      0.1,
      2.8,
      false,
      cloudPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + 80 - drift * 0.5, size.height * 0.82), width: 440, height: 95),
      0.4,
      3.0,
      false,
      cloudPaint..strokeWidth = 8.0,
    );

    canvas.restore();
  }

  void _paintBennuAsteroid(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.6;
    final bennuRadius = 160.0;
    final bennuCenter = Offset(cx + (cameraOffset.dx * 0.1), cy + (cameraOffset.dy * 0.1));

    // Rubble-pile irregular polygon silhouette
    final path = Path();
    final points = 16;
    for (int i = 0; i < points; i++) {
      final angle = (i / points) * 2 * math.pi;
      // Irregular diamond / spinning-top asteroid shape (Bennu equatorial ridge)
      final rJitter = 1.0 + (math.sin(angle * 3) * 0.12) + (math.cos(angle * 5) * 0.08);
      final r = bennuRadius * rJitter;
      final x = bennuCenter.dx + r * math.cos(angle);
      final y = bennuCenter.dy + (r * 0.82) * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Low-albedo carbonaceous dark regolith shading
    final bennuPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 0.8,
        colors: const [
          Color(0xFF4A4E54),
          Color(0xFF2C3036),
          Color(0xFF1A1C20),
          Color(0xFF0B0C0E),
        ],
      ).createShader(Rect.fromCircle(center: bennuCenter, radius: bennuRadius));
    canvas.drawPath(path, bennuPaint);

    // Surface boulders & crater field
    final boulderPaint = Paint()..color = const Color(0xFF6B7280);
    final shadowPaint = Paint()..color = const Color(0xFF0F1115);

    final boulderPositions = [
      const Offset(-40, -30),
      const Offset(30, 20),
      const Offset(-70, 10),
      const Offset(60, -40),
      const Offset(0, 45), // Nightingale crater rim
    ];

    for (final b in boulderPositions) {
      final bp = bennuCenter + b;
      canvas.drawCircle(bp, 8.0, boulderPaint);
      canvas.drawArc(Rect.fromCircle(center: bp, radius: 8.0), 0, math.pi, true, shadowPaint);
    }

    // High-tech laser telemetry targeting reticle
    final targetPaint = Paint()
      ..color = AstroviaTheme.cyan.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(bennuCenter + const Offset(0, 45), 26.0, targetPaint);
    canvas.drawLine(bennuCenter + const Offset(-35, 45), bennuCenter + const Offset(35, 45), targetPaint);
    canvas.drawLine(bennuCenter + const Offset(0, 10), bennuCenter + const Offset(0, 80), targetPaint);
  }

  // -------------------------------------------------------------
  // 2. LUNAR SURFACE SCENE (Apollo 11, 12, 15, 17)
  // -------------------------------------------------------------
  void _paintLunarSurfaceScene(Canvas canvas, Size size) {
    // 1. Jet-black sky filled with stars and glowing Earth
    _paintDeepCosmicStarfield(canvas, size, maxFractionHeight: 0.60);

    final horizonY = size.height * 0.44;

    // Distant Earth in lunar sky
    final earthPos = Offset(size.width * 0.82 + (cameraOffset.dx * 0.02), size.height * 0.16 + (cameraOffset.dy * 0.02));
    final earthPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [
          Color(0xFFE0F7FA),
          Color(0xFF0096C7),
          Color(0xFF03045E),
          Color(0xFF000000),
        ],
        stops: [0.0, 0.4, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: earthPos, radius: 24.0));
    canvas.drawCircle(earthPos, 24.0, earthPaint);
    // Earth glow
    canvas.drawCircle(
      earthPos,
      32.0,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF19D9FF).withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: earthPos, radius: 32.0)),
    );

    // 2. Distant Lunar Massifs & Apennine Mountains (Parallax layer 1)
    _paintLunarMountainRange(canvas, size, horizonY - 20, 0.05, const Color(0xFF33383F));

    // 3. Midground crater rims (Parallax layer 2)
    _paintLunarMidgroundHills(canvas, size, horizonY + 15, 0.12, const Color(0xFF4A515A));

    // 4. Foreground Lunar Regolith Plain
    final regolithRect = Rect.fromLTWH(0, horizonY + 15, size.width, size.height - horizonY);
    final regolithPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFF5D646F),
          Color(0xFF757D89),
          Color(0xFF434850),
          Color(0xFF282B30),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(regolithRect);
    canvas.drawRect(regolithRect, regolithPaint);

    // 5. Procedural craters & basalt boulders on the surface
    _paintSurfaceCraters(canvas, size, horizonY + 25, isLunar: true);

    // 6. Sunlight casting harsh low-angle shadows
    _paintSunGlare(canvas, size, const Offset(0.12, 0.18));
  }

  void _paintLunarMountainRange(Canvas canvas, Size size, double baseY, double parallaxFactor, Color color) {
    final path = Path();
    final pX = cameraOffset.dx * parallaxFactor;
    path.moveTo(0, size.height);
    path.lineTo(0, baseY);

    for (double x = 0; x <= size.width; x += 30) {
      final worldX = x - pX;
      // Majestic lunar mountains (e.g. Mt. Hadley / Taurus Massifs)
      final h = (math.sin(worldX * 0.006) * 45.0) + (math.cos(worldX * 0.015) * 25.0) + (math.sin(worldX * 0.03) * 12.0);
      path.lineTo(x, baseY - h.abs());
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  void _paintLunarMidgroundHills(Canvas canvas, Size size, double baseY, double parallaxFactor, Color color) {
    final path = Path();
    final pX = cameraOffset.dx * parallaxFactor;
    path.moveTo(0, size.height);
    path.lineTo(0, baseY);

    for (double x = 0; x <= size.width; x += 25) {
      final worldX = x - pX;
      final h = (math.sin(worldX * 0.012) * 22.0) + (math.cos(worldX * 0.028) * 14.0);
      path.lineTo(x, baseY - h.abs());
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  // -------------------------------------------------------------
  // 3. MARS SURFACE SCENE (Perseverance Expedition - Level 10)
  // -------------------------------------------------------------
  void _paintMarsSurfaceScene(Canvas canvas, Size size) {
    final horizonY = size.height * 0.46;

    // 1. Salmon-pink / Butterscotch Martian Atmosphere
    final skyRect = Rect.fromLTWH(0, 0, size.width, horizonY + 20);
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFF2B1408), // High altitude thin dark atmosphere
          Color(0xFF7A3716), // Mid atmosphere dust suspension
          Color(0xFFD46938), // Characteristic Martian butterscotch
          Color(0xFFE89A6C), // Horizon dust scatter
        ],
        stops: const [0.0, 0.35, 0.75, 1.0],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    // 2. Small Martian Moons: Phobos & Deimos in the rusty sky
    final phobosPos = Offset(size.width * 0.75 + (cameraOffset.dx * 0.01), size.height * 0.18);
    canvas.drawOval(
      Rect.fromCenter(center: phobosPos, width: 14, height: 10),
      Paint()..color = const Color(0xFF9E8A79),
    );
    final deimosPos = Offset(size.width * 0.35 + (cameraOffset.dx * 0.005), size.height * 0.12);
    canvas.drawCircle(deimosPos, 3.5, Paint()..color = const Color(0xFFC4B5A5));

    // 3. Distant Jezero Crater Delta sedimentary cliffs (Parallax 1)
    _paintMarsDeltaCliffs(canvas, size, horizonY - 15, 0.06, const Color(0xFF732E11));

    // 4. Sand dunes & Jezero sedimentary delta plain (Parallax 2)
    _paintMarsMidgroundDunes(canvas, size, horizonY + 10, 0.14, const Color(0xFF9B4019));

    // 5. Foreground Martian Soil & Basalt Plain
    final marsGroundRect = Rect.fromLTWH(0, horizonY + 10, size.width, size.height - horizonY);
    final marsGroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFFB5491C), // Red-orange iron oxide
          Color(0xFFCE5A27), // Wind-swept dunes
          Color(0xFF8C320E), // Shadowed regolith
          Color(0xFF5A1E06), // Deep crater floor
        ],
        stops: const [0.0, 0.25, 0.65, 1.0],
      ).createShader(marsGroundRect);
    canvas.drawRect(marsGroundRect, marsGroundPaint);

    // 6. Surface craters, ripple dunes, and basalt boulders
    _paintSurfaceCraters(canvas, size, horizonY + 20, isLunar: false);

    // 7. Small atmospheric dust devil particle swirling in distance
    final dustX = (size.width * 0.25 + (animationTime * 15.0) - (cameraOffset.dx * 0.2)) % size.width;
    final dustPaint = Paint()..color = const Color(0xFFFFB38A).withValues(alpha: 0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset(dustX, horizonY - 10), width: 16, height: 50), dustPaint);
  }

  void _paintMarsDeltaCliffs(Canvas canvas, Size size, double baseY, double parallaxFactor, Color color) {
    final path = Path();
    final pX = cameraOffset.dx * parallaxFactor;
    path.moveTo(0, size.height);
    path.lineTo(0, baseY);

    for (double x = 0; x <= size.width; x += 35) {
      final worldX = x - pX;
      // Step-like sedimentary delta river terraces
      final terrace = ((worldX * 0.01).floor() % 3) * 15.0;
      final h = terrace + (math.sin(worldX * 0.015) * 20.0);
      path.lineTo(x, baseY - h);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  void _paintMarsMidgroundDunes(Canvas canvas, Size size, double baseY, double parallaxFactor, Color color) {
    final path = Path();
    final pX = cameraOffset.dx * parallaxFactor;
    path.moveTo(0, size.height);
    path.lineTo(0, baseY);

    for (double x = 0; x <= size.width; x += 25) {
      final worldX = x - pX;
      // Smooth sinusoidal Martian dunes
      final h = (math.sin(worldX * 0.02) * 18.0) + (math.sin(worldX * 0.045) * 8.0);
      path.lineTo(x, baseY - h.abs());
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  // -------------------------------------------------------------
  // HELPER: Surface craters, boulders, and terrain relief
  // -------------------------------------------------------------
  void _paintSurfaceCraters(Canvas canvas, Size size, double startY, {required bool isLunar}) {
    final pX = cameraOffset.dx;
    final pY = cameraOffset.dy;

    final craterPaint = Paint()
      ..color = isLunar ? const Color(0xFF1E2126).withValues(alpha: 0.6) : const Color(0xFF4A1805).withValues(alpha: 0.6);
    final rimHighlight = Paint()
      ..color = isLunar ? const Color(0xFFA6AFBC).withValues(alpha: 0.5) : const Color(0xFFFFB38A).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Fixed procedural crater sites relative to ground
    final surfaceFeatures = [
      const Offset(80, 50),
      const Offset(220, 110),
      const Offset(380, 70),
      const Offset(520, 140),
      const Offset(680, 45),
      const Offset(840, 120),
      const Offset(-120, 80),
      const Offset(-280, 130),
    ];

    for (int i = 0; i < surfaceFeatures.length; i++) {
      final feat = surfaceFeatures[i];
      final screenX = (feat.dx - pX * 0.4) % (size.width + 400) - 200;
      final screenY = startY + feat.dy - (pY * 0.2);

      if (screenY < startY || screenY > size.height) continue;

      final w = 35.0 + (i % 3) * 20.0;
      final h = w * 0.4;
      final rect = Rect.fromCenter(center: Offset(screenX, screenY), width: w, height: h);

      // Crater bowl
      canvas.drawOval(rect, craterPaint);
      // Bright rim on top
      canvas.drawArc(rect, math.pi * 0.9, math.pi * 0.9, false, rimHighlight);

      // Associated rock / boulder nearby
      final rockX = screenX + w * 0.45;
      final rockY = screenY - 4;
      final rockPaint = Paint()..color = isLunar ? const Color(0xFF8B939E) : const Color(0xFF6B240B);
      canvas.drawCircle(Offset(rockX, rockY), 4.5, rockPaint);
      // Boulder shadow
      canvas.drawOval(
        Rect.fromCenter(center: Offset(rockX + 5, rockY + 3), width: 8, height: 3),
        Paint()..color = Colors.black.withValues(alpha: 0.5),
      );
    }
  }

  // -------------------------------------------------------------
  // HELPER: Deep cosmic starfield with twinkling
  // -------------------------------------------------------------
  void _paintDeepCosmicStarfield(Canvas canvas, Size size, {double maxFractionHeight = 1.0}) {
    // Jet black space base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * maxFractionHeight),
      Paint()..color = const Color(0xFF030509),
    );

    final starPaint = Paint()..color = Colors.white;

    // Deterministic pseudo-random star field
    final count = 120;
    for (int i = 0; i < count; i++) {
      final seedX = (math.sin(i * 19.34) * 0.5 + 0.5) * size.width;
      final seedY = (math.cos(i * 27.81) * 0.5 + 0.5) * (size.height * maxFractionHeight);

      // Parallax shift with camera
      final sx = (seedX - (cameraOffset.dx * 0.01)) % size.width;
      final sy = (seedY - (cameraOffset.dy * 0.01)) % (size.height * maxFractionHeight);

      // Star size & subtle twinkle
      final twinkle = 0.6 + 0.4 * math.sin(animationTime * 3.0 + i);
      final r = (i % 5 == 0) ? 1.8 : (i % 3 == 0 ? 1.2 : 0.8);

      starPaint.color = Colors.white.withValues(alpha: twinkle.clamp(0.2, 1.0));
      canvas.drawCircle(Offset(sx, sy), r, starPaint);
    }
  }

  // -------------------------------------------------------------
  // HELPER: Sun glare and lens flare
  // -------------------------------------------------------------
  void _paintSunGlare(Canvas canvas, Size size, Offset unitPos) {
    final sunPos = Offset(size.width * unitPos.dx, size.height * unitPos.dy);

    // Bright solar core
    canvas.drawCircle(
      sunPos,
      14.0,
      Paint()..color = const Color(0xFFFFFDF5),
    );

    // Warm radial corona flare
    final corona = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF9DB).withValues(alpha: 0.8),
          const Color(0xFFFFD166).withValues(alpha: 0.35),
          const Color(0xFF19D9FF).withValues(alpha: 0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: sunPos, radius: 95.0));
    canvas.drawCircle(sunPos, 95.0, corona);

    // Optical flare rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFF9DB).withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 4);
      final dx = math.cos(angle) * 75.0;
      final dy = math.sin(angle) * 75.0;
      canvas.drawLine(sunPos - Offset(dx, dy), sunPos + Offset(dx, dy), rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PlanetaryEnvironmentPainter oldDelegate) {
    return oldDelegate.cameraOffset != cameraOffset ||
        oldDelegate.animationTime != animationTime ||
        oldDelegate.levelNumber != levelNumber ||
        oldDelegate.isOrbital != isOrbital;
  }
}

