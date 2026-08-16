import 'package:flutter/material.dart';

import '../../core/creature_ids.dart';
import '../../core/strings.dart';
import '../../game/game_controller.dart';
import '../../ui/theme.dart';
import '../merge/creature_face.dart';

class CollectionPanel extends StatelessWidget {
  const CollectionPanel({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _eggCard(),
        for (final line in controller.catalog.lines) ...[
          const SizedBox(height: 10),
          _lineHeader(line.index, line.name),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: CreatureIds.maxTier,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, i) {
              final tier = i + 1;
              final code = CreatureIds.encode(line.index, tier);
              final known = controller.snapshot.discovered.contains(code);
              final c = controller.catalog.creatureByCode(code);
              return _cell(code, c.name, c.hint, known);
            },
          ),
        ],
      ],
    );
  }

  Widget _eggCard() {
    final known = controller.snapshot.discovered.contains(CreatureIds.egg);
    final c = controller.catalog.creatureByCode(CreatureIds.egg);
    return _cell(CreatureIds.egg, c.name, c.hint, known);
  }

  Widget _lineHeader(int line, String name) {
    final complete = CreatureIds.lineCodes(line)
        .every(controller.snapshot.discovered.contains);
    final claimed = controller.snapshot.albumClaims.contains('line_$line');
    return Row(
      children: [
        Text(
          name,
          style: const TextStyle(
            color: HatchTheme.cream,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (complete)
          Text(
            claimed ? S.lineComplete : S.lineComplete,
            style: const TextStyle(color: HatchTheme.gem, fontSize: 11),
          ),
      ],
    );
  }

  Widget _cell(int code, String name, String hint, bool known) {
    return Container(
      decoration: BoxDecoration(
        color: HatchTheme.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HatchTheme.panelEdge),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CreatureFace(code: code, discovered: known, size: 48),
          const SizedBox(height: 6),
          Text(
            known ? name : S.unknown,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: HatchTheme.cream,
            ),
          ),
          Text(
            known ? hint : 'Merge to discover',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Color(0xFFB8A8D8)),
          ),
        ],
      ),
    );
  }
}
