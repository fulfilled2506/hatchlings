import 'package:flutter_test/flutter_test.dart';

import 'package:hatchlings/core/economy.dart';

Balance _balance() {
  return Balance.fromJson({
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
  });
}

void main() {
  final b = _balance();

  test('enemy HP follows exponential stage curve', () {
    expect(Economy.enemyHp(b, 1), 10);
    expect(Economy.enemyHp(b, 2), closeTo(11.5, 0.0001));
    expect(Economy.enemyHp(b, 50), greaterThan(900));
    expect(Economy.enemyHp(b, 60), greaterThan(Economy.enemyHp(b, 50)));
  });

  test('upgrade cost grows, tap damage starts usable', () {
    expect(Economy.upgradeCost(b.tapDamage, 0), 10);
    expect(Economy.upgradeCost(b.tapDamage, 1), closeTo(11.2, 0.0001));
    expect(Economy.tapDamage(b, 0), 1);
    expect(Economy.autoDpsFromLevel(b, 0), 0);
    expect(Economy.autoDpsFromLevel(b, 1), closeTo(0.8 * 1.15, 0.001));
  });

  test('gold multiplier stacks upgrades and crystals', () {
    expect(Economy.goldMultiplier(b, 0, 0), 1);
    expect(Economy.goldMultiplier(b, 10, 0), closeTo(2.0, 0.0001));
    expect(Economy.goldMultiplier(b, 0, 100), closeTo(2.0, 0.0001));
  });

  test('board creatures add DPS bonus', () {
    final board = List<int?>.filled(20, null);
    board[0] = 1;
    board[1] = 3;
    expect(Economy.boardDps(b, board), 1 + 9);
    expect(Economy.totalDps(b, 0, board), 10);
  });

  test('max affordable stops when gold runs out', () {
    expect(Economy.maxAffordable(b.tapDamage, 0, 9), 0);
    expect(Economy.maxAffordable(b.tapDamage, 0, 10), 1);
    expect(Economy.maxAffordable(b.tapDamage, 0, 21.2), 2);
  });

  test('prestige crystals require stage 50', () {
    expect(Economy.prestigeCrystals(b, 49), 0);
    expect(Economy.prestigeCrystals(b, 50), closeTo(5, 0.0001));
  });
}
