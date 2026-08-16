import 'creature_ids.dart';
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
    required this.offlineCapLevel,
    required this.board,
    required this.lastSaveMs,
    required this.discovered,
    required this.prestigeCount,
    required this.adsRemoved,
    required this.highestStage,
    required this.relicLevels,
    required this.missionDay,
    required this.missionProgress,
    required this.missionClaimed,
    required this.albumClaims,
    required this.onboardingStep,
    required this.stagesClearedToday,
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
  int offlineCapLevel;
  List<int?> board;
  int lastSaveMs;
  Set<int> discovered;
  int prestigeCount;
  bool adsRemoved;
  int highestStage;
  Map<String, int> relicLevels;
  String missionDay;
  Map<String, int> missionProgress;
  Set<String> missionClaimed;
  Set<String> albumClaims;
  int onboardingStep;
  int stagesClearedToday;

  factory GameSnapshot.fresh(Balance balance) {
    final hp = Economy.enemyHp(balance, 1);
    final board = List<int?>.filled(balance.merge.cellCount, null);
    for (var i = 0; i < balance.startingEggs && i < board.length; i++) {
      board[i] = CreatureIds.egg;
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
      offlineCapLevel: 0,
      board: board,
      lastSaveMs: DateTime.now().millisecondsSinceEpoch,
      discovered: {CreatureIds.egg},
      prestigeCount: 0,
      adsRemoved: false,
      highestStage: 1,
      relicLevels: {},
      missionDay: '',
      missionProgress: {},
      missionClaimed: {},
      albumClaims: {},
      onboardingStep: 0,
      stagesClearedToday: 0,
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

    final relicsRaw = json['relicLevels'] as Map<String, dynamic>? ?? {};
    final missionProg =
        json['missionProgress'] as Map<String, dynamic>? ?? {};

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
      offlineCapLevel: (json['offlineCapLevel'] as num?)?.toInt() ?? 0,
      board: board,
      lastSaveMs:
          (json['lastSaveMs'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      discovered: {
        CreatureIds.egg,
        ...((json['discovered'] as List<dynamic>? ?? [])
            .map((e) => (e as num).toInt())),
      },
      prestigeCount: (json['prestigeCount'] as num?)?.toInt() ?? 0,
      adsRemoved: json['adsRemoved'] as bool? ?? false,
      highestStage: (json['highestStage'] as num?)?.toInt() ?? stage,
      relicLevels: relicsRaw.map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ),
      missionDay: json['missionDay'] as String? ?? '',
      missionProgress: missionProg.map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ),
      missionClaimed: {
        ...((json['missionClaimed'] as List<dynamic>? ?? [])
            .map((e) => e as String)),
      },
      albumClaims: {
        ...((json['albumClaims'] as List<dynamic>? ?? [])
            .map((e) => e as String)),
      },
      onboardingStep: (json['onboardingStep'] as num?)?.toInt() ?? 2,
      stagesClearedToday: (json['stagesClearedToday'] as num?)?.toInt() ?? 0,
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
      'offlineCapLevel': offlineCapLevel,
      'board': board,
      'lastSaveMs': lastSaveMs,
      'discovered': discovered.toList()..sort(),
      'prestigeCount': prestigeCount,
      'adsRemoved': adsRemoved,
      'highestStage': highestStage,
      'relicLevels': relicLevels,
      'missionDay': missionDay,
      'missionProgress': missionProgress,
      'missionClaimed': missionClaimed.toList()..sort(),
      'albumClaims': albumClaims.toList()..sort(),
      'onboardingStep': onboardingStep,
      'stagesClearedToday': stagesClearedToday,
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
    final cap = Economy.offlineCapSeconds(
      balance: balance,
      offlineCapLevel: snapshot.offlineCapLevel,
      relics: snapshot.relicLevels,
    );
    final capped = elapsed.clamp(0, cap).toDouble();

    final gps = Economy.goldPerSec(
      balance: balance,
      autoLevel: snapshot.autoLevel,
      board: snapshot.board,
      goldMultLevel: snapshot.goldMultLevel,
      crystals: snapshot.timeCrystals,
      goldBoost: goldBoost,
      relics: snapshot.relicLevels,
    );
    final gold = gps * capped;

    final empty = snapshot.board.where((e) => e == null).length;
    final interval = Economy.spawnInterval(balance, snapshot.relicLevels);
    final possible = (capped / interval).floor();
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
        snapshot.board[i] = CreatureIds.egg;
        remaining -= 1;
      }
    }
  }
}
