import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../game/game_controller.dart';
import '../../ui/theme.dart';

class ShopPanel extends StatelessWidget {
  const ShopPanel({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text(
          S.adsStubNote,
          style: TextStyle(color: Color(0xFFB8A8D8), fontSize: 12),
        ),
        const SizedBox(height: 10),
        _row(
          icon: Icons.ondemand_video,
          title: S.watchAd,
          action: controller.goldBoostActive ? 'Active' : 'Watch',
          enabled: !controller.goldBoostActive,
          onTap: controller.watchGoldBoost,
        ),
        _row(
          icon: Icons.diamond_rounded,
          title: S.buyGems,
          action: '+100',
          onTap: controller.buyGemsStub,
        ),
        _row(
          icon: Icons.block,
          title: S.removeAds,
          action: controller.snapshot.adsRemoved ? 'Owned' : 'Buy',
          enabled: !controller.snapshot.adsRemoved,
          onTap: controller.buyRemoveAdsStub,
        ),
      ],
    );
  }

  Widget _row({
    required IconData icon,
    required String title,
    required String action,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HatchTheme.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HatchTheme.panelEdge),
      ),
      child: Row(
        children: [
          Icon(icon, color: HatchTheme.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: HatchTheme.cream,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FilledButton(
            onPressed: enabled ? onTap : null,
            style: FilledButton.styleFrom(backgroundColor: HatchTheme.accent),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}
