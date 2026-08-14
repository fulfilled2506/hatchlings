import 'package:flutter/material.dart';

import '../../core/format.dart';
import 'theme.dart';

class NumberText extends StatelessWidget {
  const NumberText(
    this.value, {
    super.key,
    this.color = HatchTheme.gold,
    this.size = 18,
    this.prefix = '',
  });

  final double value;
  final Color color;
  final double size;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$prefix${formatCompact(value)}',
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }
}
