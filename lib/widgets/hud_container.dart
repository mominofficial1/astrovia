import 'package:flutter/material.dart';
import '../theme/astrovia_theme.dart';

class HudContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final bool isSelected;
  final bool isGold;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const HudContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.width,
    this.height,
    this.isSelected = false,
    this.isGold = false,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isGold
        ? AstroviaTheme.gold
        : (isSelected ? AstroviaTheme.cyan : AstroviaTheme.cyan.withValues(alpha: 0.35));

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AstroviaTheme.panelGlass,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: isSelected || isGold ? 1.8 : 1.0,
        ),
        boxShadow: isGold
            ? AstroviaTheme.goldGlowShadow
            : (isSelected ? AstroviaTheme.cyanGlowShadow : null),
      ),
      child: Stack(
        children: [
          // Corner sci-fi notches
          Positioned(
            top: 0,
            left: 0,
            child: _CornerNotch(color: borderColor),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _CornerNotch(color: borderColor, isBottomRight: true),
          ),
          child,
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: AstroviaTheme.cyan.withValues(alpha: 0.2),
          highlightColor: AstroviaTheme.cyan.withValues(alpha: 0.1),
          child: content,
        ),
      );
    }

    return content;
  }
}

class _CornerNotch extends StatelessWidget {
  final Color color;
  final bool isBottomRight;

  const _CornerNotch({required this.color, this.isBottomRight = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(10, 10),
      painter: _CornerPainter(color: color, isBottomRight: isBottomRight),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final bool isBottomRight;

  _CornerPainter({required this.color, required this.isBottomRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (!isBottomRight) {
      // Top-Left corner notch
      final path = Path()
        ..moveTo(0, size.height)
        ..lineTo(0, 0)
        ..lineTo(size.width, 0);
      canvas.drawPath(path, paint);
    } else {
      // Bottom-Right corner notch
      final path = Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
