/// Compact idle-game number formatting: 1.2K, 3.40M, 1.00B, then aa, ab...
String formatCompact(double value) {
  if (value.isNaN || value.isInfinite) return '0';
  final sign = value < 0 ? '-' : '';
  var n = value.abs();
  if (n < 1000) {
    if (n == 0) return '0';
    if (n < 100 && n != n.roundToDouble()) {
      return '$sign${n.toStringAsFixed(1)}';
    }
    return '$sign${n.round()}';
  }

  const named = ['K', 'M', 'B', 'T'];
  var group = 0;
  while (n >= 1000 && group < named.length) {
    n /= 1000;
    group += 1;
  }
  if (n >= 999.5 && group < named.length) {
    n /= 1000;
    group += 1;
  }
  if (n < 999.5) {
    return '$sign${_threeDigits(n)}${named[group - 1]}';
  }

  var letterGroup = -1;
  while (n >= 1000) {
    n /= 1000;
    letterGroup += 1;
  }
  return '$sign${_threeDigits(n)}${_letterSuffix(letterGroup)}';
}

String formatDurationShort(double seconds) {
  final s = seconds.clamp(0, 1e12).floor();
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  if (h > 0) return '${h}h ${m}m';
  if (m > 0) return '${m}m ${s % 60}s';
  return '${s}s';
}

String _threeDigits(double n) {
  if (n >= 100) return n.toStringAsFixed(0);
  if (n >= 10) return n.toStringAsFixed(1);
  return n.toStringAsFixed(2);
}

String _letterSuffix(int index) {
  final safe = index < 0 ? 0 : index;
  final first = safe ~/ 26;
  final second = safe % 26;
  return String.fromCharCodes([97 + first, 97 + second]);
}
