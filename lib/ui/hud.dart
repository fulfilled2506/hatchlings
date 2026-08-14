import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/strings.dart';
import '../game/game_controller.dart';
import 'number_text.dart';
import 'theme.dart';

class HudBar extends StatelessWidget {
  const HudBar({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final s = controller.snapshot;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          _chip(
            icon: Icons.monetization_on_rounded,
            color: HatchTheme.gold,
            child: NumberText(s.gold, size: 16),
          ),
          const SizedBox(width: 8),
          _chip(
            icon: Icons.diamond_rounded,
            color: HatchTheme.gem,
            child: NumberText(s.gems, color: HatchTheme.gem, size: 16),
          ),
          const SizedBox(width: 8),
          _chip(
            icon: Icons.auto_awesome,
            color: HatchTheme.crystal,
            child: NumberText(
              s.timeCrystals,
              color: HatchTheme.crystal,
              size: 16,
            ),
          ),
          const Spacer(),
          if (controller.goldBoostActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: HatchTheme.gold.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '2× ${formatDurationShort(controller.goldBoostLeft)}',
                style: const TextStyle(
                  color: HatchTheme.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: HatchTheme.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HatchTheme.panelEdge),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          child,
        ],
      ),
    );
  }
}

class BottomTabs extends StatelessWidget {
  const BottomTabs({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    const items = <(HomeTab, IconData, String)>[
      (HomeTab.merge, Icons.grid_view_rounded, 'Nest'),
      (HomeTab.upgrades, Icons.trending_up_rounded, S.upgrades),
      (HomeTab.collection, Icons.menu_book_rounded, S.collection),
      (HomeTab.shop, Icons.storefront_rounded, S.shop),
      (HomeTab.prestige, Icons.replay_circle_filled, S.prestige),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: const BoxDecoration(
        color: HatchTheme.panel,
        border: Border(top: BorderSide(color: HatchTheme.panelEdge)),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: _TabButton(
                icon: item.$2,
                label: item.$3,
                selected: controller.tab == item.$1,
                onTap: () => controller.selectTab(item.$1),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? HatchTheme.gold : const Color(0xFFB8A8D8);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
