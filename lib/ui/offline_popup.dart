import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/game_state.dart';
import '../core/strings.dart';
import 'theme.dart';

class OfflinePopup extends StatelessWidget {
  const OfflinePopup({
    super.key,
    required this.gain,
    required this.onCollect,
  });

  final OfflineGain gain;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HatchTheme.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: HatchTheme.panelEdge),
      ),
      title: const Text(
        S.offlineTitle,
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatDurationShort(gain.cappedSeconds),
            style: const TextStyle(color: HatchTheme.cream, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(
            '+${formatCompact(gain.gold)} gold',
            style: const TextStyle(
              color: HatchTheme.gold,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (gain.eggs > 0) ...[
            const SizedBox(height: 6),
            Text(
              '+${gain.eggs} egg${gain.eggs == 1 ? '' : 's'}',
              style: const TextStyle(color: HatchTheme.cream),
            ),
          ],
          if (gain.elapsedSeconds > gain.cappedSeconds + 1)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Offline earnings cap at 8 hours. Upgrade later to stretch it.',
                style: TextStyle(fontSize: 12, color: Color(0xFFB8A8D8)),
              ),
            ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: onCollect,
          style: FilledButton.styleFrom(backgroundColor: HatchTheme.accent),
          child: const Text(S.collect),
        ),
      ],
    );
  }
}
