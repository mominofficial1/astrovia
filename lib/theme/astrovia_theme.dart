import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AstroviaTheme {
  // Brand Color Palette
  static const Color background = Color(0xFF050B14);
  static const Color darkSpace = Color(0xFF02050A);
  static const Color panel = Color(0xFF0D1B2A);
  static const Color panelTranslucent = Color(0xD90D1B2A);
  static const Color panelGlass = Color(0x990A1728);

  static const Color cyan = Color(0xFF19D9FF);
  static const Color cyanGlow = Color(0x6619D9FF);
  static const Color blue = Color(0xFF2979FF);
  static const Color gold = Color(0xFFFFC857);
  static const Color goldGlow = Color(0x66FFC857);
  static const Color white = Color(0xFFF4F8FF);
  static const Color secondary = Color(0xFF9BAFC4);
  static const Color green = Color(0xFF00E676);
  static const Color red = Color(0xFFFF5252);

  // Typography with graceful fallbacks
  static TextStyle orbitron({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = white,
    double letterSpacing = 1.2,
    double? height,
  }) {
    try {
      return GoogleFonts.orbitron(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Courier',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
  }

  static TextStyle rajdhani({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color color = white,
    double letterSpacing = 1.0,
    double? height,
  }) {
    try {
      return GoogleFonts.rajdhani(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'sans-serif-condensed',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
  }

  static TextStyle inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = secondary,
    double letterSpacing = 0.5,
    double height = 1.4,
  }) {
    try {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'sans-serif',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
  }

  // Box Shadows & Glows
  static List<BoxShadow> get cyanGlowShadow => [
        const BoxShadow(
          color: Color(0x5519D9FF),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> get goldGlowShadow => [
        const BoxShadow(
          color: Color(0x66FFC857),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];

  static BoxDecoration hudCardDecoration({
    bool isSelected = false,
    bool isGold = false,
    Color? customColor,
  }) {
    final borderColor = isGold
        ? gold
        : (isSelected ? cyan : cyan.withValues(alpha: 0.35));
    final glow = isGold
        ? goldGlowShadow
        : (isSelected ? cyanGlowShadow : <BoxShadow>[]);

    return BoxDecoration(
      color: customColor ?? panelTranslucent,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: borderColor,
        width: isSelected || isGold ? 1.8 : 1.0,
      ),
      boxShadow: glow,
    );
  }
}
