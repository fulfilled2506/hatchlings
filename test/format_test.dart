import 'package:flutter_test/flutter_test.dart';

import 'package:hatchlings/core/format.dart';

void main() {
  test('formats thousands with K/M/B/T', () {
    expect(formatCompact(0), '0');
    expect(formatCompact(12), '12');
    expect(formatCompact(999), '999');
    expect(formatCompact(1000), '1.00K');
    expect(formatCompact(1234), '1.23K');
    expect(formatCompact(1e6), '1.00M');
    expect(formatCompact(3.4e9), '3.40B');
    expect(formatCompact(2.1e12), '2.10T');
  });

  test('formats beyond T with letter suffixes', () {
    expect(formatCompact(1e15), '1.00aa');
    expect(formatCompact(2.5e18), '2.50ab');
  });

  test('duration helper', () {
    expect(formatDurationShort(12), '12s');
    expect(formatDurationShort(65), '1m 5s');
    expect(formatDurationShort(3661), '1h 1m');
  });
}
