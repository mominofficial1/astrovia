import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/astronaut_model.dart';
import '../theme/astrovia_theme.dart';

enum AstronautAnimState {
  idle,
  walk,
  run,
  jump,
  land,
  interact,
  collect,
  zeroG,
}

class AstronautAvatarWidget extends StatelessWidget {
  final AstronautProfile profile;
  final AstronautAnimState animState;
  final double animPhase; // 0.0 to 1.0 cycle for walking/breathing
  final bool facingRight;
  final double scale;
  final bool isCarryingItem;
  final bool showHeadlampBeam;

  const AstronautAvatarWidget({
    super.key,
    required this.profile,
    this.animState = AstronautAnimState.idle,
    this.animPhase = 0.0,
    this.facingRight = true,
    this.scale = 1.0,
    this.isCarryingItem = false,
    this.showHeadlampBeam = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: (facingRight ? 1.0 : -1.0) * scale,
      scaleY: scale,
      child: CustomPaint(
        size: const Size(80, 110),
        painter: AstronautPainter(
          profile: profile,
          animState: animState,
          animPhase: animPhase,
          isCarryingItem: isCarryingItem,
          showHeadlampBeam: showHeadlampBeam,
        ),
      ),
    );
  }
}

class AstronautPainter extends CustomPainter {
  final AstronautProfile profile;
  final AstronautAnimState animState;
  final double animPhase;
  final bool isCarryingItem;
  final bool showHeadlampBeam;

  AstronautPainter({
    required this.profile,
    required this.animState,
    required this.animPhase,
    required this.isCarryingItem,
    required this.showHeadlampBeam,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.55;

    // Animation trigonometry values
    double legAngle = 0.0;
    double armAngle = 0.0;
    double bobOffset = 0.0;
    double bodyTilt = 0.0;
    double breatheOffset = math.sin(animPhase * 2 * math.pi) * 1.5;

    switch (animState) {
      case AstronautAnimState.walk:
        legAngle = math.sin(animPhase * 2 * math.pi) * 0.38;
        armAngle = -math.sin(animPhase * 2 * math.pi) * 0.35;
        bobOffset = (math.sin(animPhase * 4 * math.pi)).abs() * -4.0;
        bodyTilt = 0.05;
        break;
      case AstronautAnimState.run:
        legAngle = math.sin(animPhase * 2 * math.pi) * 0.65;
        armAngle = -math.sin(animPhase * 2 * math.pi) * 0.60;
        bobOffset = (math.sin(animPhase * 4 * math.pi)).abs() * -7.0;
        bodyTilt = 0.15;
        break;
      case AstronautAnimState.jump:
        legAngle = -0.35;
        armAngle = 0.5;
        bobOffset = -12.0;
        bodyTilt = 0.08;
        break;
      case AstronautAnimState.land:
        legAngle = 0.15;
        armAngle = 0.3;
        bobOffset = 6.0;
        bodyTilt = 0.12;
        break;
      case AstronautAnimState.collect:
      case AstronautAnimState.interact:
        legAngle = 0.1;
        armAngle = -0.85; // Reaching down
        bobOffset = 10.0;
        bodyTilt = 0.35; // Bending forward
        break;
      case AstronautAnimState.zeroG:
        legAngle = math.sin(animPhase * 2 * math.pi) * 0.15;
        armAngle = math.cos(animPhase * 2 * math.pi) * 0.20;
        bobOffset = math.sin(animPhase * 2 * math.pi) * 4.0;
        bodyTilt = -0.10;
        break;
      case AstronautAnimState.idle:
        bobOffset = breatheOffset;
        armAngle = math.sin(animPhase * 2 * math.pi) * 0.06;
        break;
    }

    canvas.save();
    canvas.translate(cx, cy + bobOffset);
    canvas.rotate(bodyTilt);

    // Headlamp Beam if toggled
    if (showHeadlampBeam) {
      _drawHeadlampBeam(canvas);
    }

    // 1. Primary Life Support Backpack (PLSS)
    _drawBackpack(canvas);

    // 2. Far Arm & Leg (Back Layer)
    _drawBackLeg(canvas, -legAngle);
    _drawBackArm(canvas, -armAngle);

    // 3. Torso / Spacesuit Core
    _drawTorso(canvas);

    // 4. Front Leg
    _drawFrontLeg(canvas, legAngle);

    // 5. Head, Helmet & Visor
    _drawHeadAndHelmet(canvas);

    // 6. Front Arm
    _drawFrontArm(canvas, armAngle);

    canvas.restore();
  }

  void _drawHeadlampBeam(Canvas canvas) {
    final beamPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AstroviaTheme.cyan.withValues(alpha: 0.35),
          AstroviaTheme.cyan.withValues(alpha: 0.0),
        ],
      ).createShader(const Rect.fromLTWH(0, -50, 180, 80));

    final beamPath = Path()
      ..moveTo(8, -32)
      ..lineTo(140, -65)
      ..lineTo(150, 10)
      ..close();

    canvas.drawPath(beamPath, beamPaint);
  }

  void _drawBackpack(Canvas canvas) {
    final packPaint = Paint()..color = const Color(0xFF37474F);
    final borderPaint = Paint()
      ..color = profile.secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Main PLSS unit attached to astronaut's back
    final packRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-28, -28, 16, 42),
      const Radius.circular(5),
    );
    canvas.drawRRect(packRect, packPaint);
    canvas.drawRRect(packRect, borderPaint);

    // Oxygen cylinders on backpack
    final o2Paint = Paint()..color = const Color(0xFFECEFF1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-25, -24, 5, 34),
        const Radius.circular(2.5),
      ),
      o2Paint,
    );

    // Pressure valve
    canvas.drawCircle(
      const Offset(-22, -18),
      2.5,
      Paint()..color = AstroviaTheme.gold,
    );

    // Cold-Gas RCS Nozzles if in zero-g or MMU
    if (animState == AstronautAnimState.zeroG) {
      final nozzlePaint = Paint()..color = const Color(0xFF263238);
      canvas.drawRect(const Rect.fromLTWH(-29, -26, 3, 4), nozzlePaint);
      canvas.drawRect(const Rect.fromLTWH(-29, 8, 3, 4), nozzlePaint);

      // Gas plume
      final gasPaint = Paint()..color = AstroviaTheme.cyan.withValues(alpha: 0.7);
      canvas.drawCircle(const Offset(-34, -24), 3.0, gasPaint);
      canvas.drawCircle(const Offset(-33, 10), 3.0, gasPaint);
    }
  }

  void _drawTorso(Canvas canvas) {
    final suitPaint = Paint()..color = profile.primaryColor;
    final strokePaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Torso suit block
    final torsoRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-14, -18, 28, 36),
      const Radius.circular(6),
    );
    canvas.drawRRect(torsoRect, suitPaint);
    canvas.drawRRect(torsoRect, strokePaint);

    // Chest pack (telemetry display and pressure controls)
    final chestPackPaint = Paint()..color = const Color(0xFF263238);
    final chestRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-8, -12, 16, 18),
      const Radius.circular(3),
    );
    canvas.drawRRect(chestRect, chestPackPaint);

    // Telemetry indicator LEDs
    canvas.drawCircle(
      const Offset(-4, -8),
      1.8,
      Paint()..color = AstroviaTheme.green,
    );
    canvas.drawCircle(
      const Offset(0, -8),
      1.8,
      Paint()..color = AstroviaTheme.cyan,
    );
    canvas.drawCircle(
      const Offset(4, -8),
      1.8,
      Paint()..color = AstroviaTheme.gold,
    );

    // Chest mission badge
    final patchPaint = Paint()..color = profile.secondaryColor;
    canvas.drawRect(const Rect.fromLTWH(-5, -2, 10, 4), patchPaint);
  }

  void _drawHeadAndHelmet(Canvas canvas) {
    final collarPaint = Paint()..color = const Color(0xFF455A64);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, -23, 20, 6),
        const Radius.circular(3),
      ),
      collarPaint,
    );

    // Helmet dome
    final helmetPaint = Paint()..color = profile.primaryColor;
    final helmetOutline = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const helmetCenter = Offset(0, -36);
    canvas.drawCircle(helmetCenter, 16, helmetPaint);
    canvas.drawCircle(helmetCenter, 16, helmetOutline);

    // Face / Hair under visor (subtle silhouette)
    final skinPaint = Paint()..color = profile.skinColor;
    canvas.drawCircle(const Offset(2, -36), 9, skinPaint);

    // Hair
    final hairPaint = Paint()..color = profile.hairColorActual;
    canvas.drawArc(
      const Rect.fromLTWH(-5, -45, 14, 12),
      math.pi,
      math.pi,
      true,
      hairPaint,
    );

    // Reflective Outer Visor
    final visorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          profile.visorColor,
          profile.visorColor.withValues(alpha: 0.65),
          AstroviaTheme.darkSpace.withValues(alpha: 0.8),
        ],
      ).createShader(const Rect.fromLTWH(-4, -44, 18, 16));

    final visorRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-2, -43, 17, 14),
      const Radius.circular(7),
    );
    canvas.drawRRect(visorRect, visorPaint);

    // Visor specular glare line
    final glarePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(2, -41), const Offset(11, -38), glarePaint);

    // Helmet mounted headlamp
    canvas.drawCircle(
      const Offset(8, -32),
      2.5,
      Paint()..color = AstroviaTheme.cyan,
    );
  }

  void _drawFrontLeg(Canvas canvas, double angle) {
    _drawLeg(canvas, angle, isFront: true);
  }

  void _drawBackLeg(Canvas canvas, double angle) {
    _drawLeg(canvas, angle, isFront: false);
  }

  void _drawLeg(Canvas canvas, double angle, {required bool isFront}) {
    canvas.save();
    canvas.translate(isFront ? 3 : -3, 16);
    canvas.rotate(angle);

    final legColor = isFront ? profile.primaryColor : Color.lerp(profile.primaryColor, Colors.black, 0.2)!;
    final legPaint = Paint()..color = legColor;
    final strokePaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Thigh
    final thighRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-5, 0, 10, 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(thighRect, legPaint);
    canvas.drawRRect(thighRect, strokePaint);

    // Knee joint cuff
    final kneePaint = Paint()..color = profile.secondaryColor;
    canvas.drawRect(const Rect.fromLTWH(-4, 14, 8, 3), kneePaint);

    // Shin / Lower leg
    final shinRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-4.5, 17, 9, 15),
      const Radius.circular(4),
    );
    canvas.drawRRect(shinRect, legPaint);
    canvas.drawRRect(shinRect, strokePaint);

    // Boot (Lunar tread / Heavy sole)
    final bootPaint = Paint()..color = const Color(0xFF263238);
    final bootPath = Path()
      ..moveTo(-5, 32)
      ..lineTo(9, 32)
      ..lineTo(8, 38)
      ..lineTo(-6, 38)
      ..close();
    canvas.drawPath(bootPath, bootPaint);

    // Silicone ribbed sole
    canvas.drawLine(
      const Offset(-6, 38),
      const Offset(8, 38),
      Paint()
        ..color = AstroviaTheme.gold
        ..strokeWidth = 1.5,
    );

    canvas.restore();
  }

  void _drawFrontArm(Canvas canvas, double angle) {
    _drawArm(canvas, angle, isFront: true);
  }

  void _drawBackArm(Canvas canvas, double angle) {
    _drawArm(canvas, angle, isFront: false);
  }

  void _drawArm(Canvas canvas, double angle, {required bool isFront}) {
    canvas.save();
    canvas.translate(isFront ? 6 : -6, -12);
    canvas.rotate(angle);

    final armColor = isFront ? profile.primaryColor : Color.lerp(profile.primaryColor, Colors.black, 0.18)!;
    final armPaint = Paint()..color = armColor;
    final strokePaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Shoulder bearing
    canvas.drawCircle(const Offset(0, 0), 4.5, armPaint);

    // Upper arm
    final bicepRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-3.5, 0, 7, 14),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(bicepRect, armPaint);
    canvas.drawRRect(bicepRect, strokePaint);

    // Forearm wrist cuff & comm pad
    final commPadPaint = Paint()..color = profile.secondaryColor;
    canvas.drawRect(const Rect.fromLTWH(-4, 12, 8, 4), commPadPaint);

    // Forearm
    final forearmRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-3.5, 14, 7, 13),
      const Radius.circular(3),
    );
    canvas.drawRRect(forearmRect, armPaint);
    canvas.drawRRect(forearmRect, strokePaint);

    // Glove
    final glovePaint = Paint()..color = const Color(0xFF37474F);
    canvas.drawCircle(const Offset(0, 29), 4.0, glovePaint);

    // Carried geological tool or core sample tube
    if (isCarryingItem && isFront) {
      final toolPaint = Paint()
        ..color = AstroviaTheme.gold
        ..strokeWidth = 2.5;
      canvas.drawLine(const Offset(-4, 25), const Offset(12, 33), toolPaint);
      canvas.drawCircle(
        const Offset(12, 33),
        3.0,
        Paint()..color = AstroviaTheme.cyan,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AstronautPainter oldDelegate) {
    return oldDelegate.animState != animState ||
        oldDelegate.animPhase != animPhase ||
        oldDelegate.profile != profile ||
        oldDelegate.isCarryingItem != isCarryingItem ||
        oldDelegate.showHeadlampBeam != showHeadlampBeam;
  }
}
