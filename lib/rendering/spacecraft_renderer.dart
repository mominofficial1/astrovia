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

  const SpacecraftWidget({
    super.key,
    required this.buildData,
    this.scale = 1.0,
    this.throttle = 0.0,
    this.isRcsFiring = false,
    this.landingLegsExtended = true,
    this.solarPanelsDeployed = true,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: CustomPaint(
        size: const Size(140, 220),
        painter: SpacecraftPainter(
          buildData: buildData,
          throttle: throttle,
          isRcsFiring: isRcsFiring,
          landingLegsExtended: landingLegsExtended,
          solarPanelsDeployed: solarPanelsDeployed,
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

  SpacecraftPainter({
    required this.buildData,
    required this.throttle,
    required this.isRcsFiring,
    required this.landingLegsExtended,
    required this.solarPanelsDeployed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);

    // 1. Solar Panels (drawn behind vehicle body)
    if (solarPanelsDeployed && buildData.hasCategory(ComponentCategory.solarArray)) {
      _drawSolarPanels(canvas);
    }

    // 2. Main Stage 1 Core Body & Boosters
    if (buildData.hasCategory(ComponentCategory.booster)) {
      _drawBoosterStraps(canvas);
    }

    if (buildData.hasCategory(ComponentCategory.propellantTank)) {
      _drawPropellantTanks(canvas);
    }

    // 3. Interstage & Separator
    if (buildData.hasCategory(ComponentCategory.separator)) {
      _drawSeparator(canvas);
    }

    // 4. Payload / Capsule / Cockpit
    _drawCapsuleOrPayload(canvas);

    // 5. Landing Legs (if lander has them)
    if (buildData.hasCategory(ComponentCategory.landingLegs)) {
      _drawLandingLegs(canvas);
    }

    // 6. Docking Port / RCS
    if (buildData.hasCategory(ComponentCategory.dockingPort)) {
      _drawDockingPort(canvas);
    }

    if (buildData.hasCategory(ComponentCategory.rcsThruster)) {
      _drawRcsBlocks(canvas);
    }

    // 7. Engine Plumes
    if (throttle > 0.0) {
      _drawEngineExhaustPlume(canvas);
    }

    canvas.restore();
  }

  void _drawSolarPanels(Canvas canvas) {
    final panelPaint = Paint()..color = const Color(0xFF0D47A1);
    final gridPaint = Paint()
      ..color = AstroviaTheme.cyan.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Left Wing
    final leftRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-68, -20, 46, 18),
      const Radius.circular(2),
    );
    canvas.drawRRect(leftRect, panelPaint);
    canvas.drawRRect(leftRect, gridPaint);

    // Solar cells grid
    for (int i = 1; i <= 3; i++) {
      canvas.drawLine(
        Offset(-68 + i * 11.5, -20),
        Offset(-68 + i * 11.5, -2),
        gridPaint,
      );
    }

    // Right Wing
    final rightRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(22, -20, 46, 18),
      const Radius.circular(2),
    );
    canvas.drawRRect(rightRect, panelPaint);
    canvas.drawRRect(rightRect, gridPaint);

    for (int i = 1; i <= 3; i++) {
      canvas.drawLine(
        Offset(22 + i * 11.5, -20),
        Offset(22 + i * 11.5, -2),
        gridPaint,
      );
    }
  }

  void _drawBoosterStraps(Canvas canvas) {
    final boosterPaint = Paint()..color = const Color(0xFFECEFF1);
    final nosePaint = Paint()..color = const Color(0xFFB0BEC5);

    // Left Booster
    final leftRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-32, 10, 10, 65),
      const Radius.circular(3),
    );
    canvas.drawRRect(leftRect, boosterPaint);

    final leftNose = Path()
      ..moveTo(-32, 10)
      ..lineTo(-27, 2)
      ..lineTo(-22, 10)
      ..close();
    canvas.drawPath(leftNose, nosePaint);

    // Right Booster
    final rightRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(22, 10, 10, 65),
      const Radius.circular(3),
    );
    canvas.drawRRect(rightRect, boosterPaint);

    final rightNose = Path()
      ..moveTo(22, 10)
      ..lineTo(27, 2)
      ..lineTo(32, 10)
      ..close();
    canvas.drawPath(rightNose, nosePaint);
  }

  void _drawPropellantTanks(Canvas canvas) {
    final tankPaint = Paint()..color = const Color(0xFFCFD8DC);
    final borderPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Central cylindrical fuselage
    final tankRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-18, -10, 36, 80),
      const Radius.circular(4),
    );
    canvas.drawRRect(tankRect, tankPaint);
    canvas.drawRRect(tankRect, borderPaint);

    // NASA worm / stripe accent
    final stripePaint = Paint()..color = const Color(0xFFD32F2F);
    canvas.drawRect(const Rect.fromLTWH(-18, 20, 36, 4), stripePaint);

    // Cryogenic tank ribbing lines
    final ribPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(-18, 40), const Offset(18, 40), ribPaint);
    canvas.drawLine(const Offset(-18, 60), const Offset(18, 60), ribPaint);
  }

  void _drawSeparator(Canvas canvas) {
    final sepPaint = Paint()..color = const Color(0xFF263238);
    canvas.drawRect(const Rect.fromLTWH(-19, 12, 38, 5), sepPaint);
  }

  void _drawCapsuleOrPayload(Canvas canvas) {
    final capsulePaint = Paint()..color = const Color(0xFFECEFF1);
    final strokePaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Conical Command Module
    final cone = Path()
      ..moveTo(-18, -10)
      ..lineTo(-8, -48)
      ..lineTo(8, -48)
      ..lineTo(18, -10)
      ..close();
    canvas.drawPath(cone, capsulePaint);
    canvas.drawPath(cone, strokePaint);

    // Capsule hatch window
    canvas.drawCircle(
      const Offset(0, -28),
      4.0,
      Paint()..color = AstroviaTheme.cyan,
    );

    // Heat shield base
    if (buildData.hasCategory(ComponentCategory.thermalHeatShield)) {
      final hsPaint = Paint()..color = const Color(0xFFBF360C);
      canvas.drawRect(const Rect.fromLTWH(-18, -11, 36, 3), hsPaint);
    }
  }

  void _drawLandingLegs(Canvas canvas) {
    final legPaint = Paint()
      ..color = const Color(0xFF78909C)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final padPaint = Paint()..color = AstroviaTheme.gold;

    if (landingLegsExtended) {
      // Left leg
      canvas.drawLine(const Offset(-16, 65), const Offset(-36, 85), legPaint);
      canvas.drawLine(const Offset(-36, 85), const Offset(-42, 85), legPaint);
      canvas.drawCircle(const Offset(-42, 85), 3.5, padPaint);

      // Right leg
      canvas.drawLine(const Offset(16, 65), const Offset(36, 85), legPaint);
      canvas.drawLine(const Offset(36, 85), const Offset(42, 85), legPaint);
      canvas.drawCircle(const Offset(42, 85), 3.5, padPaint);
    } else {
      // Folded legs
      canvas.drawLine(const Offset(-18, 40), const Offset(-18, 75), legPaint);
      canvas.drawLine(const Offset(18, 40), const Offset(18, 75), legPaint);
    }
  }

  void _drawDockingPort(Canvas canvas) {
    final portPaint = Paint()..color = const Color(0xFF90A4AE);
    final ringPaint = Paint()
      ..color = AstroviaTheme.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRect(const Rect.fromLTWH(-6, -54, 12, 6), portPaint);
    canvas.drawCircle(const Offset(0, -51), 3.5, ringPaint);
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

  void _drawEngineExhaustPlume(Canvas canvas) {
    final plumeLen = 25.0 + (throttle * 45.0);

    // Inner bright core
    final corePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          AstroviaTheme.cyan,
          AstroviaTheme.blue.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(-10, 70, 20, plumeLen));

    final plumePath = Path()
      ..moveTo(-8, 70)
      ..lineTo(0, 70 + plumeLen)
      ..lineTo(8, 70)
      ..close();
    canvas.drawPath(plumePath, corePaint);

    // Outer plasma flare
    final flarePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AstroviaTheme.gold.withValues(alpha: 0.8),
          Colors.orange.withValues(alpha: 0.4),
          Colors.red.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(-16, 70, 32, plumeLen * 1.3));

    final flarePath = Path()
      ..moveTo(-14, 70)
      ..lineTo(0, 70 + (plumeLen * 1.3))
      ..lineTo(14, 70)
      ..close();
    canvas.drawPath(flarePath, flarePaint);
  }

  @override
  bool shouldRepaint(covariant SpacecraftPainter oldDelegate) {
    return oldDelegate.throttle != throttle ||
        oldDelegate.isRcsFiring != isRcsFiring ||
        oldDelegate.landingLegsExtended != landingLegsExtended ||
        oldDelegate.solarPanelsDeployed != solarPanelsDeployed ||
        oldDelegate.buildData != buildData;
  }
}
