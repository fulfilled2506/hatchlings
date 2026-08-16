import 'package:flutter/material.dart';

import '../core/strings.dart';
import '../game/game_controller.dart';
import 'theme.dart';

class OnboardingOverlay extends StatelessWidget {
  const OnboardingOverlay({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.onboardingActive) return const SizedBox.shrink();
    final step = controller.snapshot.onboardingStep;
    final title = step == 0 ? S.onboardTapTitle : S.onboardMergeTitle;
    final body = step == 0 ? S.onboardTapBody : S.onboardMergeBody;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Container(
          color: const Color(0x99000000),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HatchTheme.panel,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: HatchTheme.gold),
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: HatchTheme.gold,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: HatchTheme.cream),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton(
                          onPressed: controller.skipOnboarding,
                          child: const Text(S.skip),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: controller.advanceOnboarding,
                          style: FilledButton.styleFrom(
                            backgroundColor: HatchTheme.accent,
                          ),
                          child: Text(step == 0 ? S.next : S.gotIt),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.paddingOf(context).bottom + 72),
            ],
          ),
        ),
      ),
    );
  }
}
