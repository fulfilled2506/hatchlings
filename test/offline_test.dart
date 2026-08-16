import 'package:flutter_test/flutter_test.dart';

import 'package:hatchlings/core/economy.dart';
import 'package:hatchlings/core/game_state.dart';

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
      'maxCapLevel': 2,
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
    'creatureGoldPerSec': [0, 1, 0, 0, 0, 0, 0],
    'lineDpsMult': [1, 1, 1],
    'goldBoostSeconds': 300,
    'startingEggs': 3,
    'contentStageCap': 200,
    'relics': [],
    'missions': [],
    'albumLineRewardGems': 25,
    'albumFullRewardGems': 80,
  });
}

void main() {
  test('offline gold uses DPS and caps at 8 hours', () {
    final b = _balance();
    final snap = GameSnapshot.fresh(b);
    snap.autoLevel = 1;
    snap.board = List<int?>.filled(20, null);
    snap.lastSaveMs = 0;
    final eightHours = OfflineCalculator.compute(
      balance: b,
      snapshot: snap,
      nowMs: 1000 * 60 * 60 * 9,
      goldBoost: false,
    );
    expect(eightHours.cappedSeconds, 28800);
    expect(eightHours.elapsedSeconds, 32400);
    expect(eightHours.gold, greaterThan(0));
    expect(eightHours.shouldShow, isTrue);
  });

  test('offline eggs fill empty nest slots only', () {
    final b = _balance();
    final snap = GameSnapshot.fresh(b);
    snap.board = List<int?>.filled(20, null);
    snap.lastSaveMs = 0;
    final gain = OfflineCalculator.compute(
      balance: b,
      snapshot: snap,
      nowMs: 60 * 1000,
      goldBoost: false,
    );
    expect(gain.eggs, 10);
    OfflineCalculator.apply(snap, gain);
    expect(snap.board.where((e) => e == 0).length, 10);
  });

  test('short absences do not pop the recap', () {
    final b = _balance();
    final snap = GameSnapshot.fresh(b);
    snap.lastSaveMs = 0;
    final gain = OfflineCalculator.compute(
      balance: b,
      snapshot: snap,
      nowMs: 10 * 1000,
      goldBoost: false,
    );
    expect(gain.shouldShow, isFalse);
  });
}
