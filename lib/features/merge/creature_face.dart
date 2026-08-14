import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../game/game_controller.dart';
import '../../ui/theme.dart';

class CreatureFace extends StatelessWidget {
  const CreatureFace({
    super.key,
    required this.tier,
    this.size = 48,
    this.discovered = true,
  });

  final int tier;
  final double size;
  final bool discovered;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _FacePainter(tier: tier, discovered: discovered),
    );
  }
}

class _FacePainter extends CustomPainter {
  _FacePainter({required this.tier, required this.discovered});

  final int tier;
  final bool discovered;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;
    final fill = discovered
        ? HatchTheme.tier(tier)
        : const Color(0xFF2A2150);
    canvas.drawCircle(c, r, Paint()..color = const Color(0x33000000));
    canvas.drawCircle(c.translate(0, -1), r, Paint()..color = fill);

    if (!discovered) {
      final q = TextPainter(
        text: const TextSpan(
          text: S.unknown,
          style: TextStyle(
            color: Color(0xFF8A7AA8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      q.paint(canvas, Offset(c.dx - q.width / 2, c.dy - q.height / 2));
      return;
    }

    if (tier == 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r * 0.72),
        0.9,
        1.4,
        false,
        Paint()
          ..color = const Color(0x66C4A35A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        c.translate(0, r * 0.08),
        r * 0.08,
        Paint()..color = HatchTheme.tierText(0),
      );
      return;
    }

    final ink = HatchTheme.tierText(tier);
    final eye = Paint()..color = ink;
    canvas.drawCircle(c.translate(-r * 0.28, -r * 0.08), r * 0.1, eye);
    canvas.drawCircle(c.translate(r * 0.28, -r * 0.08), r * 0.1, eye);
    canvas.drawCircle(
      c.translate(-r * 0.24, -r * 0.12),
      r * 0.035,
      Paint()..color = Colors.white,
    );

    final smile = Path()
      ..moveTo(c.dx - r * 0.22, c.dy + r * 0.18)
      ..quadraticBezierTo(
        c.dx,
        c.dy + r * 0.34,
        c.dx + r * 0.22,
        c.dy + r * 0.18,
      );
    canvas.drawPath(
      smile,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    if (tier >= 4) {
      canvas.drawCircle(
        c.translate(0, -r * 0.72),
        r * 0.16,
        Paint()..color = HatchTheme.gold,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) {
    return oldDelegate.tier != tier || oldDelegate.discovered != discovered;
  }
}
