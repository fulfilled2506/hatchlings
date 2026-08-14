import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../game/game_controller.dart';
import '../../ui/theme.dart';
import '../merge/creature_face.dart';

class CollectionPanel extends StatelessWidget {
  const CollectionPanel({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final creatures = controller.catalog.creatures;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: creatures.length,
      itemBuilder: (context, i) {
        final c = creatures[i];
        final known = controller.snapshot.discovered.contains(c.tier);
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
              CreatureFace(tier: c.tier, discovered: known, size: 48),
              const SizedBox(height: 6),
              Text(
                known ? c.name : S.unknown,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: HatchTheme.cream,
                ),
              ),
              Text(
                known ? c.hint : 'Merge to discover',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Color(0xFFB8A8D8)),
              ),
            ],
          ),
        );
      },
    );
  }
}
