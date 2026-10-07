import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/astrovia_theme.dart';

enum CyberButtonVariant { cyan, gold, transparent }

class CyberButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final CyberButtonVariant variant;
  final IconData? icon;
  final double minWidth;
  final double height;
  final double fontSize;

  const CyberButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CyberButtonVariant.cyan,
    this.icon,
    this.minWidth = 180,
    this.height = 48, // Accessible touch area >= 48dp (Section 28)
    this.fontSize = 15,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color glowColor;
    Color textColor;
    Color bgColor;

    switch (widget.variant) {
      case CyberButtonVariant.cyan:
        borderColor = AstroviaTheme.cyan;
        glowColor = AstroviaTheme.cyanGlow;
        textColor = AstroviaTheme.white;
        bgColor = _isPressed
            ? AstroviaTheme.cyan.withValues(alpha: 0.3)
            : (_isHovered
                ? AstroviaTheme.cyan.withValues(alpha: 0.18)
                : AstroviaTheme.panelGlass);
        break;
      case CyberButtonVariant.gold:
        borderColor = AstroviaTheme.gold;
        glowColor = AstroviaTheme.goldGlow;
        textColor = AstroviaTheme.gold;
        bgColor = _isPressed
            ? AstroviaTheme.gold.withValues(alpha: 0.3)
            : (_isHovered
                ? AstroviaTheme.gold.withValues(alpha: 0.18)
                : AstroviaTheme.panelGlass);
        break;
      case CyberButtonVariant.transparent:
        borderColor = AstroviaTheme.secondary.withValues(alpha: 0.4);
        glowColor = Colors.transparent;
        textColor = AstroviaTheme.secondary;
        bgColor = _isHovered
            ? AstroviaTheme.secondary.withValues(alpha: 0.1)
            : Colors.transparent;
        break;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          AudioService.instance.playClick();
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : (_isHovered ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: BoxConstraints(
              minWidth: widget.minWidth,
              minHeight: widget.height,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: borderColor,
                width: widget.variant == CyberButtonVariant.transparent ? 1.0 : 1.5,
              ),
              boxShadow: widget.variant != CyberButtonVariant.transparent
                  ? [
                      BoxShadow(
                        color: glowColor,
                        blurRadius: _isHovered ? 14 : 8,
                        spreadRadius: 0.5,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: widget.fontSize + 2, color: textColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: AstroviaTheme.orbitron(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
