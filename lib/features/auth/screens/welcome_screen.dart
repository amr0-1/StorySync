import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storysync/core/providers/shared_prefs_provider.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/shared/widgets/app_icon.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingFeature> _features = const [
    _OnboardingFeature(
      icon: Icons.offline_bolt_rounded,
      title: 'Local-First Library',
      description:
          'Track your Manga, Manhwa, and Manhua securely and offline using high-performance Isar NoSQL.',
    ),
    _OnboardingFeature(
      icon: Icons.search_rounded,
      title: 'Seamless Discovery',
      description:
          'Directly integrated with MangaDex, providing an expansive ecosystem to find and track your favorite series.',
    ),
    _OnboardingFeature(
      icon: Icons.insights_rounded,
      title: 'Insights Tab',
      description:
          'Discover detailed analytics and visualize your reading habits. See your stats, track your pace, and view your progress using our GitHub-style contribution heatmap!',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _features.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await ref.read(isFirstRunProvider.notifier).setFirstRunCompleted();
    if (mounted) {
      context.go('/library');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colors.inkVoid,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.space32),
            const AppIcon.large(),
            const SizedBox(height: AppDimensions.space24),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _features.length,
                itemBuilder: (context, index) {
                  return _FeatureCard(
                    feature: _features[index],
                    colors: colors,
                    theme: theme,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space24,
                vertical: AppDimensions.space32,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PageIndicators(
                    count: _features.length,
                    currentIndex: _currentPage,
                    activeColor: colors.goldSpark,
                    inactiveColor: theme.colorScheme.outline.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: _onNext,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space24,
                        vertical: AppDimensions.space16,
                      ),
                      decoration: BoxDecoration(
                        color: colors.goldSpark,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMD,
                        ),
                      ),
                      child: Text(
                        _currentPage == _features.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: colors.inkVoid,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _OnboardingFeature feature;
  final VoidInkColors colors;
  final ThemeData theme;

  const _FeatureCard({
    required this.feature,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.space32),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.1),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(feature.icon, size: 64, color: colors.goldSpark),
                  const SizedBox(height: AppDimensions.space24),
                  Text(
                    feature.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Text(
                    feature.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageIndicators extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  const _PageIndicators({
    required this.count,
    required this.currentIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: currentIndex == index ? 24 : 8,
          decoration: BoxDecoration(
            color: currentIndex == index ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _OnboardingFeature {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}
