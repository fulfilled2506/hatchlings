import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../data/content_catalog.dart';
import '../data/save_repository.dart';
import '../game/game_controller.dart';
import '../ui/home_screen.dart';
import '../ui/theme.dart';

class HatchlingsApp extends StatelessWidget {
  const HatchlingsApp({
    super.key,
    required this.catalog,
    required this.save,
  });

  final ContentCatalog catalog;
  final SaveRepository save;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(catalog: catalog, save: save)..load(),
      child: MaterialApp(
        title: S.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: HatchTheme.night,
          colorScheme: ColorScheme.fromSeed(
            seedColor: HatchTheme.accent,
            brightness: Brightness.dark,
          ),
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
