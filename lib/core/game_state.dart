import 'economy.dart';

class GameSnapshot {
  GameSnapshot({
    required this.gold,
    required this.gems,
    required this.timeCrystals,
    required this.stage,
    required this.enemyHp,
    required this.enemyMaxHp,
    required this.tapLevel,
    required this.autoLevel,
    required this.goldMultLevel,
    required this.board,
    required this.lastSaveMs,
    required this.discovered,
    required this.prestigeCount,
    required this.adsRemoved,
    required this.highestStage,
  });

  double gold;
  double gems;
  double timeCrystals;
  int stage;
  double enemyHp;
  double enemyMaxHp;
  int tapLevel;
  int autoLevel;
  int goldMultLevel;
  List<int?> board;
  int lastSaveMs;
  Set<int> discovered;
  int prestigeCount;
  bool adsRemoved;
  int highestStage;

  factory GameSnapshot.fresh(Balance balance) {
    final hp = Economy.enemyHp(balance, 1);
    final board = List<int?>.filled(balance.merge.cellCount, null);
    for (var i = 0; i < balance.startingEggs && i < board.length; i++) {
      board[i] = 0;
    }
    return GameSnapshot(
      gold: 0,
      gems: 0,
      timeCrystals: 0,
      stage: 1,
      enemyHp: hp,
      enemyMaxHp: hp,
      tapLevel: 0,
      autoLevel: 0,
      goldMultLevel: 0,
      board: board,
      lastSaveMs: DateTime.now().millisecondsSinceEpoch,
      discovered: {0},
      prestigeCount: 0,
      adsRemoved: false,
      highestStage: 1,
    );
  }

  factory GameSnapshot.fromJson(Map<String, dynamic> json, Balance balance) {
    final boardRaw = (json['board'] as List<dynamic>? ?? [])
        .map((e) => e == null ? null : (e as num).toInt())
        .toList();
    final cells = balance.merge.cellCount;
    final board = List<int?>.filled(cells, null);
    for (var i = 0; i < cells && i < boardRaw.length; i++) {
      board[i] = boardRaw[i];
    }

    final stage = (json['stage'] as num?)?.toInt() ?? 1;
    final maxHp = Economy.enemyHp(balance, stage);
    final hp = (json['enemyHp'] as num?)?.toDouble() ?? maxHp;

    return GameSnapshot(
      gold: (json['gold'] as num?)?.toDouble() ?? 0,
      gems: (json['gems'] as num?)?.toDouble() ?? 0,
      timeCrystals: (json['timeCrystals'] as num?)?.toDouble() ?? 0,
      stage: stage,
      enemyHp: hp.clamp(0, maxHp).toDouble(),
      enemyMaxHp: maxHp,
      tapLevel: (json['tapLevel'] as num?)?.toInt() ?? 0,
      autoLevel: (json['autoLevel'] as num?)?.toInt() ?? 0,
      goldMultLevel: (json['goldMultLevel'] as num?)?.toInt() ?? 0,
      board: board,
      lastSaveMs:
          (json['lastSaveMs'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      discovered: {
        0,
        ...((json['discovered'] as List<dynamic>? ?? [])
            .map((e) => (e as num).toInt())),
      },
      prestigeCount: (json['prestigeCount'] as num?)?.toInt() ?? 0,
      adsRemoved: json['adsRemoved'] as bool? ?? false,
      highestStage: (json['highestStage'] as num?)?.toInt() ?? stage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gold': gold,
      'gems': gems,
      'timeCrystals': timeCrystals,
      'stage': stage,
      'enemyHp': enemyHp,
      'tapLevel': tapLevel,
      'autoLevel': autoLevel,
      'goldMultLevel': goldMultLevel,
      'board': board,
      'lastSaveMs': lastSaveMs,
      'discovered': discovered.toList()..sort(),
      'prestigeCount': prestigeCount,
      'adsRemoved': adsRemoved,
      'highestStage': highestStage,
    };
  }
}

class OfflineGain {
  const OfflineGain({
    required this.elapsedSeconds,
    required this.cappedSeconds,
    required this.gold,
    required this.eggs,
  });

  final double elapsedSeconds;
  final double cappedSeconds;
  final double gold;
  final int eggs;

  bool get shouldShow => elapsedSeconds >= 30 && gold > 0;
}

class OfflineCalculator {
  static OfflineGain compute({
    required Balance balance,
    required GameSnapshot snapshot,
    required int nowMs,
    required bool goldBoost,
  }) {
    final elapsedMs = nowMs - snapshot.lastSaveMs;
    final elapsed = (elapsedMs / 1000).clamp(0, 1e9).toDouble();
    final capped = elapsed.clamp(0, balance.offline.capSeconds).toDouble();

    final gps = Economy.goldPerSec(
      balance: balance,
      autoLevel: snapshot.autoLevel,
      board: snapshot.board,
      goldMultLevel: snapshot.goldMultLevel,
      crystals: snapshot.timeCrystals,
      goldBoost: goldBoost,
    );
    final gold = gps * capped;

    final empty = snapshot.board.where((e) => e == null).length;
    final possible = (capped / balance.merge.spawnInterval).floor();
    final eggs = possible.clamp(0, empty);

    return OfflineGain(
      elapsedSeconds: elapsed,
      cappedSeconds: capped,
      gold: gold,
      eggs: eggs,
    );
  }

  static void apply(GameSnapshot snapshot, OfflineGain gain) {
    snapshot.gold += gain.gold;
    var remaining = gain.eggs;
    for (var i = 0; i < snapshot.board.length && remaining > 0; i++) {
      if (snapshot.board[i] == null) {
        snapshot.board[i] = 0;
        remaining -= 1;
      }
    }
  }
}
