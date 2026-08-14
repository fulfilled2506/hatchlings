import 'package:flutter/material.dart';

import '../../core/economy.dart';
import '../../core/format.dart';
import '../../core/strings.dart';
import '../../game/game_controller.dart';
import '../../ui/theme.dart';

class UpgradesPanel extends StatelessWidget {
  const UpgradesPanel({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final ids = ['tapDamage', 'autoDps', 'goldMult'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      children: [
        for (final id in ids)
          _UpgradeCard(id: id, controller: controller),
        const SizedBox(height: 4),
        Text(
          'Board DPS ${formatCompact(Economy.boardDps(controller.balance, controller.snapshot.board))}  ·  '
          '${formatCompact(controller.goldPerSec)} gold/s',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFB8A8D8), fontSize: 11),
        ),
      ],
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({required this.id, required this.controller});

  final String id;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final def = controller.balance.upgrades[id]!;
    final cost = controller.costOf(id);
    final can = controller.snapshot.gold >= cost;
    final value = controller.upgradeValue(id);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HatchTheme.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HatchTheme.panelEdge),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${def.name}  Lv ${controller.levelOf(id)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: HatchTheme.cream,
                  ),
                ),
                Text(
                  def.blurb,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB8A8D8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Now ${formatCompact(value)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: HatchTheme.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buyBtn(
                S.buy,
                formatCompact(cost),
                can,
                () => controller.buyUpgrade(id),
              ),
              const SizedBox(height: 4),
              _buyBtn(
                S.buyMax,
                '',
                can,
                () => controller.buyMax(id),
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buyBtn(
    String label,
    String cost,
    bool enabled,
    VoidCallback onTap, {
    bool compact = false,
  }) {
    return SizedBox(
      width: 88,
      height: compact ? 28 : 36,
      child: FilledButton(
        onPressed: enabled ? onTap : null,
        style: FilledButton.styleFrom(
          backgroundColor: HatchTheme.accent,
          disabledBackgroundColor: const Color(0xFF3A2E55),
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
        child: Text(
          cost.isEmpty ? label : '$label\n$cost',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
