import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/economy.dart';
import '../core/game_state.dart';

abstract class SaveStore {
  Future<String?> read();
  Future<void> write(String json);
  Future<void> clear();
}

class SharedPrefsSaveStore implements SaveStore {
  SharedPrefsSaveStore({this.key = 'hatchlings.save.v1'});

  final String key;
  SharedPreferences? _prefs;

  Future<SharedPreferences> _ready() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<String?> read() async {
    final prefs = await _ready();
    return prefs.getString(key);
  }

  @override
  Future<void> write(String json) async {
    final prefs = await _ready();
    await prefs.setString(key, json);
  }

  @override
  Future<void> clear() async {
    final prefs = await _ready();
    await prefs.remove(key);
  }
}

class MemorySaveStore implements SaveStore {
  MemorySaveStore([this.data]);

  String? data;

  @override
  Future<String?> read() async => data;

  @override
  Future<void> write(String json) async => data = json;

  @override
  Future<void> clear() async => data = null;
}

class SaveRepository {
  /// JSON blob on [SaveStore]. Swap the store for Isar later without
  /// touching combat or economy math.
  SaveRepository(this.store);

  final SaveStore store;

  Future<GameSnapshot> load(Balance balance) async {
    final raw = await store.read();
    if (raw == null || raw.isEmpty) {
      return GameSnapshot.fresh(balance);
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return GameSnapshot.fromJson(json, balance);
    } catch (_) {
      return GameSnapshot.fresh(balance);
    }
  }

  Future<void> save(GameSnapshot snapshot) async {
    snapshot.lastSaveMs = DateTime.now().millisecondsSinceEpoch;
    await store.write(jsonEncode(snapshot.toJson()));
  }

  Future<void> reset() => store.clear();
}
