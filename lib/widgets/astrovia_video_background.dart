import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/astrovia_theme.dart';

class AstroviaVideoBackground extends StatefulWidget {
  final String videoAsset;
  final double overlayOpacity;
  final bool loop;
  final bool autoPlay;
  final VoidCallback? onFinished;
  final Widget? child;
  final bool showMuteButton;

  const AstroviaVideoBackground({
    super.key,
    required this.videoAsset,
    this.overlayOpacity = 0.35,
    this.loop = true,
    this.autoPlay = true,
    this.onFinished,
    this.child,
    this.showMuteButton = false,
  });

  @override
  State<AstroviaVideoBackground> createState() =>
      _AstroviaVideoBackgroundState();
}

class _AstroviaVideoBackgroundState extends State<AstroviaVideoBackground>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = true;
  bool _isDisposed = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant AstroviaVideoBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoAsset != widget.videoAsset) {
      _cleanupController();
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;

    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.asset(widget.videoAsset);
      await controller.initialize();

      if (!mounted || _isDisposed) {
        await controller.dispose().catchError((_) {});
        return;
      }

      // Ensure audio is muted by default (Section 20)
      await controller.setVolume(0.0).catchError((_) {});
      await controller.setLooping(widget.loop).catchError((_) {});

      if (!widget.loop && widget.onFinished != null) {
        controller.addListener(_videoListener);
      }

      if (widget.autoPlay && mounted && !_isDisposed) {
        await controller.play().catchError((_) {});
      }

      if (mounted && !_isDisposed) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
          _hasError = false;
        });
        _fadeController.forward();
      } else {
        await controller.dispose().catchError((_) {});
      }
    } catch (e) {
      if (kDebugMode) {
        print('AstroviaVideoBackground: Fallback active for ${widget.videoAsset}: $e');
      }
      try {
        await controller?.dispose().catchError((_) {});
      } catch (_) {}

      if (mounted && !_isDisposed) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  void _videoListener() {
    final c = _controller;
    if (c != null &&
        c.value.isInitialized &&
        !widget.loop &&
        c.value.position >= c.value.duration) {
      widget.onFinished?.call();
    }
  }

  void _cleanupController() {
    final c = _controller;
    _controller = null;
    _isInitialized = false;
    if (c != null) {
      try {
        c.removeListener(_videoListener);
        c.pause().catchError((_) {});
        c.dispose().catchError((_) {});
      } catch (_) {}
    }
  }

  void _toggleMute() {
    final c = _controller;
    if (c != null && c.value.isInitialized) {
      setState(() {
        _isMuted = !_isMuted;
        c.setVolume(_isMuted ? 0.0 : 1.0).catchError((_) {});
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cleanupController();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 0: High-quality static cosmos background (always visible underneath)
        const SpaceCosmosFallback(),

        // Layer 1: Real cinematic video if initialized without error
        if (_isInitialized && _controller != null && !_hasError)
          FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _controller!.value.size.width > 0
                      ? _controller!.value.size.width
                      : 1920,
                  height: _controller!.value.size.height > 0
                      ? _controller!.value.size.height
                      : 1080,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          ),

        // Layer 2: Dark transparent overlay (20% to 45% per Section 5)
        Container(
          color: Colors.black.withValues(alpha: widget.overlayOpacity),
        ),

        // Layer 3: Subtle Space Grid / Scan lines effect
        const IgnorePointer(
          child: CustomPaint(
            painter: SubtleGridPainter(),
            size: Size.infinite,
          ),
        ),

        // Layer 4: Interactive HUD & Screen Content
        if (widget.child != null) widget.child!,

        // Layer 5: Optional minimal Sound toggle button (top-right corner)
        if (widget.showMuteButton && _isInitialized)
          Positioned(
            top: 14,
            right: 18,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleMute,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AstroviaTheme.panelGlass,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AstroviaTheme.cyan.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: _isMuted
                            ? AstroviaTheme.secondary
                            : AstroviaTheme.cyan,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isMuted ? "MUTED" : "AUDIO ON",
                        style: AstroviaTheme.rajdhani(
                          fontSize: 12,
                          color: _isMuted
                              ? AstroviaTheme.secondary
                              : AstroviaTheme.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Dynamic cosmic fallback drawing high-fidelity stars and planetary horizon
class SpaceCosmosFallback extends StatelessWidget {
  const SpaceCosmosFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.3),
          radius: 1.2,
          colors: [
            Color(0xFF0F1B2F),
            Color(0xFF080F1E),
            Color(0xFF02050A),
          ],
        ),
      ),
      child: const CustomPaint(
        painter: StarfieldPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class StarfieldPainter extends CustomPainter {
  const StarfieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final starPaint = Paint()..color = Colors.white;

    for (int i = 0; i < 90; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.4;
      final opacity = random.nextDouble() * 0.7 + 0.3;
      starPaint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // Distant cyan nebula glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AstroviaTheme.cyan.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.75, size.height * 0.25),
          radius: size.width * 0.35,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.25),
      size.width * 0.35,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SubtleGridPainter extends CustomPainter {
  const SubtleGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AstroviaTheme.cyan.withValues(alpha: 0.025)
      ..strokeWidth = 0.5;

    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
