import 'package:flutter/material.dart';
import '../theme/astrovia_theme.dart';

class ScannerBeam extends StatefulWidget {
  final double height;
  final Duration duration;
  final Color beamColor;

  const ScannerBeam({
    super.key,
    this.height = 160,
    this.duration = const Duration(milliseconds: 1800),
    this.beamColor = AstroviaTheme.cyan,
  });

  @override
  State<ScannerBeam> createState() => _ScannerBeamState();
}

class _ScannerBeamState extends State<ScannerBeam>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _ScannerPainter(
            progress: _animation.value,
            color: widget.beamColor,
          ),
        );
      },
    );
  }
}

class _ScannerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScannerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;

    // Glowing beam line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);

    // Gradient trail above and below
    final rect = Rect.fromLTRB(0, y - 24, size.width, y + 24);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        color.withValues(alpha: 0.35),
        Colors.transparent,
      ],
    );
    final fillPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
