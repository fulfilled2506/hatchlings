import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/strings.dart';
import '../../game/game_controller.dart';
import '../../ui/theme.dart';

class PrestigePanel extends StatelessWidget {
  const PrestigePanel({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final ready = controller.canPrestige;
    final crystals = controller.nextPrestigeCrystals;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            S.prestigeBlurb,
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFB8A8D8)),
          ),
          const SizedBox(height: 16),
          Text(
            ready
                ? 'Gain ${formatCompact(crystals)} Time Crystals'
                : S.prestigeLocked,
            style: TextStyle(
              color: ready ? HatchTheme.crystal : const Color(0xFFB8A8D8),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          Text(
            'Highest stage ${controller.snapshot.highestStage}  ·  '
            'Rebirths ${controller.snapshot.prestigeCount}',
            style: const TextStyle(color: Color(0xFFB8A8D8), fontSize: 12),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: ready ? controller.rebirth : null,
              style: FilledButton.styleFrom(
                backgroundColor: HatchTheme.crystal,
                foregroundColor: HatchTheme.ink,
              ),
              child: const Text(S.prestigeCta),
            ),
          ),
        ],
      ),
    );
  }
}
