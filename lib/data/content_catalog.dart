import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/economy.dart';

class ContentCatalog {
  const ContentCatalog({required this.balance, required this.creatures});

  final Balance balance;
  final List<CreatureDef> creatures;

  CreatureDef creature(int tier) {
    return creatures.firstWhere(
      (c) => c.tier == tier,
      orElse: () => creatures.first,
    );
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
    return ContentCatalog(
      balance: Balance.fromJson(balanceJson),
      creatures: list,
    );
  }
}
