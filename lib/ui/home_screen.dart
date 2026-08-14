import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../features/collection/collection_panel.dart';
import '../features/merge/merge_board.dart';
import '../features/prestige/prestige_panel.dart';
import '../features/shop/shop_panel.dart';
import '../features/upgrades/upgrades_panel.dart';
import '../game/game_controller.dart';
import '../game/hatchlings_game.dart';
import 'hud.dart';
import 'offline_popup.dart';
import 'theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  HatchlingsGame? _game;
  bool _offlineShown = false;
  GameController? _bound;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<GameController>();
    if (_bound != controller) {
      _bound = controller;
      controller.attachTicker(this);
      _game = HatchlingsGame(controller: controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    if (!controller.ready || _game == null) {
      return const Scaffold(
        backgroundColor: HatchTheme.night,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.appName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: HatchTheme.gold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                S.tagline,
                style: TextStyle(color: HatchTheme.cream),
              ),
            ],
          ),
        ),
      );
    }

    if (!_offlineShown && controller.pendingOffline != null) {
      _offlineShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final gain = controller.pendingOffline;
        if (gain == null) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => OfflinePopup(
            gain: gain,
            onCollect: () {
              controller.dismissOffline();
              Navigator.of(context).pop();
            },
          ),
        );
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HudBar(controller: controller),
            Expanded(
              flex: 55,
              child: Stack(
                children: [
                  GameWidget(game: _game!),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    child: IgnorePointer(
                      child: Text(
                        S.tapHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0x88FFF6E0),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 45,
              child: ColoredBox(
                color: HatchTheme.dusk,
                child: _LowerPanel(controller: controller),
              ),
            ),
            BottomTabs(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _LowerPanel extends StatelessWidget {
  const _LowerPanel({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.tab) {
      case HomeTab.merge:
        return MergeBoardPanel(controller: controller);
      case HomeTab.upgrades:
        return UpgradesPanel(controller: controller);
      case HomeTab.collection:
        return CollectionPanel(controller: controller);
      case HomeTab.shop:
        return ShopPanel(controller: controller);
      case HomeTab.prestige:
        return PrestigePanel(controller: controller);
    }
  }
}
