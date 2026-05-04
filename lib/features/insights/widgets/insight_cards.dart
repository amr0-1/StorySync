import 'package:flutter/material.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';

/// Animated carousel of dynamic reading insight strings.
///
/// Auto-advances every 5 seconds with smooth transitions.
/// Displays a maximum of 6 insights from a deduplicated pool.
class InsightCards extends StatefulWidget {
  final List<String> insights;

  const InsightCards({super.key, required this.insights});

  @override
  State<InsightCards> createState() => _InsightCardsState();
}

class _InsightCardsState extends State<InsightCards> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    if (widget.insights.length > 1) {
      _startAutoAdvance();
    }
  }

  void _startAutoAdvance() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || widget.insights.isEmpty) return;

      final nextPage = (_currentPage + 1) % widget.insights.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      _startAutoAdvance();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    if (widget.insights.isEmpty) {
      return _buildEmptyState(colors);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INSIGHTS',
          style: AppTextStyles.overline.copyWith(color: colors.textHint),
        ),
        const SizedBox(height: AppDimensions.space12),
        SizedBox(
          height: 80,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.insights.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _InsightCard(text: widget.insights[index], colors: colors);
            },
          ),
        ),
        if (widget.insights.length > 1) ...[
          const SizedBox(height: AppDimensions.space8),
          _buildDots(colors),
        ],
      ],
    );
  }

  Widget _buildDots(VoidInkColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.insights.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: i == _currentPage ? 16 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: i == _currentPage
                ? colors.goldSpark
                : colors.inkMuted.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(VoidInkColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: colors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 20, color: colors.textHint),
          const SizedBox(width: AppDimensions.space12),
          Text(
            'Start reading to unlock insights',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String text;
  final VoidInkColors colors;

  const _InsightCard({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    // Extract emoji from start of text
    final hasEmoji = text.length > 2 && !RegExp(r'^[a-zA-Z0-9]').hasMatch(text);
    final emoji = hasEmoji ? text.substring(0, 2).trim() : '📊';
    final displayText = hasEmoji ? text.substring(2).trim() : text;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: colors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Text(
              displayText,
              style: AppTextStyles.titleSmall.copyWith(
                color: colors.textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
