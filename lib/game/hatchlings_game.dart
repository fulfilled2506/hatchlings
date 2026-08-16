import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

import '../core/format.dart';
import '../ui/theme.dart';
import 'game_controller.dart';

class HatchlingsGame extends FlameGame with TapCallbacks {
  HatchlingsGame({required this.controller});

  final GameController controller;
  EnemyBlob? _enemy;
  int _seenHit = 0;

  @override
  ui.Color backgroundColor() => HatchTheme.night;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    final backdrop = BattleBackdrop();
    _enemy = EnemyBlob(controller: controller);
    await add(backdrop);
    await add(_enemy!);
    await add(StageBanner(controller: controller));
    if (size.x > 0) _layout(size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final enemy = _enemy;
    if (enemy == null || !enemy.isMounted) return;
    _layout(size);
  }

  void _layout(Vector2 size) {
    final enemy = _enemy;
    if (enemy == null) return;
    enemy.position = Vector2(size.x * 0.5, size.y * 0.54);
    enemy.baseRadius = math.min(size.x, size.y) * 0.22;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final hit = controller.lastHit;
    if (hit != null && identityHashCode(hit) != _seenHit) {
      _seenHit = identityHashCode(hit);
      final pos = Vector2(hit.nx * size.x, hit.ny * size.y);
      add(DamageFloater(text: formatCompact(hit.damage), position: pos));
      if (controller.combo >= 3) {
        add(
          DamageFloater(
            text: 'x${controller.combo}',
            position: pos + Vector2(0, -28),
            tint: HatchTheme.gold,
            textScale: 0.85,
          ),
        );
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final p = event.canvasPosition;
    final nx = size.x == 0 ? 0.5 : (p.x / size.x).clamp(0.0, 1.0);
    final ny = size.y == 0 ? 0.5 : (p.y / size.y).clamp(0.0, 1.0);
    controller.performTap(nx: nx, ny: ny);
  }
}

class BattleBackdrop extends Component with HasGameReference<HatchlingsGame> {
  final _stars = <Offset>[];
  final _rng = math.Random(7);

  @override
  void onLoad() {
    _scatter();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _scatter();
  }

  void _scatter() {
    _stars.clear();
    final s = game.size;
    for (var i = 0; i < 28; i++) {
      _stars.add(Offset(_rng.nextDouble() * s.x, _rng.nextDouble() * s.y * 0.7));
    }
  }

  @override
  void render(Canvas canvas) {
    final s = game.size;
    final rect = Offset.zero & Size(s.x, s.y);
    final sky = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, s.y),
        const [Color(0xFF1B1240), Color(0xFF2A1B4E), Color(0xFF1A3A3A)],
        const [0, 0.55, 1],
      );
    canvas.drawRect(rect, sky);

    final starPaint = Paint()..color = const Color(0x66FFF6E0);
    for (final star in _stars) {
      canvas.drawCircle(star, 1.4, starPaint);
    }

    final moon = Paint()..color = const Color(0x33FFF6E0);
    canvas.drawCircle(Offset(s.x * 0.82, s.y * 0.16), 28, moon);
    canvas.drawCircle(
      Offset(s.x * 0.82, s.y * 0.16),
      22,
      Paint()..color = const Color(0x22FFF6E0),
    );

    final ground = Path()
      ..moveTo(0, s.y * 0.78)
      ..quadraticBezierTo(s.x * 0.5, s.y * 0.68, s.x, s.y * 0.78)
      ..lineTo(s.x, s.y)
      ..lineTo(0, s.y)
      ..close();
    canvas.drawPath(ground, Paint()..color = const Color(0xFF16302C));
    canvas.drawPath(
      ground,
      Paint()
        ..color = const Color(0xFF2A6B5A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}

class EnemyBlob extends PositionComponent
    with HasGameReference<HatchlingsGame> {
  EnemyBlob({required this.controller}) : super(anchor: Anchor.center);

  final GameController controller;
  double baseRadius = 72;
  double _squash = 1;
  double _wobble = 0;

  @override
  void onMount() {
    super.onMount();
    position = Vector2(game.size.x * 0.5, game.size.y * 0.54);
  }

  @override
  void update(double dt) {
    _wobble += dt * 2.2;
    if (controller.lastHitFlash > 0) {
      _squash = 0.78;
    } else {
      _squash += (1 - _squash) * math.min(1, dt * 14);
    }
  }

  @override
  void render(Canvas canvas) {
    final hp = controller.hpRatio;
    final pulse = 1 + math.sin(_wobble) * 0.03;
    final r = baseRadius * pulse * (0.82 + 0.18 * hp);
    final flash = controller.lastHitFlash > 0;
    final fill = flash ? const Color(0xFFFFF6E0) : Color.lerp(
          const Color(0xFF5B2A7A),
          const Color(0xFFE85D75),
          1 - hp,
        )!;

    canvas.save();
    canvas.scale(1 + (1 - _squash) * 0.35, _squash);

    final shadow = Paint()..color = const Color(0x66000000);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, r * 0.95),
        width: r * 1.6,
        height: r * 0.35,
      ),
      shadow,
    );

    canvas.drawCircle(Offset.zero, r, Paint()..color = fill);
    canvas.drawCircle(
      Offset(-r * 0.28, -r * 0.22),
      r * 0.28,
      Paint()..color = const Color(0x55FFFFFF),
    );

    final eyePaint = Paint()..color = HatchTheme.ink;
    final eyeY = -r * 0.08;
    canvas.drawCircle(Offset(-r * 0.28, eyeY), r * 0.12, eyePaint);
    canvas.drawCircle(Offset(r * 0.28, eyeY), r * 0.12, eyePaint);
    canvas.drawCircle(
      Offset(-r * 0.24, eyeY - r * 0.04),
      r * 0.04,
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawCircle(
      Offset(r * 0.32, eyeY - r * 0.04),
      r * 0.04,
      Paint()..color = const Color(0xFFFFFFFF),
    );

    final mouth = Path()
      ..moveTo(-r * 0.18, r * 0.22)
      ..quadraticBezierTo(0, r * (hp < 0.35 ? 0.12 : 0.38), r * 0.18, r * 0.22);
    canvas.drawPath(
      mouth,
      Paint()
        ..color = HatchTheme.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Horns
    final horn = Paint()..color = const Color(0xFFFFD166);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-r * 0.55, -r * 0.7),
        width: r * 0.28,
        height: r * 0.5,
      ),
      horn,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(r * 0.55, -r * 0.7),
        width: r * 0.28,
        height: r * 0.5,
      ),
      horn,
    );

    canvas.restore();
  }
}

class StageBanner extends PositionComponent
    with HasGameReference<HatchlingsGame> {
  StageBanner({required this.controller});

  final GameController controller;

  @override
  void render(Canvas canvas) {
    final s = game.size;
    final hp = controller.hpRatio;
    final barWidth = s.x * 0.72;
    final left = (s.x - barWidth) / 2;
    final top = s.y * 0.08;
    final rect = Rect.fromLTWH(left, top, barWidth, 16);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(rrect, Paint()..color = HatchTheme.hpBack);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth * hp, 16),
        const Radius.circular(10),
      ),
      Paint()..color = HatchTheme.hp,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0x66FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final tp = TextPainter(
      text: TextSpan(
        text:
            'STAGE ${controller.snapshot.stage}   ${formatCompact(controller.snapshot.enemyHp)} HP',
        style: const TextStyle(
          color: Color(0xFFFFF6E0),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((s.x - tp.width) / 2, top + 22));
  }
}

class DamageFloater extends PositionComponent {
  DamageFloater({
    required this.text,
    required Vector2 position,
    this.tint = HatchTheme.gold,
    this.textScale = 1,
  }) : super(position: position, anchor: Anchor.center);

  final String text;
  final Color tint;
  final double textScale;
  double _life = 0;

  @override
  void update(double dt) {
    _life += dt;
    position.add(Vector2(0, -70 * dt));
    if (_life > 0.7) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_life / 0.7).clamp(0.0, 1.0);
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: tint.withValues(alpha: 1 - t),
          fontSize: 22 * textScale,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}
