import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/creature_ids.dart';
import '../core/economy.dart';

class ContentCatalog {
  const ContentCatalog({
    required this.balance,
    required this.creatures,
    required this.lines,
  });

  final Balance balance;
  final List<CreatureDef> creatures;
  final List<LineDef> lines;

  CreatureDef creatureByCode(int code) {
    if (code == CreatureIds.egg) {
      return creatures.firstWhere(
        (c) => c.tier == 0,
        orElse: () => creatures.first,
      );
    }
    final tier = CreatureIds.tierOf(code);
    final line = CreatureIds.lineOf(code);
    return creatures.firstWhere(
      (c) => c.tier == tier && c.line == line,
      orElse: () => creatures.firstWhere(
        (c) => c.tier == tier,
        orElse: () => creatures.first,
      ),
    );
  }

  LineDef? line(int index) {
    for (final l in lines) {
      if (l.index == index) return l;
    }
    return null;
  }

  static Future<ContentCatalog> loadFromAssets() async {
    final balanceRaw = await rootBundle.loadString('assets/data/balance.json');
    final creaturesRaw = await rootBundle.loadString(
      'assets/data/creatures.json',
    );
    return fromJsonStrings(balanceRaw, creaturesRaw);
  }

  static ContentCatalog fromJsonStrings(String balanceRaw, String creaturesRaw) {
    final balanceJson = jsonDecode(balanceRaw) as Map<String, dynamic>;
    final creaturesJson = jsonDecode(creaturesRaw) as Map<String, dynamic>;
    final list = (creaturesJson['creatures'] as List<dynamic>)
        .map((e) => CreatureDef.fromJson(e as Map<String, dynamic>))
        .toList();
    final lines = (creaturesJson['lines'] as List<dynamic>? ?? [])
        .map((e) => LineDef.fromJson(e as Map<String, dynamic>))
        .toList();
    return ContentCatalog(
      balance: Balance.fromJson(balanceJson),
      creatures: list,
      lines: lines,
    );
  }
}
