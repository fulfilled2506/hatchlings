import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../game/game_controller.dart';
import '../../ui/theme.dart';
import 'creature_face.dart';

class MergeBoardPanel extends StatelessWidget {
  const MergeBoardPanel({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final cols = controller.balance.merge.cols;
    final rows = controller.balance.merge.rows;
    final board = controller.snapshot.board;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6, bottom: 4),
          child: Text(
            S.mergeHint,
            style: TextStyle(color: Color(0xFFB8A8D8), fontSize: 11),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cols * rows,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                return _Tile(
                  index: index,
                  tier: index < board.length ? board[index] : null,
                  controller: controller,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.index,
    required this.tier,
    required this.controller,
  });

  final int index;
  final int? tier;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final child = _NestSlot(tier: tier);
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) =>
          controller.dropTile(details.data, index),
      builder: (context, candidate, rejected) {
        final glow = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: glow ? HatchTheme.gold : HatchTheme.panelEdge,
              width: glow ? 2 : 1,
            ),
            color: glow
                ? HatchTheme.gold.withOpacity(0.12)
                : HatchTheme.panel.withOpacity(0.7),
          ),
          child: tier == null
              ? child
              : Draggable<int>(
                  data: index,
                  feedback: Material(
                    color: Colors.transparent,
                    child: CreatureFace(tier: tier!, size: 52),
                  ),
                  childWhenDragging: Opacity(opacity: 0.25, child: child),
                  child: child,
                ),
        );
      },
    );
  }
}

class _NestSlot extends StatelessWidget {
  const _NestSlot({required this.tier});

  final int? tier;

  @override
  Widget build(BuildContext context) {
    if (tier == null) {
      return const Center(
        child: Icon(Icons.add, color: Color(0x33FFF6E0), size: 18),
      );
    }
    return Center(child: CreatureFace(tier: tier!, size: 44));
  }
}
