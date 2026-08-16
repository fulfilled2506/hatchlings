import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/strings.dart';
import '../../game/game_controller.dart';
import '../../ui/theme.dart';

class MissionsCard extends StatelessWidget {
  const MissionsCard({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 6),
          child: Text(
            S.dailyMissions,
            style: TextStyle(
              color: HatchTheme.cream,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        for (final mission in controller.balance.missions)
          _MissionRow(controller: controller, missionId: mission.id),
      ],
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({required this.controller, required this.missionId});

  final GameController controller;
  final String missionId;

  @override
  Widget build(BuildContext context) {
    final mission = controller.balance.missions.firstWhere(
      (m) => m.id == missionId,
    );
    final progress = controller.missionProgress(missionId);
    final claimed = controller.missionClaimed(missionId);
    final ratio = (progress / mission.target).clamp(0.0, 1.0);
    final canClaim = controller.canClaimMission(missionId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HatchTheme.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HatchTheme.panelEdge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mission.title,
                  style: const TextStyle(
                    color: HatchTheme.cream,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                claimed
                    ? S.claimed
                    : '${formatCompact(progress.toDouble())}/${mission.target}',
                style: const TextStyle(color: Color(0xFFB8A8D8), fontSize: 11),
              ),
            ],
          ),
          Text(
            mission.blurbFilled(),
            style: const TextStyle(color: Color(0xFFB8A8D8), fontSize: 11),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: HatchTheme.hpBack,
              color: HatchTheme.gem,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: canClaim ? () => controller.claimMission(missionId) : null,
              style: FilledButton.styleFrom(
                backgroundColor: HatchTheme.gem,
                foregroundColor: HatchTheme.ink,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                claimed
                    ? S.claimed
                    : '${S.claim} +${mission.rewardGems.toInt()}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
