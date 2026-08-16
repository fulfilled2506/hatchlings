/// Board cell encoding: 0 = egg, forest tiers 1–6, sea 101–106, fire 201–206.
class CreatureIds {
  static const egg = 0;
  static const lineCount = 3;
  static const maxTier = 6;

  static int encode(int line, int tier) {
    if (tier <= 0) return egg;
    final safeLine = line.clamp(0, lineCount - 1);
    if (safeLine == 0) return tier;
    return safeLine * 100 + tier;
  }

  static int tierOf(int code) {
    if (code <= 0) return 0;
    if (code < 100) return code;
    return code % 100;
  }

  static int lineOf(int code) {
    if (code <= 0 || code < 100) return 0;
    return code ~/ 100;
  }

  static bool isEgg(int? code) => code == egg;

  static int? evolved(int code, {required int maxTier}) {
    if (code == egg) return null;
    final t = tierOf(code);
    if (t >= maxTier) return null;
    return encode(lineOf(code), t + 1);
  }

  static List<int> lineCodes(int line) => [
    for (var t = 1; t <= maxTier; t++) encode(line, t),
  ];

  static List<int> allDiscoverable() => [
    egg,
    for (var line = 0; line < lineCount; line++) ...lineCodes(line),
  ];
}
