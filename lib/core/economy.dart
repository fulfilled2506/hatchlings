import 'dart:math' as math;

import 'creature_ids.dart';

class UpgradeDef {
  const UpgradeDef({
    required this.id,
    required this.name,
    required this.blurb,
    required this.baseCost,
    required this.costGrowth,
    required this.baseValue,
    required this.valueGrowth,
  });

  final String id;
  final String name;
  final String blurb;
  final double baseCost;
  final double costGrowth;
  final double baseValue;
  final double valueGrowth;

  factory UpgradeDef.fromJson(Map<String, dynamic> json) {
    return UpgradeDef(
      id: json['id'] as String,
      name: json['name'] as String,
      blurb: json['blurb'] as String,
      baseCost: (json['baseCost'] as num).toDouble(),
      costGrowth: (json['costGrowth'] as num).toDouble(),
      baseValue: (json['baseValue'] as num).toDouble(),
      valueGrowth: (json['valueGrowth'] as num).toDouble(),
    );
  }
}

class EnemyBalance {
  const EnemyBalance({
    required this.baseHp,
    required this.hpGrowth,
    required this.baseGold,
    required this.goldGrowth,
    required this.bossEvery,
    required this.bossHpMult,
    required this.bossGoldMult,
  });

  final double baseHp;
  final double hpGrowth;
  final double baseGold;
  final double goldGrowth;
  final int bossEvery;
  final double bossHpMult;
  final double bossGoldMult;

  factory EnemyBalance.fromJson(Map<String, dynamic> json) {
    return EnemyBalance(
      baseHp: (json['baseHp'] as num).toDouble(),
      hpGrowth: (json['hpGrowth'] as num).toDouble(),
      baseGold: (json['baseGold'] as num).toDouble(),
      goldGrowth: (json['goldGrowth'] as num).toDouble(),
      bossEvery: (json['bossEvery'] as num?)?.toInt() ?? 10,
      bossHpMult: (json['bossHpMult'] as num?)?.toDouble() ?? 3.0,
      bossGoldMult: (json['bossGoldMult'] as num?)?.toDouble() ?? 4.0,
    );
  }

  bool isBoss(int stage) =>
      bossEvery > 0 && stage > 0 && stage % bossEvery == 0;
}

class OfflineBalance {
  const OfflineBalance({
    required this.capSeconds,
    required this.goldPerDamage,
    required this.minPopupSeconds,
    required this.maxCapLevel,
  });

  final double capSeconds;
  final double goldPerDamage;
  final double minPopupSeconds;
  final int maxCapLevel;

  factory OfflineBalance.fromJson(Map<String, dynamic> json) {
    return OfflineBalance(
      capSeconds: (json['capSeconds'] as num).toDouble(),
      goldPerDamage: (json['goldPerDamage'] as num).toDouble(),
      minPopupSeconds: (json['minPopupSeconds'] as num).toDouble(),
      maxCapLevel: (json['maxCapLevel'] as num?)?.toInt() ?? 2,
    );
  }
}

class MergeBalance {
  const MergeBalance({
    required this.cols,
    required this.rows,
    required this.spawnInterval,
    required this.killEggChance,
    required this.maxTier,
    required this.maxTierGoldBurst,
  });

  final int cols;
  final int rows;
  final double spawnInterval;
  final double killEggChance;
  final int maxTier;
  final double maxTierGoldBurst;

  int get cellCount => cols * rows;

  factory MergeBalance.fromJson(Map<String, dynamic> json) {
    return MergeBalance(
      cols: json['cols'] as int,
      rows: json['rows'] as int,
      spawnInterval: (json['spawnInterval'] as num).toDouble(),
      killEggChance: (json['killEggChance'] as num).toDouble(),
      maxTier: json['maxTier'] as int,
      maxTierGoldBurst: (json['maxTierGoldBurst'] as num).toDouble(),
    );
  }
}

class PrestigeBalance {
  const PrestigeBalance({
    required this.minStage,
    required this.crystalsPerStage,
  });

  final int minStage;
  final double crystalsPerStage;

  factory PrestigeBalance.fromJson(Map<String, dynamic> json) {
    return PrestigeBalance(
      minStage: json['minStage'] as int,
      crystalsPerStage: (json['crystalsPerStage'] as num).toDouble(),
    );
  }
}

class RelicDef {
  const RelicDef({
    required this.id,
    required this.name,
    required this.blurb,
    required this.stat,
    required this.perLevel,
    required this.baseCost,
    required this.costGrowth,
    required this.maxLevel,
  });

  final String id;
  final String name;
  final String blurb;
  final String stat;
  final double perLevel;
  final double baseCost;
  final double costGrowth;
  final int maxLevel;

  factory RelicDef.fromJson(Map<String, dynamic> json) {
    return RelicDef(
      id: json['id'] as String,
      name: json['name'] as String,
      blurb: json['blurb'] as String,
      stat: json['stat'] as String,
      perLevel: (json['perLevel'] as num).toDouble(),
      baseCost: (json['baseCost'] as num).toDouble(),
      costGrowth: (json['costGrowth'] as num).toDouble(),
      maxLevel: (json['maxLevel'] as num).toInt(),
    );
  }
}

class MissionDef {
  const MissionDef({
    required this.id,
    required this.title,
    required this.blurb,
    required this.target,
    required this.rewardGems,
  });

  final String id;
  final String title;
  final String blurb;
  final int target;
  final double rewardGems;

  String blurbFilled() => blurb.replaceAll('{target}', '$target');

  factory MissionDef.fromJson(Map<String, dynamic> json) {
    return MissionDef(
      id: json['id'] as String,
      title: json['title'] as String,
      blurb: json['blurb'] as String,
      target: (json['target'] as num).toInt(),
      rewardGems: (json['rewardGems'] as num).toDouble(),
    );
  }
}

class Balance {
  const Balance({
    required this.enemy,
    required this.upgrades,
    required this.offline,
    required this.merge,
    required this.prestige,
    required this.relicGoldPerCrystal,
    required this.creatureDps,
    required this.creatureGoldPerSec,
    required this.lineDpsMult,
    required this.goldBoostSeconds,
    required this.startingEggs,
    required this.contentStageCap,
    required this.relics,
    required this.missions,
    required this.albumLineRewardGems,
    required this.albumFullRewardGems,
  });

  final EnemyBalance enemy;
  final Map<String, UpgradeDef> upgrades;
  final OfflineBalance offline;
  final MergeBalance merge;
  final PrestigeBalance prestige;
  final double relicGoldPerCrystal;
  final List<double> creatureDps;
  final List<double> creatureGoldPerSec;
  final List<double> lineDpsMult;
  final double goldBoostSeconds;
  final int startingEggs;
  final int contentStageCap;
  final List<RelicDef> relics;
  final List<MissionDef> missions;
  final double albumLineRewardGems;
  final double albumFullRewardGems;

  UpgradeDef get tapDamage => upgrades['tapDamage']!;
  UpgradeDef get autoDps => upgrades['autoDps']!;
  UpgradeDef get goldMult => upgrades['goldMult']!;
  UpgradeDef? get offlineCap => upgrades['offlineCap'];

  RelicDef? relic(String id) {
    for (final r in relics) {
      if (r.id == id) return r;
    }
    return null;
  }

  factory Balance.fromJson(Map<String, dynamic> json) {
    final upgradeJson = json['upgrades'] as Map<String, dynamic>;
    return Balance(
      enemy: EnemyBalance.fromJson(json['enemy'] as Map<String, dynamic>),
      upgrades: upgradeJson.map(
        (key, value) => MapEntry(
          key,
          UpgradeDef.fromJson(value as Map<String, dynamic>),
        ),
      ),
      offline: OfflineBalance.fromJson(json['offline'] as Map<String, dynamic>),
      merge: MergeBalance.fromJson(json['merge'] as Map<String, dynamic>),
      prestige: PrestigeBalance.fromJson(
        json['prestige'] as Map<String, dynamic>,
      ),
      relicGoldPerCrystal: (json['relicGoldPerCrystal'] as num).toDouble(),
      creatureDps: (json['creatureDps'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      creatureGoldPerSec: (json['creatureGoldPerSec'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      lineDpsMult: (json['lineDpsMult'] as List<dynamic>? ?? [1, 1, 1])
          .map((e) => (e as num).toDouble())
          .toList(),
      goldBoostSeconds: (json['goldBoostSeconds'] as num).toDouble(),
      startingEggs: json['startingEggs'] as int,
      contentStageCap: (json['contentStageCap'] as num?)?.toInt() ?? 200,
      relics: (json['relics'] as List<dynamic>? ?? [])
          .map((e) => RelicDef.fromJson(e as Map<String, dynamic>))
          .toList(),
      missions: (json['missions'] as List<dynamic>? ?? [])
          .map((e) => MissionDef.fromJson(e as Map<String, dynamic>))
          .toList(),
      albumLineRewardGems: (json['albumLineRewardGems'] as num?)?.toDouble() ?? 25,
      albumFullRewardGems: (json['albumFullRewardGems'] as num?)?.toDouble() ?? 80,
    );
  }
}

class CreatureDef {
  const CreatureDef({
    required this.tier,
    required this.line,
    required this.id,
    required this.name,
    required this.hint,
  });

  final int tier;
  final int line;
  final String id;
  final String name;
  final String hint;

  int get code => CreatureIds.encode(line < 0 ? 0 : line, tier);

  factory CreatureDef.fromJson(Map<String, dynamic> json) {
    return CreatureDef(
      tier: json['tier'] as int,
      line: (json['line'] as num?)?.toInt() ?? 0,
      id: json['id'] as String,
      name: json['name'] as String,
      hint: json['hint'] as String,
    );
  }
}

class LineDef {
  const LineDef({required this.id, required this.name, required this.index});

  final String id;
  final String name;
  final int index;

  factory LineDef.fromJson(Map<String, dynamic> json) {
    return LineDef(
      id: json['id'] as String,
      name: json['name'] as String,
      index: (json['index'] as num).toInt(),
    );
  }
}

/// Pure combat / economy math. No Flutter, no timers.
class Economy {
  static bool isBoss(Balance balance, int stage) => balance.enemy.isBoss(stage);

  static double enemyHp(Balance balance, int stage) {
    final safeStage = math.max(1, stage);
    var hp =
        balance.enemy.baseHp * math.pow(balance.enemy.hpGrowth, safeStage - 1);
    if (isBoss(balance, safeStage)) {
      hp *= balance.enemy.bossHpMult;
    }
    return hp.toDouble();
  }

  static double enemyGold(Balance balance, int stage, double goldMultiplier) {
    final safeStage = math.max(1, stage);
    var gold =
        balance.enemy.baseGold *
        math.pow(balance.enemy.goldGrowth, safeStage - 1) *
        goldMultiplier;
    if (isBoss(balance, safeStage)) {
      gold *= balance.enemy.bossGoldMult;
    }
    return gold.toDouble();
  }

  static double upgradeCost(UpgradeDef def, int level) {
    return def.baseCost * math.pow(def.costGrowth, math.max(0, level));
  }

  static double relicCost(RelicDef def, int level) {
    return def.baseCost * math.pow(def.costGrowth, math.max(0, level));
  }

  static int maxAffordable(UpgradeDef def, int level, double gold) {
    var bought = 0;
    var remaining = gold;
    var current = level;
    while (bought < 999) {
      final cost = upgradeCost(def, current);
      if (remaining < cost) break;
      remaining -= cost;
      current += 1;
      bought += 1;
    }
    return bought;
  }

  static double relicStat(Map<String, int> levels, RelicDef def) {
    final level = levels[def.id] ?? 0;
    return def.perLevel * level;
  }

  static double relicMult(
    Balance balance,
    Map<String, int> levels,
    String stat,
  ) {
    var bonus = 0.0;
    for (final r in balance.relics) {
      if (r.stat == stat) bonus += relicStat(levels, r);
    }
    return 1 + bonus;
  }

  static double relicFlat(
    Balance balance,
    Map<String, int> levels,
    String stat,
  ) {
    var total = 0.0;
    for (final r in balance.relics) {
      if (r.stat == stat) total += relicStat(levels, r);
    }
    return total;
  }

  static double tapDamage(
    Balance balance,
    int level,
    Map<String, int> relics,
  ) {
    final def = balance.tapDamage;
    final base = level <= 0
        ? 1.0
        : def.baseValue * math.pow(def.valueGrowth, level);
    return base * relicMult(balance, relics, 'tap');
  }

  static double autoDpsFromLevel(
    Balance balance,
    int level,
    Map<String, int> relics,
  ) {
    if (level <= 0) return 0;
    final def = balance.autoDps;
    return def.baseValue *
        math.pow(def.valueGrowth, level) *
        relicMult(balance, relics, 'auto');
  }

  static double goldMultiplier(
    Balance balance,
    int level,
    double crystals,
    Map<String, int> relics,
  ) {
    final perLevel = balance.goldMult.baseValue;
    final fromUpgrades = 1 + perLevel * level;
    final fromCrystals = 1 + crystals * balance.relicGoldPerCrystal;
    return fromUpgrades * fromCrystals * relicMult(balance, relics, 'gold');
  }

  static double boardDps(
    Balance balance,
    List<int?> board,
    Map<String, int> relics,
  ) {
    var total = 0.0;
    for (final code in board) {
      if (code == null) continue;
      final tier = CreatureIds.tierOf(code);
      if (tier < 0 || tier >= balance.creatureDps.length) continue;
      final line = CreatureIds.lineOf(code);
      final lineMult = line < balance.lineDpsMult.length
          ? balance.lineDpsMult[line]
          : 1.0;
      total += balance.creatureDps[tier] * lineMult;
    }
    return total * relicMult(balance, relics, 'board');
  }

  static double boardGoldPerSec(Balance balance, List<int?> board) {
    var total = 0.0;
    for (final code in board) {
      if (code == null) continue;
      final tier = CreatureIds.tierOf(code);
      if (tier < 0 || tier >= balance.creatureGoldPerSec.length) continue;
      total += balance.creatureGoldPerSec[tier];
    }
    return total;
  }

  static double totalDps(
    Balance balance,
    int autoLevel,
    List<int?> board,
    Map<String, int> relics,
  ) {
    return autoDpsFromLevel(balance, autoLevel, relics) +
        boardDps(balance, board, relics);
  }

  static double offlineCapSeconds({
    required Balance balance,
    required int offlineCapLevel,
    required Map<String, int> relics,
  }) {
    final upgrade = balance.offlineCap;
    final fromUpgrade =
        (upgrade?.baseValue ?? 7200) * math.max(0, offlineCapLevel);
    final fromRelic = relicFlat(balance, relics, 'offlineCap');
    return balance.offline.capSeconds + fromUpgrade + fromRelic;
  }

  static double spawnInterval(
    Balance balance,
    Map<String, int> relics,
  ) {
    final mult = relicMult(balance, relics, 'spawn');
    // Higher spawn relic → faster spawns (lower interval).
    return balance.merge.spawnInterval / mult;
  }

  static double goldPerSec({
    required Balance balance,
    required int autoLevel,
    required List<int?> board,
    required int goldMultLevel,
    required double crystals,
    required bool goldBoost,
    required Map<String, int> relics,
  }) {
    final dps = totalDps(balance, autoLevel, board, relics);
    final mult = goldMultiplier(balance, goldMultLevel, crystals, relics);
    final boost = goldBoost ? 2.0 : 1.0;
    final offlineRate = relicMult(balance, relics, 'offlineRate');
    return (dps * balance.offline.goldPerDamage + boardGoldPerSec(balance, board)) *
        mult *
        boost *
        offlineRate;
  }

  static double prestigeCrystals(
    Balance balance,
    int stage,
    Map<String, int> relics,
  ) {
    if (stage < balance.prestige.minStage) return 0;
    return stage *
        balance.prestige.crystalsPerStage *
        relicMult(balance, relics, 'prestige');
  }

  static double maxTierBurst(Balance balance, int stage) {
    return balance.merge.maxTierGoldBurst *
        math.pow(balance.enemy.goldGrowth, math.max(0, stage - 1));
  }
}
