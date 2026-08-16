import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../core/creature_ids.dart';
import '../core/economy.dart';
import '../core/game_state.dart';
import '../data/content_catalog.dart';
import '../data/monetization.dart';
import '../data/save_repository.dart';

class FloatingHit {
  FloatingHit({required this.damage, required this.nx, required this.ny});

  final double damage;
  final double nx;
  final double ny;
}

enum HomeTab { merge, upgrades, collection, shop, prestige }

class GameController extends ChangeNotifier with WidgetsBindingObserver {
  GameController({
    required this.catalog,
    required SaveRepository save,
    Monetization? monetization,
    math.Random? random,
    TickerProvider? vsync,
    DateTime Function()? clock,
  }) : _save = save,
       monetization = monetization ?? StubMonetization(),
       _rng = random ?? math.Random(),
       _clock = clock ?? DateTime.now,
       snapshot = GameSnapshot.fresh(catalog.balance) {
    if (vsync != null) {
      _ticker = vsync.createTicker(_onTick)..start();
    }
  }

  final ContentCatalog catalog;
  final SaveRepository _save;
  final Monetization monetization;
  final math.Random _rng;
  final DateTime Function() _clock;

  Balance get balance => catalog.balance;

  GameSnapshot snapshot;

  bool ready = false;
  OfflineGain? pendingOffline;
  HomeTab tab = HomeTab.merge;
  int combo = 1;
  double goldBoostLeft = 0;
  double lastHitFlash = 0;
  int lastKillAtMs = 0;
  FloatingHit? lastHit;
  String? toast;

  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;
  double _spawnAcc = 0;
  double _saveAcc = 0;
  double _comboAcc = 1e9;
  double _uiAcc = 0;
  bool _boundLifecycle = false;

  bool get goldBoostActive => goldBoostLeft > 0;
  bool get onboardingActive => snapshot.onboardingStep < 2;
  bool get isBossStage => Economy.isBoss(balance, snapshot.stage);

  Map<String, int> get relics => snapshot.relicLevels;

  double get tapDamage =>
      Economy.tapDamage(balance, snapshot.tapLevel, relics);

  double get autoDps => Economy.totalDps(
    balance,
    snapshot.autoLevel,
    snapshot.board,
    relics,
  );

  double get goldMult => Economy.goldMultiplier(
    balance,
    snapshot.goldMultLevel,
    snapshot.timeCrystals,
    relics,
  );

  double get goldPerSec => Economy.goldPerSec(
    balance: balance,
    autoLevel: snapshot.autoLevel,
    board: snapshot.board,
    goldMultLevel: snapshot.goldMultLevel,
    crystals: snapshot.timeCrystals,
    goldBoost: goldBoostActive,
    relics: relics,
  );

  double get offlineCapSeconds => Economy.offlineCapSeconds(
    balance: balance,
    offlineCapLevel: snapshot.offlineCapLevel,
    relics: relics,
  );

  double get hpRatio {
    if (snapshot.enemyMaxHp <= 0) return 0;
    return (snapshot.enemyHp / snapshot.enemyMaxHp).clamp(0, 1);
  }

  bool get canPrestige =>
      snapshot.stage >= balance.prestige.minStage ||
      snapshot.highestStage >= balance.prestige.minStage;

  double get nextPrestigeCrystals =>
      Economy.prestigeCrystals(balance, snapshot.stage, relics);

  Future<void> load() async {
    snapshot = await _save.load(balance);
    _ensureMissionDay();
    final now = _clock().millisecondsSinceEpoch;
    final gain = OfflineCalculator.compute(
      balance: balance,
      snapshot: snapshot,
      nowMs: now,
      goldBoost: false,
    );
    if (gain.cappedSeconds > 0) {
      OfflineCalculator.apply(snapshot, gain);
    }
    pendingOffline = gain.shouldShow ? gain : null;
    snapshot.lastSaveMs = now;
    ready = true;
    if (!_boundLifecycle) {
      WidgetsBinding.instance.addObserver(this);
      _boundLifecycle = true;
    }
    notifyListeners();
    await persist();
  }

  void attachTicker(TickerProvider vsync) {
    _ticker?.dispose();
    _lastElapsed = Duration.zero;
    _ticker = vsync.createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!ready) {
      _lastElapsed = elapsed;
      return;
    }
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt <= 0 || dt > 0.25) return;
    tick(dt);
  }

  void tick(double dt) {
    _comboAcc += dt;
    if (_comboAcc > 0.45) combo = 1;
    if (goldBoostLeft > 0) {
      goldBoostLeft = math.max(0, goldBoostLeft - dt);
    }
    if (lastHitFlash > 0) {
      lastHitFlash = math.max(0, lastHitFlash - dt);
    }

    final interval = Economy.spawnInterval(balance, relics);
    _spawnAcc += dt;
    if (_spawnAcc >= interval) {
      _spawnAcc = 0;
      trySpawnEgg();
    }

    final stageBefore = snapshot.stage;
    dealDamage(autoDps * dt, fromTap: false, notify: false);

    _saveAcc += dt;
    if (_saveAcc >= 5) {
      _saveAcc = 0;
      persist();
    }

    _uiAcc += dt;
    if (_uiAcc >= 0.12 || snapshot.stage != stageBefore) {
      _uiAcc = 0;
      notifyListeners();
    }
  }

  double performTap({double nx = 0.5, double ny = 0.5}) {
    if (_comboAcc <= 0.45) {
      combo = math.min(20, combo + 1);
    } else {
      combo = 1;
    }
    _comboAcc = 0;
    final dmg = tapDamage * (1 + (combo - 1) * 0.06);
    lastHit = FloatingHit(damage: dmg, nx: nx, ny: ny);
    _haptic(false);
    if (snapshot.onboardingStep == 0) {
      snapshot.onboardingStep = 1;
    }
    dealDamage(dmg, fromTap: true);
    return dmg;
  }

  void dealDamage(double amount, {required bool fromTap, bool notify = true}) {
    if (amount <= 0) return;
    snapshot.enemyHp -= amount;
    if (fromTap) lastHitFlash = 0.12;
    var safety = 0;
    while (snapshot.enemyHp <= 0 && safety < 40) {
      safety += 1;
      _onKill();
    }
    if (notify) notifyListeners();
  }

  void _haptic(bool medium) {
    try {
      if (medium) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    } catch (_) {}
  }

  void _onKill() {
    final reward =
        Economy.enemyGold(balance, snapshot.stage, goldMult) *
        (goldBoostActive ? 2 : 1);
    snapshot.gold += reward;
    lastKillAtMs = _clock().millisecondsSinceEpoch;
    if (_rng.nextDouble() < balance.merge.killEggChance) {
      trySpawnEgg();
    }
    snapshot.stagesClearedToday += 1;
    _bumpMission('stages', 1);
    snapshot.stage += 1;
    if (snapshot.stage > snapshot.highestStage) {
      snapshot.highestStage = snapshot.stage;
    }
    if (snapshot.stage > balance.contentStageCap) {
      // Soft wall: still playable but content paced to 200.
    }
    final hp = Economy.enemyHp(balance, snapshot.stage);
    snapshot.enemyMaxHp = hp;
    snapshot.enemyHp += hp;
  }

  bool trySpawnEgg() {
    final empty = <int>[];
    for (var i = 0; i < snapshot.board.length; i++) {
      if (snapshot.board[i] == null) empty.add(i);
    }
    if (empty.isEmpty) return false;
    final slot = empty[_rng.nextInt(empty.length)];
    snapshot.board[slot] = CreatureIds.egg;
    snapshot.discovered.add(CreatureIds.egg);
    notifyListeners();
    return true;
  }

  /// Drag [from] onto [to]. 3-of-a-kind evolves; otherwise move/swap.
  bool dropTile(int from, int to) {
    if (from == to) return false;
    if (from < 0 ||
        to < 0 ||
        from >= snapshot.board.length ||
        to >= snapshot.board.length) {
      return false;
    }
    final a = snapshot.board[from];
    final b = snapshot.board[to];
    if (a == null) return false;

    if (b == null) {
      snapshot.board[to] = a;
      snapshot.board[from] = null;
      notifyListeners();
      return true;
    }

    if (a == b) {
      final third = _findThird(a, from, to);
      if (third != null) {
        snapshot.board[from] = null;
        snapshot.board[third] = null;
        final next = _mergeResult(a);
        snapshot.board[to] = next;
        snapshot.discovered.add(next);
        _bumpMission('merges', 1);
        if (snapshot.onboardingStep == 1) {
          snapshot.onboardingStep = 2;
        }
        _checkAlbumRewards();
        _haptic(true);
        notifyListeners();
        return true;
      }
    }

    snapshot.board[from] = b;
    snapshot.board[to] = a;
    notifyListeners();
    return true;
  }

  int _mergeResult(int code) {
    if (code == CreatureIds.egg) {
      final line = _rng.nextInt(CreatureIds.lineCount);
      return CreatureIds.encode(line, 1);
    }
    final evolved = CreatureIds.evolved(
      code,
      maxTier: balance.merge.maxTier,
    );
    if (evolved == null) {
      snapshot.gold +=
          Economy.maxTierBurst(balance, snapshot.stage) *
          (goldBoostActive ? 2 : 1);
      return code;
    }
    return evolved;
  }

  int? _findThird(int code, int from, int to) {
    for (var i = 0; i < snapshot.board.length; i++) {
      if (i == from || i == to) continue;
      if (snapshot.board[i] == code) return i;
    }
    return null;
  }

  bool buyUpgrade(String id, {int times = 1}) {
    final def = balance.upgrades[id];
    if (def == null) return false;
    if (id == 'offlineCap' &&
        snapshot.offlineCapLevel >= balance.offline.maxCapLevel) {
      return false;
    }
    var bought = 0;
    for (var i = 0; i < times; i++) {
      if (id == 'offlineCap' &&
          snapshot.offlineCapLevel >= balance.offline.maxCapLevel) {
        break;
      }
      final level = _levelOf(id);
      final cost = Economy.upgradeCost(def, level);
      if (snapshot.gold < cost) break;
      snapshot.gold -= cost;
      _setLevel(id, level + 1);
      bought += 1;
    }
    if (bought == 0) return false;
    notifyListeners();
    return true;
  }

  bool buyMax(String id) {
    final def = balance.upgrades[id];
    if (def == null) return false;
    var n = Economy.maxAffordable(def, _levelOf(id), snapshot.gold);
    if (id == 'offlineCap') {
      final room = balance.offline.maxCapLevel - snapshot.offlineCapLevel;
      n = math.min(n, room);
    }
    if (n <= 0) return false;
    return buyUpgrade(id, times: n);
  }

  bool buyRelic(String id) {
    final def = balance.relic(id);
    if (def == null) return false;
    final level = snapshot.relicLevels[id] ?? 0;
    if (level >= def.maxLevel) return false;
    final cost = Economy.relicCost(def, level);
    if (snapshot.timeCrystals < cost) return false;
    snapshot.timeCrystals -= cost;
    snapshot.relicLevels[id] = level + 1;
    _flashToast('Bought ${def.name}');
    notifyListeners();
    persist();
    return true;
  }

  int _levelOf(String id) {
    switch (id) {
      case 'tapDamage':
        return snapshot.tapLevel;
      case 'autoDps':
        return snapshot.autoLevel;
      case 'goldMult':
        return snapshot.goldMultLevel;
      case 'offlineCap':
        return snapshot.offlineCapLevel;
      default:
        return 0;
    }
  }

  void _setLevel(String id, int level) {
    switch (id) {
      case 'tapDamage':
        snapshot.tapLevel = level;
      case 'autoDps':
        snapshot.autoLevel = level;
      case 'goldMult':
        snapshot.goldMultLevel = level;
      case 'offlineCap':
        snapshot.offlineCapLevel = level;
    }
  }

  double upgradeValue(String id) {
    switch (id) {
      case 'tapDamage':
        return tapDamage;
      case 'autoDps':
        return Economy.autoDpsFromLevel(balance, snapshot.autoLevel, relics);
      case 'goldMult':
        return goldMult;
      case 'offlineCap':
        return offlineCapSeconds / 3600;
      default:
        return 0;
    }
  }

  int levelOf(String id) => _levelOf(id);

  double costOf(String id) {
    final def = balance.upgrades[id]!;
    return Economy.upgradeCost(def, _levelOf(id));
  }

  void selectTab(HomeTab next) {
    tab = next;
    notifyListeners();
  }

  void dismissOffline() {
    if (pendingOffline != null) {
      _bumpMission('offline', 1);
    }
    pendingOffline = null;
    notifyListeners();
  }

  void advanceOnboarding() {
    if (snapshot.onboardingStep < 2) {
      snapshot.onboardingStep += 1;
      notifyListeners();
    }
  }

  void skipOnboarding() {
    snapshot.onboardingStep = 2;
    notifyListeners();
    persist();
  }

  void clearToast() {
    toast = null;
  }

  void _flashToast(String message) {
    toast = message;
  }

  String _dayKey(DateTime dt) =>
      '${dt.toUtc().year.toString().padLeft(4, '0')}-'
      '${dt.toUtc().month.toString().padLeft(2, '0')}-'
      '${dt.toUtc().day.toString().padLeft(2, '0')}';

  void _ensureMissionDay() {
    final today = _dayKey(_clock());
    if (snapshot.missionDay == today) return;
    snapshot.missionDay = today;
    snapshot.missionProgress = {};
    snapshot.missionClaimed = {};
    snapshot.stagesClearedToday = 0;
  }

  void _bumpMission(String id, int amount) {
    _ensureMissionDay();
    final current = snapshot.missionProgress[id] ?? 0;
    snapshot.missionProgress[id] = current + amount;
  }

  int missionProgress(String id) {
    _ensureMissionDay();
    return snapshot.missionProgress[id] ?? 0;
  }

  bool missionClaimed(String id) => snapshot.missionClaimed.contains(id);

  bool canClaimMission(String id) {
    MissionDef? def;
    for (final m in balance.missions) {
      if (m.id == id) def = m;
    }
    if (def == null) return false;
    if (missionClaimed(id)) return false;
    return missionProgress(id) >= def.target;
  }

  bool claimMission(String id) {
    if (!canClaimMission(id)) return false;
    final def = balance.missions.firstWhere((m) => m.id == id);
    snapshot.missionClaimed.add(id);
    snapshot.gems += def.rewardGems;
    _flashToast('+${def.rewardGems.toInt()} gems');
    notifyListeners();
    persist();
    return true;
  }

  void _checkAlbumRewards() {
    for (var line = 0; line < CreatureIds.lineCount; line++) {
      final key = 'line_$line';
      if (snapshot.albumClaims.contains(key)) continue;
      final codes = CreatureIds.lineCodes(line);
      if (codes.every(snapshot.discovered.contains)) {
        snapshot.albumClaims.add(key);
        snapshot.gems += balance.albumLineRewardGems;
        final name = catalog.line(line)?.name ?? 'Line';
        _flashToast('$name album complete! +${balance.albumLineRewardGems.toInt()} gems');
      }
    }
    const fullKey = 'album_full';
    if (!snapshot.albumClaims.contains(fullKey)) {
      final all = CreatureIds.allDiscoverable();
      if (all.every(snapshot.discovered.contains)) {
        snapshot.albumClaims.add(fullKey);
        snapshot.gems += balance.albumFullRewardGems;
        _flashToast('Full album! +${balance.albumFullRewardGems.toInt()} gems');
      }
    }
  }

  Future<void> watchGoldBoost() async {
    final ok = await monetization.watchRewardedAd();
    if (!ok) return;
    goldBoostLeft = balance.goldBoostSeconds;
    notifyListeners();
  }

  Future<void> buyGemsStub() async {
    final ok = await monetization.purchaseGems();
    if (!ok) return;
    snapshot.gems += 100;
    notifyListeners();
    await persist();
  }

  Future<void> buyRemoveAdsStub() async {
    final ok = await monetization.purchaseRemoveAds();
    if (!ok) return;
    snapshot.adsRemoved = true;
    notifyListeners();
    await persist();
  }

  bool rebirth() {
    if (!canPrestige) return false;
    final gained = Economy.prestigeCrystals(balance, snapshot.stage, relics);
    snapshot.timeCrystals += gained;
    snapshot.prestigeCount += 1;
    snapshot.gold = 0;
    snapshot.tapLevel = 0;
    snapshot.autoLevel = 0;
    snapshot.goldMultLevel = 0;
    // offlineCapLevel + relics + album persist
    snapshot.stage = 1;
    final hp = Economy.enemyHp(balance, 1);
    snapshot.enemyHp = hp;
    snapshot.enemyMaxHp = hp;
    snapshot.board = List<int?>.filled(balance.merge.cellCount, null);
    for (var i = 0; i < balance.startingEggs && i < snapshot.board.length; i++) {
      snapshot.board[i] = CreatureIds.egg;
    }
    goldBoostLeft = 0;
    combo = 1;
    notifyListeners();
    persist();
    return true;
  }

  Future<void> persist() async {
    await _save.save(snapshot);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      persist();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    if (_boundLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
    }
    persist();
    super.dispose();
  }
}
