import 'package:flutter_test/flutter_test.dart';

import 'package:hatchlings/core/strings.dart';

void main() {
  test('app branding strings are present', () {
    expect(S.appName, 'Hatchlings');
    expect(S.tagline.isNotEmpty, isTrue);
  });
}
