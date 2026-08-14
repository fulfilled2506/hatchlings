import 'dart:math' as math;

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
  });

  final double baseHp;
  final double hpGrowth;
  final double baseGold;
  final double goldGrowth;

  factory EnemyBalance.fromJson(Map<String, dynamic> json) {
    return EnemyBalance(
      baseHp: (json['baseHp'] as num).toDouble(),
      hpGrowth: (json['hpGrowth'] as num).toDouble(),
      baseGold: (json['baseGold'] as num).toDouble(),
      goldGrowth: (json['goldGrowth'] as num).toDouble(),
    );
  }
}

class OfflineBalance {
  const OfflineBalance({
    required this.capSeconds,
    required this.goldPerDamage,
    required this.minPopupSeconds,
  });

  final double capSeconds;
  final double goldPerDamage;
  final double minPopupSeconds;

  factory OfflineBalance.fromJson(Map<String, dynamic> json) {
    return OfflineBalance(
      capSeconds: (json['capSeconds'] as num).toDouble(),
      goldPerDamage: (json['goldPerDamage'] as num).toDouble(),
      minPopupSeconds: (json['minPopupSeconds'] as num).toDouble(),
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
    required this.goldBoostSeconds,
    required this.startingEggs,
  });

  final EnemyBalance enemy;
  final Map<String, UpgradeDef> upgrades;
  final OfflineBalance offline;
  final MergeBalance merge;
  final PrestigeBalance prestige;
  final double relicGoldPerCrystal;
  final List<double> creatureDps;
  final List<double> creatureGoldPerSec;
  final double goldBoostSeconds;
  final int startingEggs;

  UpgradeDef get tapDamage => upgrades['tapDamage']!;
  UpgradeDef get autoDps => upgrades['autoDps']!;
  UpgradeDef get goldMult => upgrades['goldMult']!;

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
      goldBoostSeconds: (json['goldBoostSeconds'] as num).toDouble(),
      startingEggs: json['startingEggs'] as int,
    );
  }
}

class CreatureDef {
  const CreatureDef({
    required this.tier,
    required this.id,
    required this.name,
    required this.hint,
  });

  final int tier;
  final String id;
  final String name;
  final String hint;

  factory CreatureDef.fromJson(Map<String, dynamic> json) {
    return CreatureDef(
      tier: json['tier'] as int,
      id: json['id'] as String,
      name: json['name'] as String,
      hint: json['hint'] as String,
    );
  }
}

/// Pure combat / economy math. No Flutter, no timers.
class Economy {
  static double enemyHp(Balance balance, int stage) {
    final safeStage = math.max(1, stage);
    return balance.enemy.baseHp *
        math.pow(balance.enemy.hpGrowth, safeStage - 1);
  }

  static double enemyGold(Balance balance, int stage, double goldMultiplier) {
    final safeStage = math.max(1, stage);
    return balance.enemy.baseGold *
        math.pow(balance.enemy.goldGrowth, safeStage - 1) *
        goldMultiplier;
  }

  static double upgradeCost(UpgradeDef def, int level) {
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

  static double tapDamage(Balance balance, int level) {
    final def = balance.tapDamage;
    if (level <= 0) return 1;
    return def.baseValue * math.pow(def.valueGrowth, level);
  }

  static double autoDpsFromLevel(Balance balance, int level) {
    if (level <= 0) return 0;
    final def = balance.autoDps;
    return def.baseValue * math.pow(def.valueGrowth, level);
  }

  static double goldMultiplier(Balance balance, int level, double crystals) {
    final perLevel = balance.goldMult.baseValue;
    final fromUpgrades = 1 + perLevel * level;
    final fromRelics = 1 + crystals * balance.relicGoldPerCrystal;
    return fromUpgrades * fromRelics;
  }

  static double boardDps(Balance balance, List<int?> board) {
    var total = 0.0;
    for (final tier in board) {
      if (tier == null) continue;
      if (tier < 0 || tier >= balance.creatureDps.length) continue;
      total += balance.creatureDps[tier];
    }
    return total;
  }

  static double boardGoldPerSec(Balance balance, List<int?> board) {
    var total = 0.0;
    for (final tier in board) {
      if (tier == null) continue;
      if (tier < 0 || tier >= balance.creatureGoldPerSec.length) continue;
      total += balance.creatureGoldPerSec[tier];
    }
    return total;
  }

  static double totalDps(Balance balance, int autoLevel, List<int?> board) {
    return autoDpsFromLevel(balance, autoLevel) + boardDps(balance, board);
  }

  static double goldPerSec({
    required Balance balance,
    required int autoLevel,
    required List<int?> board,
    required int goldMultLevel,
    required double crystals,
    required bool goldBoost,
  }) {
    final dps = totalDps(balance, autoLevel, board);
    final mult = goldMultiplier(balance, goldMultLevel, crystals);
    final boost = goldBoost ? 2.0 : 1.0;
    return (dps * balance.offline.goldPerDamage +
            boardGoldPerSec(balance, board)) *
        mult *
        boost;
  }

  static double prestigeCrystals(Balance balance, int stage) {
    if (stage < balance.prestige.minStage) return 0;
    return stage * balance.prestige.crystalsPerStage;
  }

  static double maxTierBurst(Balance balance, int stage) {
    return balance.merge.maxTierGoldBurst *
        math.pow(balance.enemy.goldGrowth, math.max(0, stage - 1));
  }
}
