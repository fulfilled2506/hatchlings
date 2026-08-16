import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:hatchlings/data/content_catalog.dart';
import 'package:hatchlings/data/save_repository.dart';
import 'package:hatchlings/game/game_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('active 15-minute session reaches the rebirth wall', () {
    final catalog = ContentCatalog.fromJsonStrings(
      File('assets/data/balance.json').readAsStringSync(),
      File('assets/data/creatures.json').readAsStringSync(),
    );
    final controller = GameController(
      catalog: catalog,
      save: SaveRepository(MemorySaveStore()),
      random: Random(1),
    );
    controller.snapshot.onboardingStep = 2;

    for (var second = 0; second < 900; second++) {
      controller.tick(1);
      for (var i = 0; i < 3; i++) {
        controller.performTap();
      }
      if (controller.snapshot.autoLevel == 0 &&
          controller.snapshot.gold >= controller.costOf('autoDps')) {
        controller.buyUpgrade('autoDps');
      } else if (second % 12 == 0) {
        controller.buyUpgrade('goldMult');
      } else {
        controller.buyUpgrade('tapDamage');
      }
      _mergeWhateverWeCan(controller);
    }

    expect(
      controller.snapshot.stage,
      inInclusiveRange(35, 90),
      reason:
          '15 min of tapping should climb toward rebirth. Got stage '
          '${controller.snapshot.stage}, gold ${controller.snapshot.gold}, '
          'tap ${controller.snapshot.tapLevel}, auto ${controller.snapshot.autoLevel}.',
    );
    expect(controller.balance.prestige.minStage, 50);
    expect(controller.balance.contentStageCap, 200);
    expect(controller.balance.relics.length, 8);
  });
}

void _mergeWhateverWeCan(GameController controller) {
  var safety = 0;
  while (safety < 30) {
    safety += 1;
    var merged = false;
    final board = controller.snapshot.board;
    for (var i = 0; i < board.length; i++) {
      final tier = board[i];
      if (tier == null) continue;
      final matches = <int>[];
      for (var j = 0; j < board.length; j++) {
        if (j != i && board[j] == tier) matches.add(j);
      }
      if (matches.length >= 2) {
        controller.dropTile(matches.first, i);
        merged = true;
        break;
      }
    }
    if (!merged) break;
  }
}
