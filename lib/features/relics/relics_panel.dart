import 'package:flutter/material.dart';

import '../../core/economy.dart';
import '../../core/format.dart';
import '../../core/strings.dart';
import '../../game/game_controller.dart';
import '../../ui/theme.dart';

class RelicsPanel extends StatelessWidget {
  const RelicsPanel({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          S.relics,
          style: TextStyle(
            color: HatchTheme.crystal,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          S.relicsBlurb,
          style: TextStyle(color: Color(0xFFB8A8D8), fontSize: 11),
        ),
        const SizedBox(height: 8),
        for (final relic in controller.balance.relics)
          _RelicRow(controller: controller, relicId: relic.id),
      ],
    );
  }
}

class _RelicRow extends StatelessWidget {
  const _RelicRow({required this.controller, required this.relicId});

  final GameController controller;
  final String relicId;

  @override
  Widget build(BuildContext context) {
    final relic = controller.balance.relic(relicId)!;
    final level = controller.snapshot.relicLevels[relicId] ?? 0;
    final maxed = level >= relic.maxLevel;
    final buyCost = maxed ? 0.0 : Economy.relicCost(relic, level);
    final can = !maxed && controller.snapshot.timeCrystals >= buyCost;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HatchTheme.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HatchTheme.panelEdge),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${relic.name}  Lv $level/${relic.maxLevel}',
                  style: const TextStyle(
                    color: HatchTheme.cream,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                Text(
                  relic.blurb,
                  style: const TextStyle(color: Color(0xFFB8A8D8), fontSize: 11),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: can ? () => controller.buyRelic(relicId) : null,
            style: FilledButton.styleFrom(
              backgroundColor: HatchTheme.crystal,
              foregroundColor: HatchTheme.ink,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(maxed ? S.maxed : '${formatCompact(buyCost)} ✦'),
          ),
        ],
      ),
    );
  }
}
