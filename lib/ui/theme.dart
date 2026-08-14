import 'dart:ui';

/// Palette shared by Flutter HUD and Flame battle.
class HatchTheme {
  static const night = Color(0xFF140E2A);
  static const dusk = Color(0xFF2A1B4E);
  static const moss = Color(0xFF1F3A3A);
  static const panel = Color(0xFF241A42);
  static const panelEdge = Color(0xFF3D2E6B);
  static const gold = Color(0xFFFFD166);
  static const gem = Color(0xFF7CE7FF);
  static const crystal = Color(0xFFE0AFFF);
  static const cream = Color(0xFFFFF6E0);
  static const ink = Color(0xFF1A1030);
  static const hp = Color(0xFFFF6B6B);
  static const hpBack = Color(0xFF4A2040);
  static const accent = Color(0xFFFF8A5B);

  static const List<Color> tiers = [
    Color(0xFFF4E4C1), // egg
    Color(0xFF7DDEA5), // nibbit
    Color(0xFF6EC4FF), // sproutling
    Color(0xFFC792EA), // bloomlet
    Color(0xFFFF8A5B), // grovekin
    Color(0xFFFFD166), // luminox
    Color(0xFFFFF1F8), // mythowisp
  ];

  static const List<Color> tierInk = [
    Color(0xFF6B5420),
    Color(0xFF145C38),
    Color(0xFF0A3A66),
    Color(0xFF4A1A6B),
    Color(0xFF6B2208),
    Color(0xFF6B4A00),
    Color(0xFF6B3050),
  ];

  static Color tier(int t) => tiers[t.clamp(0, tiers.length - 1)];
  static Color tierText(int t) => tierInk[t.clamp(0, tierInk.length - 1)];
}
