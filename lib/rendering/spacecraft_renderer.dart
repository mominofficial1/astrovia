import 'package:flutter/material.dart';
import '../models/spacecraft_model.dart';
import '../theme/astrovia_theme.dart';

class SpacecraftWidget extends StatelessWidget {
  final SpacecraftBuild buildData;
  final double scale;
  final double throttle; // 0.0 to 1.0
  final bool isRcsFiring;
  final bool landingLegsExtended;
  final bool solarPanelsDeployed;
  final bool hatchOpen;
  final int missionLevel;

  const SpacecraftWidget({
    super.key,
    required this.buildData,
    this.scale = 1.0,
    this.throttle = 0.0,
    this.isRcsFiring = false,
    this.landingLegsExtended = true,
    this.solarPanelsDeployed = true,
    this.hatchOpen = false,
    this.missionLevel = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: CustomPaint(
        size: const Size(150, 230),
        painter: SpacecraftPainter(
          buildData: buildData,
          throttle: throttle,
          isRcsFiring: isRcsFiring,
          landingLegsExtended: landingLegsExtended,
          solarPanelsDeployed: solarPanelsDeployed,
          hatchOpen: hatchOpen,
          missionLevel: missionLevel,
        ),
      ),
    );
  }
}

class SpacecraftPainter extends CustomPainter {
  final SpacecraftBuild buildData;
  final double throttle;
  final bool isRcsFiring;
  final bool landingLegsExtended;
  final bool solarPanelsDeployed;
  final bool hatchOpen;
  final int missionLevel;

  SpacecraftPainter({
    required this.buildData,
    required this.throttle,
    required this.isRcsFiring,
    required this.landingLegsExtended,
    required this.solarPanelsDeployed,
    this.hatchOpen = false,
    this.missionLevel = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);

    // Choose specialized renderer for mission vehicle family:
    if (missionLevel == 6 || missionLevel == 7 || missionLevel == 8) {
      // Space Shuttle Orbiter (STS-31, STS-61, STS-88)
      _drawSpaceShuttleOrbiter(canvas);
    } else if (missionLevel == 9) {
      // OSIRIS-REx robotic deep space probe
      _drawOsirisRexProbe(canvas);
    } else if (missionLevel >= 2 && missionLevel <= 5) {
      // Apollo Lunar Module (LEM)
      _drawApolloLunarModule(canvas);
    } else {
      // Standard Modular Rocket / Apollo CSM (Level 1, 10, and custom builder)
      _drawModularRocket(canvas);
    }

    // Engine exhaust plume when throttle is active
    if (throttle > 0.0) {
      _drawEngineExhaustPlume(canvas);
    }

    canvas.restore();
  }

  // -------------------------------------------------------------
  // 1. APOLLO LUNAR MODULE (LEM) - Levels 2, 3, 4, 5
  // -------------------------------------------------------------
  void _drawApolloLunarModule(Canvas canvas) {
    // 1. Landing Legs with footpads (Gold pads, titanium struts)
    if (landingLegsExtended) {
      final strutPaint = Paint()
        ..color = const Color(0xFFB0BEC5)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      final padPaint = Paint()..color = AstroviaTheme.gold;

      // Left leg
      canvas.drawLine(const Offset(-25, 40), const Offset(-55, 75), strutPaint);
      canvas.drawCircle(const Offset(-55, 75), 6.0, padPaint);

      // Right leg
      canvas.drawLine(const Offset(25, 40), const Offset(55, 75), strutPaint);
      canvas.drawCircle(const Offset(55, 75), 6.0, padPaint);

      // Forward ladder leg
      canvas.drawLine(const Offset(0, 42), const Offset(0, 78), strutPaint);
      canvas.drawCircle(const Offset(0, 78), 6.5, padPaint);

      // Ladder rungs
      final ladderPaint = Paint()
        ..color = const Color(0xFFECEFF1)
        ..strokeWidth = 2.0;
      for (double ly = 46; ly <= 74; ly += 6.0) {
        canvas.drawLine(Offset(-6, ly), Offset(6, ly), ladderPaint);
      }
    }

    // 2. Descent Stage: Gold Kapton Foil Octagonal Base
    final descentPaint = Paint()..color = const Color(0xFFD4AF37); // Gold Kapton foil
    final descentRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-32, 12, 64, 34),
      const Radius.circular(3),
    );
    canvas.drawRRect(descentRect, descentPaint);
    // Crinkled foil highlights
    final foilLine = Paint()
      ..color = const Color(0xFFFFE082).withValues(alpha: 0.6)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(-30, 20), const Offset(30, 20), foilLine);
    canvas.drawLine(const Offset(-28, 30), const Offset(28, 30), foilLine);
    canvas.drawLine(const Offset(-10, 12), const Offset(-10, 46), foilLine);
    canvas.drawLine(const Offset(10, 12), const Offset(10, 46), foilLine);

    // Modular Equipment Scientific Assembly (MESA) pallet
    final mesaPaint = Paint()..color = const Color(0xFF37474F);
    canvas.drawRect(const Rect.fromLTWH(-28, 22, 14, 16), mesaPaint);

    // 3. Ascent Stage: Black & Grey cockpit with triangular docking windows
    final ascentPaint = Paint()..color = const Color(0xFF263238);
    final ascentPath = Path()
      ..moveTo(-26, 12)
      ..lineTo(-30, -18)
      ..lineTo(-18, -36)
      ..lineTo(18, -36)
      ..lineTo(30, -18)
      ..lineTo(26, 12)
      ..close();
    canvas.drawPath(ascentPath, ascentPaint);

    // Triangulated cock-pit windows
    final windowPaint = Paint()..color = AstroviaTheme.cyan.withValues(alpha: 0.85);
    _drawPolygon(canvas, [const Offset(-16, -24), const Offset(-8, -30), const Offset(-8, -20)], windowPaint);
    _drawPolygon(canvas, [const Offset(16, -24), const Offset(8, -30), const Offset(8, -20)], windowPaint);

    // Overhead rendezvous window
    canvas.drawRect(const Rect.fromLTWH(-5, -34, 10, 5), windowPaint);

    // 4. Egress Hatch & Airlock Chamber
    if (hatchOpen) {
      // Open hatch: illuminated interior airlock
      final chamberPaint = Paint()..color = AstroviaTheme.cyan.withValues(alpha: 0.4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-11, -8, 22, 20), const Radius.circular(3)),
        chamberPaint,
      );
      // Open door swinging forward
      final doorPaint = Paint()
        ..color = const Color(0xFF78909C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawLine(const Offset(-11, -8), const Offset(-24, 0), doorPaint);
      // Status indicator green
      canvas.drawCircle(const Offset(0, -12), 2.5, Paint()..color = AstroviaTheme.green);
    } else {
      // Sealed rectangular egress hatch
      final hatchPaint = Paint()..color = const Color(0xFF455A64);
      final hatchBorder = Paint()
        ..color = AstroviaTheme.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final hatchRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, -6, 20, 18),
        const Radius.circular(3),
      );
      canvas.drawRRect(hatchRect, hatchPaint);
      canvas.drawRRect(hatchRect, hatchBorder);
      // Hatch latch handle
      canvas.drawLine(const Offset(-4, 3), const Offset(4, 3), Paint()..color = Colors.white..strokeWidth = 1.5);
      // Status indicator cyan
      canvas.drawCircle(const Offset(0, -10), 2.0, Paint()..color = AstroviaTheme.cyan);
    }

    // 5. Reaction Control Thruster Quads
    _drawRcsQuadBlock(canvas, const Offset(-30, -8));
    _drawRcsQuadBlock(canvas, const Offset(30, -8));
  }

  // -------------------------------------------------------------
  // 2. SPACE SHUTTLE ORBITER (STS-31, STS-61, STS-88)
  // -------------------------------------------------------------
  void _drawSpaceShuttleOrbiter(Canvas canvas) {
    // 1. Delta wings with black thermal protection tiles
    final wingPath = Path()
      ..moveTo(0, -60) // Nose tip
      ..lineTo(-18, -10)
      ..lineTo(-54, 45) // Left wingtip
      ..lineTo(-26, 45)
      ..lineTo(-26, 55)
      ..lineTo(26, 55)
      ..lineTo(26, 45)
      ..lineTo(54, 45) // Right wingtip
      ..lineTo(18, -10)
      ..close();

    // Black tile bottom / white top
    canvas.drawPath(wingPath, Paint()..color = const Color(0xFFECEFF1));
    canvas.drawPath(wingPath, Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // 2. Black cockpit nose cone
    final nosePath = Path()
      ..moveTo(0, -60)
      ..lineTo(-10, -42)
      ..lineTo(10, -42)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFF1E293B));

    // Flight deck windshield windows
    final glassPaint = Paint()..color = AstroviaTheme.cyan;
    _drawPolygon(canvas, [const Offset(-7, -40), const Offset(-2, -44), const Offset(-2, -38)], glassPaint);
    _drawPolygon(canvas, [const Offset(7, -40), const Offset(2, -44), const Offset(2, -38)], glassPaint);

    // 3. Payload Cargo Bay
    if (hatchOpen) {
      // Open cargo bay doors revealing payload & Remote Manipulator Arm
      final bayPaint = Paint()..color = const Color(0xFF263238);
      canvas.drawRect(const Rect.fromLTWH(-16, -26, 32, 58), bayPaint);

      // Open radiator doors folded outward
      final doorPaint = Paint()
        ..color = const Color(0xFFB0BEC5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawLine(const Offset(-16, -26), const Offset(-28, -15), doorPaint);
      canvas.drawLine(const Offset(-28, -15), const Offset(-28, 25), doorPaint);
      canvas.drawLine(const Offset(16, -26), const Offset(28, -15), doorPaint);
      canvas.drawLine(const Offset(28, -15), const Offset(28, 25), doorPaint);

      // Remote Manipulator System (Canadarm robot arm)
      final armPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(-14, -20), const Offset(-18, 0), armPaint);
      canvas.drawLine(const Offset(-18, 0), const Offset(-4, 12), armPaint);
      canvas.drawCircle(const Offset(-4, 12), 3.5, Paint()..color = AstroviaTheme.cyan);
    } else {
      // Closed white cargo bay doors
      final bayPaint = Paint()..color = const Color(0xFFCFD8DC);
      final bayRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-16, -26, 32, 58), const Radius.circular(2));
      canvas.drawRRect(bayRect, bayPaint);
      // Center seam line
      canvas.drawLine(const Offset(0, -26), const Offset(0, 32), Paint()..color = const Color(0xFF78909C)..strokeWidth = 1.2);
    }

    // 4. Vertical Tail Fin & Orbital Maneuvering Pods
    final tailPaint = Paint()..color = const Color(0xFFB0BEC5);
    _drawPolygon(canvas, [const Offset(0, 20), const Offset(-3, 56), const Offset(3, 56)], tailPaint);
  }

  void _drawPolygon(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.isEmpty) return;
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // -------------------------------------------------------------
  // 3. OSIRIS-REx ROBOTIC PROBE (Level 9)
  // -------------------------------------------------------------
  void _drawOsirisRexProbe(Canvas canvas) {
    // Dual solar array wings
    final wingPaint = Paint()..color = const Color(0xFF0D47A1);
    final gridPaint = Paint()
      ..color = AstroviaTheme.cyan.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRect(const Rect.fromLTWH(-68, -12, 44, 24), wingPaint);
    canvas.drawRect(const Rect.fromLTWH(-68, -12, 44, 24), gridPaint);
    canvas.drawRect(const Rect.fromLTWH(24, -12, 44, 24), wingPaint);
    canvas.drawRect(const Rect.fromLTWH(24, -12, 44, 24), gridPaint);

    // Hexagonal deep-space bus
    final busPaint = Paint()..color = const Color(0xFF546E7A);
    final busPath = Path()
      ..moveTo(0, -32)
      ..lineTo(22, -18)
      ..lineTo(22, 18)
      ..lineTo(0, 32)
      ..lineTo(-22, 18)
      ..lineTo(-22, -18)
      ..close();
    canvas.drawPath(busPath, busPaint);

    // High-Gain Antenna dish
    final dishPaint = Paint()
      ..color = const Color(0xFFECEFF1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawArc(const Rect.fromLTWH(-16, -44, 32, 18), 0.2, 2.7, false, dishPaint);
    canvas.drawLine(const Offset(0, -35), const Offset(0, -42), Paint()..color = AstroviaTheme.gold..strokeWidth = 1.5);

    // TAGSAM (Touch-and-Go Sample Acquisition Mechanism) articulated arm
    final tagPaint = Paint()
      ..color = const Color(0xFFECEFF1)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 24), const Offset(0, 48), tagPaint);
    canvas.drawLine(const Offset(0, 48), const Offset(12, 60), tagPaint);
    // Nitrogen sample cylinder head
    canvas.drawCircle(const Offset(12, 60), 5.5, Paint()..color = AstroviaTheme.cyan);

    // Sample Return Capsule (SRC) on bus deck
    final srcPaint = Paint()..color = const Color(0xFFD4AF37);
    canvas.drawCircle(const Offset(0, 0), 10.0, srcPaint);
  }

  // -------------------------------------------------------------
  // 4. MODULAR ROCKET / APOLLO CSM (Level 1, 10, Builder)
  // -------------------------------------------------------------
  void _drawModularRocket(Canvas canvas) {
    if (solarPanelsDeployed && buildData.hasCategory(ComponentCategory.solarArray)) {
      _drawSolarPanels(canvas);
    }

    if (buildData.hasCategory(ComponentCategory.booster)) {
      _drawBoosterStraps(canvas);
    }

    if (buildData.hasCategory(ComponentCategory.propellantTank)) {
      _drawPropellantTanks(canvas);
    }

    if (buildData.hasCategory(ComponentCategory.separator)) {
      _drawSeparator(canvas);
    }

    _drawCapsuleOrPayload(canvas);

    if (buildData.hasCategory(ComponentCategory.landingLegs)) {
      _drawLandingLegs(canvas);
    }

    if (buildData.hasCategory(ComponentCategory.dockingPort)) {
      _drawDockingPort(canvas);
    }

    if (buildData.hasCategory(ComponentCategory.rcsThruster)) {
      _drawRcsBlocks(canvas);
    }
  }

  void _drawSolarPanels(Canvas canvas) {
    final panelPaint = Paint()..color = const Color(0xFF0D47A1);
    final gridPaint = Paint()
      ..color = AstroviaTheme.cyan.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final leftRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-68, -20, 46, 18), const Radius.circular(2));
    canvas.drawRRect(leftRect, panelPaint);
    canvas.drawRRect(leftRect, gridPaint);

    final rightRect = RRect.fromRectAndRadius(const Rect.fromLTWH(22, -20, 46, 18), const Radius.circular(2));
    canvas.drawRRect(rightRect, panelPaint);
    canvas.drawRRect(rightRect, gridPaint);
  }

  void _drawBoosterStraps(Canvas canvas) {
    final boosterPaint = Paint()..color = const Color(0xFFECEFF1);
    final leftRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-32, 10, 10, 65), const Radius.circular(3));
    canvas.drawRRect(leftRect, boosterPaint);
    final rightRect = RRect.fromRectAndRadius(const Rect.fromLTWH(22, 10, 10, 65), const Radius.circular(3));
    canvas.drawRRect(rightRect, boosterPaint);
  }

  void _drawPropellantTanks(Canvas canvas) {
    final tankPaint = Paint()..color = const Color(0xFFCFD8DC);
    final borderPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final tankRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-18, -10, 36, 80), const Radius.circular(4));
    canvas.drawRRect(tankRect, tankPaint);
    canvas.drawRRect(tankRect, borderPaint);

    final stripePaint = Paint()..color = const Color(0xFFD32F2F);
    canvas.drawRect(const Rect.fromLTWH(-18, 20, 36, 4), stripePaint);
  }

  void _drawSeparator(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(-19, 12, 38, 5), Paint()..color = const Color(0xFF263238));
  }

  void _drawCapsuleOrPayload(Canvas canvas) {
    final capsulePaint = Paint()..color = const Color(0xFFECEFF1);
    final strokePaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final cone = Path()
      ..moveTo(-18, -10)
      ..lineTo(-8, -48)
      ..lineTo(8, -48)
      ..lineTo(18, -10)
      ..close();
    canvas.drawPath(cone, capsulePaint);
    canvas.drawPath(cone, strokePaint);

    if (hatchOpen) {
      canvas.drawRect(const Rect.fromLTWH(-6, -34, 12, 14), Paint()..color = AstroviaTheme.cyan.withValues(alpha: 0.5));
    } else {
      canvas.drawCircle(const Offset(0, -28), 4.0, Paint()..color = AstroviaTheme.cyan);
    }
  }

  void _drawLandingLegs(Canvas canvas) {
    final legPaint = Paint()
      ..color = const Color(0xFF78909C)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final padPaint = Paint()..color = AstroviaTheme.gold;

    if (landingLegsExtended) {
      canvas.drawLine(const Offset(-16, 65), const Offset(-36, 85), legPaint);
      canvas.drawCircle(const Offset(-36, 85), 3.5, padPaint);
      canvas.drawLine(const Offset(16, 65), const Offset(36, 85), legPaint);
      canvas.drawCircle(const Offset(36, 85), 3.5, padPaint);
    }
  }

  void _drawDockingPort(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(-6, -54, 12, 6), Paint()..color = const Color(0xFF90A4AE));
    canvas.drawCircle(const Offset(0, -51), 3.5, Paint()..color = AstroviaTheme.gold..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  void _drawRcsBlocks(Canvas canvas) {
    final rcsPaint = Paint()..color = const Color(0xFF37474F);
    canvas.drawRect(const Rect.fromLTWH(-20, -18, 3, 5), rcsPaint);
    canvas.drawRect(const Rect.fromLTWH(17, -18, 3, 5), rcsPaint);

    if (isRcsFiring) {
      final plumePaint = Paint()..color = AstroviaTheme.cyan.withValues(alpha: 0.8);
      canvas.drawCircle(const Offset(-23, -15), 3.0, plumePaint);
      canvas.drawCircle(const Offset(20, -15), 3.0, plumePaint);
    }
  }

  void _drawRcsQuadBlock(Canvas canvas, Offset pos) {
    canvas.drawRect(Rect.fromCenter(center: pos, width: 6, height: 6), Paint()..color = const Color(0xFF9E9E9E));
    if (isRcsFiring) {
      canvas.drawCircle(pos, 5.0, Paint()..color = AstroviaTheme.cyan.withValues(alpha: 0.6));
    }
  }

  void _drawEngineExhaustPlume(Canvas canvas) {
    final plumeLen = 25.0 + (throttle * 45.0);
    final corePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFF9DB),
          const Color(0xFFFF9100),
          AstroviaTheme.cyan.withValues(alpha: 0.8),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(-12, 68, 24, plumeLen));

    final flamePath = Path()
      ..moveTo(-10, 68)
      ..quadraticBezierTo(0, 68 + plumeLen, 10, 68)
      ..close();
    canvas.drawPath(flamePath, corePaint);
  }

  @override
  bool shouldRepaint(covariant SpacecraftPainter oldDelegate) {
    return oldDelegate.throttle != throttle ||
        oldDelegate.isRcsFiring != isRcsFiring ||
        oldDelegate.landingLegsExtended != landingLegsExtended ||
        oldDelegate.solarPanelsDeployed != solarPanelsDeployed ||
        oldDelegate.hatchOpen != hatchOpen ||
        oldDelegate.missionLevel != missionLevel;
  }
}
