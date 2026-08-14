import 'package:flutter_test/flutter_test.dart';

import 'package:hatchlings/core/economy.dart';
import 'package:hatchlings/data/content_catalog.dart';
import 'package:hatchlings/data/save_repository.dart';
import 'package:hatchlings/game/game_controller.dart';

ContentCatalog _catalog() {
  return ContentCatalog(
    balance: Balance.fromJson({
      'enemy': {
        'baseHp': 10,
        'hpGrowth': 1.15,
        'baseGold': 5,
        'goldGrowth': 1.1,
      },
      'upgrades': {
        'tapDamage': {
          'id': 'tapDamage',
          'name': 'Tap',
          'blurb': '',
          'baseCost': 10,
          'costGrowth': 1.12,
          'baseValue': 1,
          'valueGrowth': 1.15,
        },
        'autoDps': {
          'id': 'autoDps',
          'name': 'Auto',
          'blurb': '',
          'baseCost': 40,
          'costGrowth': 1.13,
          'baseValue': 0.8,
          'valueGrowth': 1.15,
        },
        'goldMult': {
          'id': 'goldMult',
          'name': 'Gold',
          'blurb': '',
          'baseCost': 80,
          'costGrowth': 1.15,
          'baseValue': 0.1,
          'valueGrowth': 0,
        },
      },
      'offline': {
        'capSeconds': 28800,
        'goldPerDamage': 0.4,
        'minPopupSeconds': 30,
      },
      'merge': {
        'cols': 5,
        'rows': 4,
        'spawnInterval': 6,
        'killEggChance': 0.2,
        'maxTier': 6,
        'maxTierGoldBurst': 100,
      },
      'prestige': {'minStage': 50, 'crystalsPerStage': 0.1},
      'relicGoldPerCrystal': 0.01,
      'creatureDps': [0, 1, 3, 9, 27, 81, 243],
      'creatureGoldPerSec': [0, 0.2, 0.8, 3, 11, 40, 150],
      'goldBoostSeconds': 300,
      'startingEggs': 3,
    }),
    creatures: const [],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('3 matching tiles evolve into the next hatchling', () {
    final controller = GameController(
      catalog: _catalog(),
      save: SaveRepository(MemorySaveStore()),
    );
    controller.snapshot.board = List<int?>.filled(20, null);
    controller.snapshot.board[0] = 1;
    controller.snapshot.board[1] = 1;
    controller.snapshot.board[2] = 1;
    expect(controller.dropTile(0, 1), isTrue);
    expect(controller.snapshot.board[1], 2);
    expect(controller.snapshot.board[0], isNull);
    expect(controller.snapshot.board[2], isNull);
    expect(controller.snapshot.discovered.contains(2), isTrue);
  });

  test('two different tiles swap', () {
    final controller = GameController(
      catalog: _catalog(),
      save: SaveRepository(MemorySaveStore()),
    );
    controller.snapshot.board = List<int?>.filled(20, null);
    controller.snapshot.board[0] = 1;
    controller.snapshot.board[5] = 2;
    controller.dropTile(0, 5);
    expect(controller.snapshot.board[0], 2);
    expect(controller.snapshot.board[5], 1);
  });

  test('tapping kills a stage-1 blob and pays gold', () {
    final controller = GameController(
      catalog: _catalog(),
      save: SaveRepository(MemorySaveStore()),
    );
    controller.snapshot.enemyHp = 3;
    controller.snapshot.enemyMaxHp = 10;
    controller.performTap();
    controller.performTap();
    controller.performTap();
    expect(controller.snapshot.stage, greaterThan(1));
    expect(controller.snapshot.gold, greaterThan(0));
  });

  test('buying tap power spends gold', () {
    final controller = GameController(
      catalog: _catalog(),
      save: SaveRepository(MemorySaveStore()),
    );
    controller.snapshot.gold = 10;
    expect(controller.buyUpgrade('tapDamage'), isTrue);
    expect(controller.snapshot.tapLevel, 1);
    expect(controller.snapshot.gold, 0);
    expect(controller.buyUpgrade('tapDamage'), isFalse);
  });

  test('rebirth resets the nest but keeps crystals', () {
    final controller = GameController(
      catalog: _catalog(),
      save: SaveRepository(MemorySaveStore()),
    );
    controller.snapshot.stage = 50;
    controller.snapshot.highestStage = 50;
    controller.snapshot.gold = 999;
    controller.snapshot.tapLevel = 12;
    controller.snapshot.gems = 40;
    expect(controller.rebirth(), isTrue);
    expect(controller.snapshot.stage, 1);
    expect(controller.snapshot.tapLevel, 0);
    expect(controller.snapshot.gold, 0);
    expect(controller.snapshot.gems, 40);
    expect(controller.snapshot.timeCrystals, greaterThan(0));
    expect(controller.snapshot.prestigeCount, 1);
  });
}
