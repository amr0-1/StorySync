import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storysync/core/providers/shared_prefs_provider.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/shared/widgets/app_icon.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Scaffold(
      backgroundColor: colors.inkVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space24,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(child: AppIcon.large()),
              const SizedBox(height: AppDimensions.space32),
              Text(
                'Welcome to StorySync',
                style: AppTextStyles.displayLarge.copyWith(
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space16),
              Text(
                'Track your Manga, Manhwa, and Manhua offline first. Your library, securely stored on your device.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(isFirstRunProvider.notifier)
                      .setFirstRunCompleted();
                  if (context.mounted) {
                    context.go('/library');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.goldSpark,
                  foregroundColor: colors.inkVoid,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.space16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                ),
                child: Text(
                  'Get Started',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.inkVoid,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }
}
