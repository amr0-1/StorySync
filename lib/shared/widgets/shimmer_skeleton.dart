import 'package:flutter/material.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';

/// A shimmer effect widget that cycles between two colors
class ShimmerSkeleton extends StatefulWidget {
  /// The width of the skeleton
  final double? width;

  /// The height of the skeleton
  final double? height;

  /// Border radius of the skeleton
  final double borderRadius;

  const ShimmerSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppDimensions.radiusSM,
  });

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final color = Color.lerp(colors.inkPanel, colors.inkMuted, t);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// A skeleton card widget for loading states in grid view
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Container(
      width: AppDimensions.gridCardWidth,
      decoration: BoxDecoration(
        color: colors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cover skeleton
          ShimmerSkeleton(
            height: AppDimensions.gridCoverHeight,
            borderRadius: 0,
          ),

          // Title and badge skeleton
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title line 1
                  const ShimmerSkeleton(
                    width: double.infinity,
                    height: 14,
                    borderRadius: AppDimensions.radiusXS,
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  // Title line 2 (shorter)
                  const ShimmerSkeleton(
                    width: 80,
                    height: 14,
                    borderRadius: AppDimensions.radiusXS,
                  ),
                  const Spacer(),
                  // Badge skeleton
                  const ShimmerSkeleton(
                    width: 60,
                    height: 18,
                    borderRadius: AppDimensions.radiusFull,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A skeleton list tile widget for loading states in list view
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
      child: const Row(
        children: [
          // Thumbnail skeleton
          ShimmerSkeleton(
            width: AppDimensions.listThumbWidth,
            height: AppDimensions.listThumbHeight,
            borderRadius: AppDimensions.radiusXS,
          ),
          SizedBox(width: AppDimensions.space12),

          // Title and info skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                ShimmerSkeleton(
                  width: double.infinity,
                  height: 16,
                  borderRadius: AppDimensions.radiusXS,
                ),
                const SizedBox(height: AppDimensions.space8),
                // Status and author
                Row(
                  children: [
                    ShimmerSkeleton(
                      width: 60,
                      height: 18,
                      borderRadius: AppDimensions.radiusFull,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ShimmerSkeleton(
                        height: 12,
                        borderRadius: AppDimensions.radiusXS,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chapter counter skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerSkeleton(
                width: 32,
                height: 18,
                borderRadius: AppDimensions.radiusXS,
              ),
              const SizedBox(height: AppDimensions.space4),
              ShimmerSkeleton(
                width: 40,
                height: 12,
                borderRadius: AppDimensions.radiusXS,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A grid of skeleton cards for loading state
class SkeletonGrid extends StatelessWidget {
  /// Number of skeleton cards to show
  final int itemCount;

  const SkeletonGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.space16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio:
            AppDimensions.gridCardWidth / AppDimensions.gridCardHeight,
        crossAxisSpacing: AppDimensions.space16,
        mainAxisSpacing: AppDimensions.space16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonCard(),
    );
  }
}
